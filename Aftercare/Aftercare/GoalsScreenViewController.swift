//
//  GoalsScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/9/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

class GoalsScreenViewController: UIViewController, ContentConformer {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var collectionView: UICollectionView!
    
    var header: InitialPageHeaderView! {
        return headerView as! InitialPageHeaderView
    }
    
    //MARK: - fileprivates
    
    fileprivate let cellIdentifier = String(describing: GoalsScreenCell.self)
    fileprivate var dataSource: [GoalData]?
    fileprivate let columns: CGFloat = 3.0
    fileprivate let cellPading: CGFloat = 16.0
    fileprivate var calculatedConstraints = false
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    fileprivate let goalPopupScreen: GoalPopupScreen = {
        let popup = Bundle.main.loadNibNamed(
            String(describing: GoalPopupScreen.self),
            owner: self,
            options: nil
            )?.first as! GoalPopupScreen
        return popup
    }()
    
    var contentDelegate: ContentDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            if !calculatedConstraints {
                calculatedConstraints = true
                let topPadding = self.view.safeAreaInsets.top
                headerHeightConstraint.constant += topPadding
            }
        }
    }
}

//MARK: - Theme & appearance

extension GoalsScreenViewController {
    
    fileprivate func setup() {
        
        header.updateTitle("goals_hdl_goals".localized())
        
        //setup collection
        self.collectionView.register(
            UINib(
                nibName: cellIdentifier,
                bundle: nil
            ),
            forCellWithReuseIdentifier: cellIdentifier
        )
        
        self.collectionView.backgroundColor = .clear
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.dataSource = UserDataContainer.shared.goalsData
        
        if let count = self.dataSource?.count, count == 0 {
            let emptyState = State(.emptyState, "goals_txt_no_goals_found".localized())
            showState(emptyState)
        }
        
        if self.dataSource == nil {
            let errorState = State(.errorState, "error_popup_title".localized())
            showState(errorState)
        }
    }
    
}

//MARK: - UICollectionViewDelegate

extension GoalsScreenViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let popup = self.goalPopupScreen
        if let data = self.dataSource?[indexPath.row] {
            popup.config(data)
            let frame = UIScreen.main.bounds
            popup.frame = frame
            self.view.addSubview(popup)
            
            _ = UIView.animate(withDuration: 0.5, animations: {
                popup.alpha = 1
            })
        }
        
    }
}

extension GoalsScreenViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screen = UIScreen.main.bounds
        let cellWidth: CGFloat = (screen.width / columns) - cellPading
        let cellHeight = cellWidth * 1.5
        let size = CGSize(width: cellWidth, height: cellHeight)
        
        return size
    }
}

//MARK: - UICollectionViewDataSource

extension GoalsScreenViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GoalsScreenCell
        if let data = self.dataSource?[indexPath.row] {
            cell.config(data)
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource?.count ?? 0
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

//MARK: - InitialPageHeaderViewDelegate

extension GoalsScreenViewController: InitialPageHeaderViewDelegate {
    
    func mainMenuButtonIsPressed() {
        contentDelegate?.openMainMenu()
    }
    
}
