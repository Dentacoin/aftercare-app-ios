//
//  ActionScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/6/17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
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
    
    fileprivate var pagesArray: [ActionView] = []
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
    }
    
    //MARK: - Internal logic
    
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
    
    fileprivate func createSubScreens() -> [ActionView]? {
        
        let pageTypes: [ActionRecordType] = [.flossed, .brush, .rinsed]
        
        for i in 0...pageTypes.count - 1 {
            let type = pageTypes[i]
            let page = Bundle.main.loadNibNamed(
                "ActionView",
                owner: self.contentScrollView,
                options: nil
            )?.first as! ActionView
            
            page.backgroundColor = .clear
            page.config(type: type)
            page.delegate = self
            pagesArray.append(page)
        }
        return pagesArray
    }
    
    fileprivate func setupSubScreens(_ screens: [ActionView]) {
        
        contentScrollView.frame = CGRect(
            x: 0,
            y: 0, width: view.frame.width,
            height: view.frame.height
        )
        contentScrollView.contentSize = CGSize(
            width: view.frame.width * CGFloat(screens.count),
            height: 1//we don't need vertical scrooling so we set height to 1
        )
        contentScrollView.isPagingEnabled = true
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        
        for i in 0 ..< screens.count {
            let screen = screens[i]
            screen.frame = CGRect(
                x: view.frame.width * CGFloat(i),
                y: 0,
                width: view.frame.width,
                height: view.frame.height
            )
            contentScrollView.addSubview(screen)
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
    
    func statisticsScreenOpened(_ sender: ActionView) {
        //open all other statistics screens except the sender where is already opened
        for page in pagesArray {
            if page != sender {
                page.openStatisticsScreen(false)
            }
        }
    }
    
    func statisticsScreenClosed(_ sender: ActionView) {
        //close all other statistics screens except the sender where is already closed
        for page in pagesArray {
            if page != sender {
                page.closeStatisticsScreen(false)
            }
        }
    }
    
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
