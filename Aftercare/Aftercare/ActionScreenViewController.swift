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
    fileprivate var tooltipsShown = false
    
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
    
    fileprivate lazy var routinesPopupScreen: RoutinesPopupScreen = {
        let popup = Bundle.main.loadNibNamed(
            String(describing: RoutinesPopupScreen.self),
            owner: self,
            options: nil
            )?.first as! RoutinesPopupScreen
        return popup
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDataContainer.shared.getTutorialsToggle() == true {
            showTutorials()
        } else {
            requestDayRoutine()
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
        
        //If no routine, show tooltip on current page
        if UserDataContainer.shared.routine == nil, tooltipsShown == false {
            tooltipsShown = true
            if let page = pagesArray.first {
                //Show tooltips only in first sub-screen e.g. Floss screen
                page.showTooltips()
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
        
        if !UserDataContainer.shared.isRoutineRequested {
            UserDataContainer.shared.isRoutineRequested = true
            
            let routine = Routines.getRoutineForNow()
            if var routine = routine {
                
                guard routine.isDone == false else {
                    return
                }
                
                routine.isDone = true
                
                SoundManager.shared.playSound(SoundType.greeting(routine.type))
                UserDataContainer.shared.routine = routine
                
                let routinesPopup = self.routinesPopupScreen
                routinesPopup.delegate = self
                
                let frame = UIScreen.main.bounds
                routinesPopup.frame = frame
                self.view.addSubview(routinesPopup)
                
                routinesPopup.setup(routine)
                routinesPopup.popupType = .start
            }
        }
    
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
    
    fileprivate func scrollContentScrollViewTo(page index: Int) {
        //scroll UIScrollView's contents to the page according to selected tab with animation
        self.currentPageIndex = index
        DispatchQueue.main.async() {
            UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.contentScrollView.contentOffset.x = self.contentScrollView.frame.size.width * CGFloat(index)
            }, completion: nil)
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
                scrollContentScrollViewTo(page: index)
                let page = pagesArray[index]
                page.changeStateTo(.Ready)
                
                return
            } else {
                
                let routinesPopup = self.routinesPopupScreen
                routinesPopup.delegate = self
                
                let frame = UIScreen.main.bounds
                routinesPopup.frame = frame
                self.view.addSubview(routinesPopup)
                
                routinesPopup.setup(routine)
                routinesPopup.popupType = .end
                
            }
        }
        exitFullscreen()
    }
    
    func actionComplete() {
        //...
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
        self.lastTab = pageIndex
    }
    
}

//MARK: - RoutinesPopupScreenDelegate

extension ActionScreenViewController: RoutinesPopupScreenDelegate {
    
    func onRoutinesButtonPressed() {
        routinesPopupScreen.removeFromSuperview()
        
        //make all tabs unselected
        self.lastTab = -1
        
        guard let routine = UserDataContainer.shared.routine else { return }
        //scroll to first routine screen
        guard let index = getPageIndex(routine.actions.first!) else { return }
        scrollContentScrollViewTo(page: index)
        
        let page = pagesArray[index]
        page.changeStateTo(.Ready)
        
        //Lock the scroll view and header while executing routine
        self.goFullScreen()
        
        //play background music
        SoundManager.shared.playRandomMusic()
        
    }
    
    func onRoutinesClosed() {
        SoundManager.shared.stopSound()
        SoundManager.shared.stopMusic()
        
        UserDataContainer.shared.routine = nil
    }
    
}

// MARK: - TutorialsPopupScreenDelegate

extension ActionScreenViewController: TutorialsPopupScreenDelegate {
    
    func onTutorialsFinishedPressed() {
        
    }
    
    func onTutorialsClosed() {
        self.tutorialsPopup.dismiss(animated: true, completion: nil)
    }
    
}
