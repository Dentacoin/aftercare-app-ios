//
// Aftercare
// Created by Dimitar Grudev on 07.02.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import UIKit

class TutorialsPopupScreen: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: - Localized strings
    
    fileprivate lazy var nextString:String = {
        return "onboarding_txt_next".localized()
    }()
    
    fileprivate lazy var iGotItString:String = {
        return "onboarding_txt_got_it".localized()
    }()
    
    fileprivate var tutorialScreens: [TutorialView]?
    fileprivate var currentPage: Int = 0
    
    // MARK: - Delegates
    
    var delegate: TutorialsPopupScreenDelegate?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculateLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //disable tutorials to not show anymore
        UserDataContainer.shared.setTutorialsToggle(false)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Internal Logic
    
    fileprivate func setup() {
        
        closeButton.tintColor = .white
        
        //pageControl seetings
        pageControl.isUserInteractionEnabled = false
        pageControl.tintColor = .clear
        pageControl.pageIndicatorTintColor = .dntDarkSkyBlue
        pageControl.currentPageIndicatorTintColor = .dntIceBlue
        
        let themeManager = ThemeManager.shared
        themeManager.setDCBlueTheme(to: self.nextButton, ofType: .ButtonDefault)
        self.nextButton.setTitle(nextString, for: .normal)
        self.nextButton.setTitle(nextString, for: .highlighted)
        
        tutorialScreens = []
        guard var screens = tutorialScreens else {
            return
        }
        let tutorialsModel = Tutorials.getTutorialsModel()
        
        for tutorial in tutorialsModel {
            guard let tutorialView: TutorialView = TutorialView.loadViewFromNib() else {
                return
            }
            tutorialView.tutorialData = tutorial
            tutorialView.frame = contentScrollView.frame
            screens.append(tutorialView)
        }
        
        contentScrollView.delegate = self
        contentScrollView.clipsToBounds = false
        contentScrollView.isPagingEnabled = true
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        
        tutorialScreens = screens
        pageControl.numberOfPages = screens.count
        
        for i in 0 ..< screens.count {
            let screen = screens[i]
            contentScrollView.addSubview(screen)
        }
        
        calculateLayouts()
    }
    
    fileprivate func calculateLayouts() {
        guard var screens = tutorialScreens else {
            return
        }
        for i in 0 ..< screens.count {
            let screen = screens[i]
            let scrollBounds = contentScrollView.bounds
            let frame = CGRect(
                x: scrollBounds.width * CGFloat(i),
                y: 0,
                width: scrollBounds.width,
                height: scrollBounds.height
            )
            screen.frame = frame
        }
        
        contentScrollView.contentSize = CGSize(
            width: contentScrollView.bounds.width * CGFloat(screens.count),
            height: 1//we don't need vertical scrooling so we set height to 1
        )
    }
    
    fileprivate func scrollContentScrollViewTo(page index: Int) {
        self.currentPage = index
        DispatchQueue.main.async() {
            UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.contentScrollView.contentOffset.x = self.contentScrollView.frame.size.width * CGFloat(index)
            }, completion: nil)
        }
    }
    
    fileprivate func updateComponents(forPage page: Int) {
        updateNextButtonLabel(page)
        updatePageControl(page)
    }
    
    fileprivate func updateNextButtonLabel(_ page: Int) {
        guard let totalPages = self.tutorialScreens?.count else {
            return
        }
        if self.currentPage == totalPages - 1 {
            self.nextButton.setTitle(iGotItString, for: .normal)
            self.nextButton.setTitle(iGotItString, for: .highlighted)
        } else {
            self.nextButton.setTitle(nextString, for: .normal)
            self.nextButton.setTitle(nextString, for: .highlighted)
        }
    }
    
    fileprivate func updatePageControl(_ page: Int) {
        self.pageControl.currentPage = page
    }
    
    fileprivate func closeTutorials() {
        delegate?.onTutorialsClosed()
    }
}

// MARK: - IBActions

extension TutorialsPopupScreen {
    
    @IBAction func onNextButtonPressed(_ sender: UIButton) {
        guard let pages: Int = self.tutorialScreens?.count else {
            return
        }
        if self.currentPage < pages - 1 {
            self.scrollContentScrollViewTo(page: self.currentPage + 1)
        } else {
            delegate?.onTutorialsFinished()
        }
    }
    
    @IBAction func onCloseButtonPressed(_ sender: UIButton) {
        closeTutorials()
    }
    
}

//MARK: - UIScrollViewDelegate

extension TutorialsPopupScreen: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        self.currentPage = pageIndex
        self.updateComponents(forPage: pageIndex)
    }
    
}

// MARK: - Delegate protocol

protocol TutorialsPopupScreenDelegate {
    func onTutorialsFinished()
    func onTutorialsClosed()
}
