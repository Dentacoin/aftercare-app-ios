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
            }
        }
        updateSubscreensContentSizes()
    }
    
    //MARK: - Internal logic
    
    fileprivate func requestDayRoutine() {
        
        if UserDataContainer.shared.isRoutineRequested {
            UserDataContainer.shared.isRoutineRequested = true
            
//            let routinesPopup = self.routinesPopupScreen
//            routinesPopup.delegate = self
//            routinesPopup.setCurrentDay(58)
//            routinesPopup.setRoutinesDescription("Lorem Ipsum dolor sit amet")
//            routinesPopup.setRoutinesStartLabel("Start routine")
//            let frame = UIScreen.main.bounds
//            routinesPopup.frame = frame
//            self.view.addSubview(routinesPopup)
            
        }
    
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
        
//        let pageTypes: [ActionRecordType] = [.flossed, .brush, .rinsed]
        
//        for i in 0...pageTypes.count - 1 {
//            let type = pageTypes[i]
//            let page = Bundle.main.loadNibNamed(
//                "ActionView",
//                owner: self.contentScrollView,
//                options: nil
//            )?.first as! ActionView
//
//            page.backgroundColor = .clear
//            page.config(type: type)
//            page.delegate = self
//            pagesArray.append(page)
//        }
        
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
    
//    func statisticsScreenOpened(_ sender: UIView) {
//        //open all other statistics screens except the sender where is already opened
//        for page in pagesArray {
//            if page.actionViewRecordType == (sender as! ActionView).actionViewRecordType {
//                page.openStatisticsScreen(animated: false)
//            }
//        }
//    }
//
//    func statisticsScreenClosed(_ sender: UIView) {
//        //close all other statistics screens except the sender where is already closed
//        for page in pagesArray {
//            if page.actionViewRecordType == (sender as! ActionView).actionViewRecordType {
//                continue
//            }
//            page.closeStatisticsScreen(animated: false)
//        }
//    }
    
    func timerStarted() {
        self.view.layoutIfNeeded()
        self.headerHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        contentScrollView.isScrollEnabled = false
    }
    
    func timerStopped() {
        self.view.layoutIfNeeded()
        self.headerHeightConstraint.constant =  self.headerHeight
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        contentScrollView.isScrollEnabled = true
    }
    
    func actionComplete() {
        if self.currentPageIndex >= self.pagesArray.count - 1 {
            return
        }
        self.scrollContentScrollViewTo(page: self.currentPageIndex + 1)
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
        
    }
    
}
