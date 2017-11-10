//
//  ActionScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/6/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit

class ActionScreenViewController: UIViewController, ContentConformer {
    
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
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
    fileprivate var lastTab: Int = 0
    fileprivate var tutorialsAlreadySetup = false
    
    fileprivate let goalPopupScreen: GoalPopupScreen = {
        let popup = Bundle.main.loadNibNamed(
            String(describing: GoalPopupScreen.self),
            owner: self,
            options: nil
            )?.first as! GoalPopupScreen
        return popup
    }()
    
    fileprivate let routinesPopupScreen: RoutinesPopupScreen = {
        let popup = Bundle.main.loadNibNamed(
            String(describing: RoutinesPopupScreen.self),
            owner: self,
            options: nil
            )?.first as! RoutinesPopupScreen
        return popup
    }()
    
    fileprivate lazy var routineMorningStartButtonLabel: String = {
       return NSLocalizedString("Start morning routine", comment: "")
    }()
    
    fileprivate lazy var routineEveningStartButtonLabel: String = {
        return NSLocalizedString("Start evening routine", comment: "")
    }()
    
    fileprivate lazy var routineDescriptionLabel: String = {
        return NSLocalizedString("Good morning sunshine. It is a beautiful day. Let’s get you started properly. \n\n *You will receive your reward upon completion of the 90-day period.", comment: "")
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.delegate = self
        contentScrollView.delegate = self
        contentScrollView.clipsToBounds = false
        UserDataContainer.shared.delegate = self
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestDayRoutine()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            if !calculatedConstraints {
                calculatedConstraints = true
                let topPadding = self.view.safeAreaInsets.top
                headerHeightConstraint.constant += topPadding
                headerHeight = headerHeightConstraint.constant
                
                //If no routine, show tutorial on current page
                if UserDataContainer.shared.routine == nil {
                    if let page = pagesArray.first {
                        page.setupTutorials()
                    }
                }
                
            }
        }
        updateSubscreensContentSizes()
    }
    
    //MARK: - Internal logic
    
    fileprivate func requestDayRoutine() {
        
        if !UserDataContainer.shared.isRoutineRequested {
            UserDataContainer.shared.isRoutineRequested = true
            
            let routine = Routine.getRoutineForNow()
            if let routine = routine {
                
                let buttonLabel: String?
                let routinePath: RoutinePath?
                if routine.startHour == 2 {
//                    if UserDataContainer.shared.isMorningRoutineDone {
//                        //the routine is already done
//                        return
//                    }
                    UserDataContainer.shared.isMorningRoutineDone = true
                    buttonLabel = routineMorningStartButtonLabel
                    routinePath = .morning
                } else {
//                    if UserDataContainer.shared.isEveningRoutineDone {
//                        //routine is alredy done
//                        return
//                    }
                    UserDataContainer.shared.isEveningRoutineDone = true
                    buttonLabel = routineEveningStartButtonLabel
                    routinePath = .evening
                }
                
                UserDataContainer.shared.routine = routine
                
                let routinesPopup = self.routinesPopupScreen
                routinesPopup.delegate = self
                routinesPopup.setCurrentDay(UserDataContainer.shared.dayNumberOf90DaysSession ?? 0)
                routinesPopup.setRoutinesDescription(routineDescriptionLabel)
                routinesPopup.setRoutinesStartLabel(buttonLabel!)
                routinesPopup.delegate = self
                let frame = UIScreen.main.bounds
                routinesPopup.frame = frame
                self.view.addSubview(routinesPopup)
                
                //play routine greeting sound
                SoundManager.shared.playSound(SoundType.greeting(routinePath!))
                //play background music
                SoundManager.shared.playRandomMusic()
            }
        }
    
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
    
    fileprivate func scrollContentScrollViewTo(page index: Int) {
        //scroll UIScrollView's contents to the page according to selected tab with animation
        self.currentPageIndex = index
        DispatchQueue.main.async() {
            UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.contentScrollView.contentOffset.x = self.contentScrollView.frame.size.width * CGFloat(index)
            }, completion: { [weak self] success in
                if !(self?.tutorialsAlreadySetup)! {
                    self?.tutorialsAlreadySetup = true
                    if let page = self?.pagesArray[index] {
                        page.setupTutorials()
                    }
                }
            })
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
            contentScrollView.isScrollEnabled = false
        }
    }
    
    func timerStopped() {
        if let routine = UserDataContainer.shared.routine {
            //we have routine
            
            if routine.actions.count > 0 {
                
                //proceed with the next screen
                guard let nextScreenType = routine.actions.first else { return }
                guard let pageIndex = getPageIndex(nextScreenType) else { return }
                scrollContentScrollViewTo(page: pageIndex)
                let page = pagesArray[pageIndex]
                page.changeStateTo(.Ready)
                self.lastTab = pageIndex
                
                return
            } else {
                SoundManager.shared.stopMusic()
            }
            //we don't have any more screen in our routine so we set it's value to nil and exit
            UserDataContainer.shared.routine = nil
        }
        
        exitFullscreen()
        contentScrollView.isScrollEnabled = true
        
    }
    
    func actionComplete() {
        if self.currentPageIndex >= self.pagesArray.count - 1 {
            return
        }
        self.scrollContentScrollViewTo(page: self.currentPageIndex + 1)
    }
    
    fileprivate func goFullScreen() {
        self.view.layoutIfNeeded()
        self.headerHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func exitFullscreen() {
        self.view.layoutIfNeeded()
        self.headerHeightConstraint.constant =  self.headerHeight
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            self.header.selectTab(atIndex: self.lastTab)
        }
    }
    
}

//MARK: - ActionHeaderViewDelegate

extension ActionScreenViewController: ActionHeaderViewDelegate {
    
    func mainMenuButtonIsPressed() {
        contentDelegate?.openMainMenu()
    }
    
    func tabBarButtonPressed(_ index: Int) {
        scrollContentScrollViewTo(page: index)
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
        header.selectTab(atIndex: pageIndex)
    }
    
}

//MARK: - RoutinesPopupScreenDelegate

extension ActionScreenViewController: RoutinesPopupScreenDelegate {
    
    func onRoutinesButtonPressed() {
        routinesPopupScreen.removeFromSuperview()
        
        guard let routine = UserDataContainer.shared.routine else { return }
        //scroll to first routine screen
        guard let pageIndex = getPageIndex(routine.actions.first!) else { return }
        scrollContentScrollViewTo(page: pageIndex)
        self.header.selectTab(atIndex: pageIndex)
        
        let page = pagesArray[pageIndex]
        page.changeStateTo(.Ready)
        
        //Lock the scroll view and header while executing routine
        self.view.layoutIfNeeded()
        self.headerHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        contentScrollView.isScrollEnabled = false
        
    }
    
}
