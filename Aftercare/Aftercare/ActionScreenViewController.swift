//
//  ActionScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/6/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

class ActionScreenViewController: UIViewController, ContentConformer {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    
    //MARK: - Public
    
    var header: ActionHeaderView! {
        return headerView as! ActionHeaderView
    }
    
    //MARK: - Delegates
    
    var contentDelegate: ContentDelegate?
    
    //MARK: - fileprivates
    
    fileprivate var pagesArray: [ActionViewProtocol] = []
    fileprivate var calculatedConstraints = false
    fileprivate var headerHeight: CGFloat = 0
    fileprivate var currentPageIndex = 0
    fileprivate var spotlights: [AwesomeSpotlight] = []
    
    fileprivate var routineRecordData: RoutineData? {
        didSet {
            UserDataContainer.shared.lastRoutineRecord = routineRecordData
        }
    }
    
    fileprivate var lastTab: Int = 0 {
        didSet {
            self.header.selectTab(atIndex: self.lastTab)
        }
    }
    
    fileprivate lazy var tutorialsPopup: TutorialsPopupScreen = {
        let popup = Bundle.main.loadNibNamed(
                String(describing: TutorialsPopupScreen.self),
                owner: self,
                options: nil
            )?.first as! TutorialsPopupScreen
        return popup
    }()
    
    fileprivate lazy var goalPopupScreen: GoalPopupScreen = {
        let popup = Bundle.main.loadNibNamed(
            String(describing: GoalPopupScreen.self),
            owner: self,
            options: nil
            )?.first as! GoalPopupScreen
        return popup
    }()
    
    fileprivate lazy var missionPopupScreen: MissionPopupScreen = {
        let popup = Bundle.main.loadNibNamed(
            String(describing: MissionPopupScreen.self),
            owner: self,
            options: nil
            )?.first as! MissionPopupScreen
        return popup
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        prepareSubScreens()
        
        if UserDataContainer.shared.getTutorialsToggle() == true {
            showTutorials()
        } else {
            if UserDataContainer.shared.toggleSpotlightsForActionScreen {
                setupSpotlightTutorials()
            } else {
                requestDayRoutine()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            if !calculatedConstraints {
                let topPadding = self.view.safeAreaInsets.top
                headerHeightConstraint.constant += topPadding
            }
        }
        
        if !calculatedConstraints {
            //save header height value in local variable
            self.headerHeight = headerHeightConstraint.constant
            calculatedConstraints = true
        }
        
        updateSubscreensContentSizes()
    }
    
    //MARK: - Internal logic
    
    fileprivate func requestDayRoutine() {
        
        APIProvider.retreiveCurrentJourney() { [weak self] journey, error in

            if let error = error {
                if error.code == 400, error.errors.first! == "not_started_yet" {
                    // No started Journey - [Show Routine Popup]
                    
                    if let lastPresentRoutine = UserDataContainer.shared.lastTimeRoutinePopupPresented {
                        if Date.passedMinutes(30, fromDate: lastPresentRoutine) == false {
                            //last routine popup shown within last 30 min.
                            return
                        }
                    }
                    
                    if let routine = Routines.getRoutineForNow() {
                        self?.routineRecordData = RoutineData(startTime: Date(), type: routine.type)
                        self?.showStartRoutinePopup(forRoutine: routine)
                    }
                } else {
                    // Someting whent wrong
                    UIAlertController.show(
                        controllerWithTitle: NSLocalizedString("Error", comment: ""),
                        message: error.toNSError().localizedDescription,
                        buttonTitle: NSLocalizedString("Ok", comment: "")
                    )
                    return
                }
            }

            guard let journey = journey else {
                return
            }

            if let routine = Routines.getRoutineForNow() {

                if let lastPresentRoutine = UserDataContainer.shared.lastTimeRoutinePopupPresented {
                    if Date.passedMinutes(30, fromDate: lastPresentRoutine) == false {
                        //last routine popup shown within last 30 min.
                        return
                    }
                }
                
                if journey.skipped > journey.tolerance {
                    // Journey failed [Show Failed Journey Popup]
                    self?.routineRecordData = RoutineData(startTime: Date(), type: routine.type)
                    self?.showFailedJourneyPopup(journey, routine)
                    return
                }

                if let lastRoutine = journey.lastRoutine {
                    let lastRoutineType = lastRoutine.type
                    if routine.type == lastRoutineType {//same type routine
                        guard let lastRoutineEnd = lastRoutine.endTime?.dateFromISO8601 else {
                            return
                        }
                        let days = Date.passedDaysSince(lastRoutineEnd)
                        if days > 0 {// routine is from previous day
                            self?.routineRecordData = RoutineData(startTime: Date(), type: routine.type)
                            self?.showStartRoutinePopup(forRoutine: routine)
                        } else {
                            // This routine is already done
                            return
                        }
                    } else {
                        //different type routine
                        self?.routineRecordData = RoutineData(startTime: Date(), type: routine.type)
                        self?.showStartRoutinePopup(forRoutine: routine)
                    }
                }
                
                if journey.day == 1, journey.skipped == 0 {
                    // Journey just started. [Show Start Journey Popup]
                    self?.routineRecordData = RoutineData(startTime: Date(), type: routine.type)
                    self?.showStartJourneyPopup(journey, routine)
                    return
                }
                
            }
        }
    }
    
    fileprivate func showStartRoutinePopup(forRoutine routine: Routine) {
        UserDataContainer.shared.routine = routine
        UserDataContainer.shared.lastTimeRoutinePopupPresented = Date()
        createMissionPopup()
        MissionPopupConfigurator.config(missionPopupScreen, forType: .routineStart)
        SoundManager.shared.playSound(SoundType.greeting(routine.type))
    }
    
    fileprivate func showEndRoutinePopup(forRoutine routine: Routine) {
        createMissionPopup()
        MissionPopupConfigurator.config(missionPopupScreen, forType: .routineEnd)
        //play end routine popup sound
        SoundManager.shared.playSound(SoundType.sound(routine.type, .rinse, .done(.congratulations)))
    }
    
    fileprivate func showStartJourneyPopup(_ journey: JourneyData, _ routine: Routine) {
        UserDataContainer.shared.routine = routine
        UserDataContainer.shared.journey = journey
        UserDataContainer.shared.lastTimeRoutinePopupPresented = Date()
        createMissionPopup()
        MissionPopupConfigurator.config(missionPopupScreen, forType: .journeyStart)
    }
    
    fileprivate func showFailedJourneyPopup(_ journey: JourneyData, _ routine: Routine) {
        UserDataContainer.shared.routine = routine
        UserDataContainer.shared.journey = journey
        UserDataContainer.shared.lastTimeRoutinePopupPresented = Date()
        createMissionPopup()
        MissionPopupConfigurator.config(missionPopupScreen, forType: .journeyFailed)
    }
    
    fileprivate func showTutorials() {
        tutorialsPopup.delegate = self
        let tutorialsNavController = UINavigationController(rootViewController: tutorialsPopup)
        self.present(tutorialsNavController, animated: true, completion: nil)
    }
    
    fileprivate func getPageIndex(_ type: ActionRecordType) -> Int? {
        for i in 0..<pagesArray.count {
            let page = pagesArray[i]
            if page.actionViewRecordType == type {
                return i
            }
        }
        return nil
    }
    
}

//MARK: - apply theme and appearance

extension ActionScreenViewController {
    
    fileprivate func setup() {
        
        header.delegate = self
        contentScrollView.delegate = self
        contentScrollView.clipsToBounds = false
        UserDataContainer.shared.delegate = self
        
        //Status Bar settings
        self.modalPresentationCapturesStatusBarAppearance = true
        
        header.updateTitle(NSLocalizedString("Dentacare", comment: ""))
        
        guard let screens = createSubScreens() else { return }
        setupSubScreens(screens)
    }
    
    fileprivate func createSubScreens() -> [ActionViewProtocol]? {
        
        let flossPage = FlossActionView()
        flossPage.delegate = self
        pagesArray.append(flossPage)
        let brushPage = BrushActionView()
        brushPage.delegate = self
        pagesArray.append(brushPage)
        let rinsePage = RinseActionView()
        rinsePage.delegate = self
        pagesArray.append(rinsePage)
        
        return pagesArray
    }
    
    fileprivate func setupSubScreens(_ screens: [ActionViewProtocol]) {
        
        contentScrollView.contentSize = CGSize(
            width: view.frame.width * CGFloat(screens.count),
            height: 1//we don't need vertical scrooling so we set height to 1
        )
        contentScrollView.isPagingEnabled = true
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        
        for i in 0 ..< screens.count {
            let screen = screens[i] as! UIView
            contentScrollView.addSubview(screen)
        }
    }
    
    fileprivate func updateSubscreensContentSizes() {
        if pagesArray.count > 0 {
            let scrollFrame = contentScrollView.frame
            for i in 0..<pagesArray.count {
                let page = pagesArray[i]
                let frame = CGRect(
                    x: scrollFrame.size.width * CGFloat(i),
                    y: 0,
                    width: view.frame.width,
                    height: scrollFrame.size.height
                )
                (page as! UIView).frame = frame
            }
        }
    }
    
    fileprivate func prepareSubScreens() {
        //scroll subscreen's scroll view to the middle screen (Brushing)
        scrollContentScrollViewTo(page: 1, animating: false)
    }
    
    fileprivate func scrollContentScrollViewTo(page index: Int, animating animate: Bool) {
        //scroll UIScrollView's contents to the page according to selected tab with animation
        self.currentPageIndex = index
        if animate {
            DispatchQueue.main.async() { [weak self] in
                UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    self?.contentScrollView.contentOffset.x = (self?.view.frame.width)! * CGFloat(index)
                }, completion: nil)
            }
        } else {
            self.contentScrollView.contentOffset.x = view.frame.width * CGFloat(index)
            header.selectTab(atIndex: index)
        }
    }
    
    // Spotlight Tutorials
    
    fileprivate func setupSpotlightTutorials() {
        
        UserDataContainer.shared.toggleSpotlightsForActionScreen = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: { [weak self] in
            let spotlightModels = SpotlightModels.actionScreen
            for model in spotlightModels {
                if let viewUnderSpot = self?.getSpotlightView(forID: model.id) {
                    guard let newFrame = viewUnderSpot.superview?.convert(viewUnderSpot.frame, to: nil) else {
                        return
                    }
                    let smallestSide = newFrame.width > newFrame.height ? newFrame.height : newFrame.width
                    let scaleFactor: CGFloat = 1.7
                    let squareSide = smallestSide * scaleFactor
                    let widthOffset = (newFrame.width - squareSide) / 2
                    let heightOffset = (newFrame.height - squareSide) / 2
                    let square = CGRect(
                        x: newFrame.origin.x + widthOffset,
                        y: newFrame.origin.y + heightOffset,
                        width: squareSide,
                        height: squareSide
                    )
                    self?.spotlights.append(
                        AwesomeSpotlight(
                            withRect: square,
                            shape: model.shape,
                            text: model.label
                        )
                    )
                }
            }

            let spotlightView = AwesomeSpotlightView(frame: (self?.view.frame)!, spotlight: (self?.spotlights)!)
            spotlightView.cutoutRadius = 8
            spotlightView.delegate = self
            self?.view.addSubview(spotlightView)
            spotlightView.start()
        })
        
    }
    
    fileprivate func getSpotlightView(forID id: SpotlightID) -> UIView? {
        guard let container = pagesArray[currentPageIndex].embedView else {
            return nil
        }
        switch id {
            case .totalDCN:
                return container.totalBar
            case .lastRecordTime:
                return container.actionBarsContainer.lastBar
            case .remainActivities:
                return container.actionBarsContainer.leftBar
            case .earnedDCN:
                return container.actionBarsContainer.earnedBar
            case .openStatistics:
                return container.actionFootherContainer.statisticsButton
            default:
                return nil
        }
    }
}

// MARK: - AwesomeSpotlightViewDelegate

extension ActionScreenViewController: AwesomeSpotlightViewDelegate {
    func spotlightViewWillCleanup(_ spotlightView: AwesomeSpotlightView, atIndex index: Int) {
        if index == spotlights.count - 1 {
            requestDayRoutine()
        }
    }
}

//MARK: - ActionViewDelegate

extension ActionScreenViewController: ActionViewDelegate {
    
    func requestToOpenCollectScreen() {
        let vcID = String(describing: CollectScreenViewController.self)
        contentDelegate?.requestLoadViewController(vcID, nil)
    }
    
    func timerStarted() {
        if var routine = UserDataContainer.shared.routine {
            //we have routine
            
            //remove current screen from the list
            routine.actions = Array(routine.actions.dropFirst())
            UserDataContainer.shared.routine = routine
            
        } else {
            goFullScreen()
        }
    }
    
    func timerStopped() {
        if let routine = UserDataContainer.shared.routine {
            //we have routine
            
            if routine.actions.count > 0 {
                
                //proceed with the next screen
                guard let nextScreenType = routine.actions.first else { return }
                guard let index = getPageIndex(nextScreenType) else { return }
                scrollContentScrollViewTo(page: index, animating: true)
                let page = pagesArray[index]
                page.changeStateTo(.Ready)
                
            }
        }
    }
    
    func actionComplete(_ newRecord: ActionRecordData?) {
        
        if let newRecord = newRecord {
            guard var routineData = self.routineRecordData else {
                return
            }
            if var _ = routineData.records {
                routineData.records?.append(newRecord)
            } else {
                routineData.records = [newRecord]
            }
            self.routineRecordData = routineData
        }
        
        // If this is the last action in the routine, try to record the routine
        
        guard let routine = UserDataContainer.shared.routine else {
            exitFullscreen()
            return
        }
        
        if routine.actions.count == 0 {//Routine Complete
            
            guard var routineData = self.routineRecordData else {
                return
            }
            routineData.endTime = Date().iso8601
            
            if var allLocalRecords = Routines.getAllSaved() {
                allLocalRecords.append(routineData)
            }
            
            APIProvider.recordRoutine(routineData, onComplete: { [weak self] (routineData, error) in
                
                if let error = error {
                    print("ActionScreenViewController : actionComplete Error: \(error)")
                    if error.code == ErrorCodes.noInternetConnection.rawValue {
                        //save routineData locally
                        
                        return
                    }
                }
                
                UserDataContainer.shared.lastRoutineRecord = routineData
                
                if let journey = UserDataContainer.shared.journey {
                    if journey.completed == true {
                        if journey.skipped > journey.tolerance {
                            self?.showFailedJourneyPopup(journey, routine)
                        } else {
                            self?.showEndRoutinePopup(forRoutine: routine)
                        }
                    }
                } else {
                    // This should never happen
                    self?.showEndRoutinePopup(forRoutine: routine)
                }
                
                self?.exitFullscreen()
                self?.clearPastRoutineData()
                UserDataContainer.shared.syncWithServer()
                
            })
            
        }
        
    }
    
    fileprivate func clearPastRoutineData() {
        UserDataContainer.shared.journey = nil
        UserDataContainer.shared.routine = nil
        self.routineRecordData = nil
    }
    
    fileprivate func goFullScreen() {
        self.view.layoutIfNeeded()
        self.headerTopConstraint.constant = -self.headerHeight
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        //notify pages that screen will enter fullscreen
        for page in self.pagesArray {
            page.screenWillEnterFullscreen()
        }
        
        contentScrollView.isScrollEnabled = false
    }
    
    fileprivate func exitFullscreen() {
        self.view.layoutIfNeeded()
        self.headerTopConstraint.constant =  0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            //...
        })
        
        //notify pages that screen will exit fullscreen
        for page in self.pagesArray {
            page.screenWillExitFullscreen()
        }
        contentScrollView.isScrollEnabled = true
    }
    
    fileprivate func createMissionPopup() {
        let missionPopup = self.missionPopupScreen
        missionPopup.delegate = self
        
        let frame = UIScreen.main.bounds
        missionPopup.frame = frame
        self.view.addSubview(missionPopup)
    }
    
}

//MARK: - ActionHeaderViewDelegate

extension ActionScreenViewController: ActionHeaderViewDelegate {
    
    func mainMenuButtonIsPressed() {
        contentDelegate?.openMainMenu()
    }
    
    func tabBarButtonPressed(_ index: Int) {
        scrollContentScrollViewTo(page: index, animating: true)
    }
    
}

//MARK: - DataSourceDelegate

extension ActionScreenViewController: DataSourceDelegate {
    
    func actionScreenDataUpdated(_ data: ActionScreenData) {
        for page in pagesArray {
            page.updateData(data)
        }
    }
    
    func goalsDataUpdated(_ data: [GoalData]) {
        //Show Goal popup if new goal is achieved
        if let newGoals = SystemMethods.Goals.scanForNewGoals() {
            let popup = self.goalPopupScreen
            if let data = newGoals.first {
                popup.config(data)
                let frame = UIScreen.main.bounds
                popup.frame = frame
                self.view.addSubview(popup)
                
                UIView.animate(withDuration: 0.5, animations: {
                    popup.alpha = 1
                })
            }
        }
    }
}

//MARK: - UIScrollViewDelegate

extension ActionScreenViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        self.lastTab = pageIndex
    }
    
}

//MARK: - MissionPopupScreenDelegate

extension ActionScreenViewController: MissionPopupScreenDelegate {
    
    func onActionButtonPressed() {
        missionPopupScreen.removeFromSuperview()
        
        //make all tabs unselected
        self.lastTab = -1
        
        guard let routine = UserDataContainer.shared.routine else { return }
        //scroll to first routine screen
        guard let index = getPageIndex(routine.actions.first!) else { return }
        scrollContentScrollViewTo(page: index, animating: true)
        
        let page = pagesArray[index]
        page.changeStateTo(.Ready)
        
        //Lock the scroll view and header while executing routine
        self.goFullScreen()
        
        //play background music
        SoundManager.shared.playRandomMusic()
        
    }
    
    func onPopupClosed() {
        SoundManager.shared.stopSound()
        SoundManager.shared.stopMusic()
        UserDataContainer.shared.routine = nil
    }
    
}

// MARK: - TutorialsPopupScreenDelegate

extension ActionScreenViewController: TutorialsPopupScreenDelegate {
    
    func onTutorialsFinished() {
        self.tutorialsPopup.dismiss(animated: true, completion: nil)
    }
    
    func onTutorialsClosed() {
        self.tutorialsPopup.dismiss(animated: true, completion: nil)
    }
    
}
