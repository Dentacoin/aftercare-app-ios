//
// Aftercare
// Created by Dimitar Grudev on 23.02.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import UIKit

class WithdrawsScreenViewController: UIViewController, ContentConformer {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomContentPadding: NSLayoutConstraint!
    @IBOutlet weak var withdrawsTableView: UITableView!
    
    // MARK: - public
    
    var header: InitialPageHeaderView! {
        return headerView as! InitialPageHeaderView
    }
    
    // MARK: - fileprivates
    
    fileprivate let withdrawCellIdentifier = "WithdrawsCell"
    fileprivate var calculatedConstraints = false
    fileprivate var withdrawsDataSource: [TransactionData]?
    
    // MARK: - Delegates
    
    var contentDelegate: ContentDelegate?
    
    // MARK: - Lifecycle
    
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
                let bottomPadding = self.view.safeAreaInsets.bottom
                bottomContentPadding.constant -= bottomPadding
            }
        }
    }
    
}

//MARK: - Theme and appearancesetup

extension WithdrawsScreenViewController {
    
    fileprivate func setup() {

        header.updateTitle(NSLocalizedString("Withdraws", comment: ""))
        
        withdrawsTableView.register(
            UINib(
                nibName: withdrawCellIdentifier,
                bundle: nil
            ),
            forCellReuseIdentifier: withdrawCellIdentifier
        )
        
        withdrawsTableView.dataSource = self
        withdrawsTableView.rowHeight = 120
        withdrawsTableView.allowsSelection = false
        
        showLoadingScreenState()
        
        requestWithdrawsData()
    }
    
    fileprivate func requestWithdrawsData() {
        
        APIProvider.getAllTransactions() { [weak self] transactions, error in
            
            if let error = error {
                UIAlertController.show(
                    controllerWithTitle: NSLocalizedString("Error", comment: ""),
                    message: error.toNSError().localizedDescription,
                    buttonTitle: NSLocalizedString("Ok", comment: "")
                )
                self?.showErrorState()
                return
            }
            
            guard let transactions = transactions else {
                self?.showErrorState()
                return
            }
            
            self?.showNoneState()
            
            if transactions.count > 0 {
                self?.withdrawsDataSource = transactions
                self?.withdrawsTableView.reloadData()
            } else {
                self?.showEmptyState()
            }
            
        }
        
    }
    
    fileprivate func showEmptyState() {
        let state = State(StateType.emptyState, NSLocalizedString("No withdraws found!", comment: ""))
        self.showState(state)
    }
    
    fileprivate func showLoadingScreenState() {
        let loadingState = State(.loadingState, NSLocalizedString("Loading...", comment: ""))
        self.showState(loadingState)
    }
    
    fileprivate func showErrorState() {
        let state = State(StateType.errorState, NSLocalizedString("Error...", comment: ""))
        self.showState(state)
    }
    
    fileprivate func showNoneState() {
        let state = State(StateType.none)
        self.showState(state)
    }

}

// MARK: - UITableViewDataSource

extension WithdrawsScreenViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return withdrawsDataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = withdrawsDataSource?[indexPath.row] else {
            print("This should not happen ever")
            return UITableViewCell()
        }
        let cell: WithdrawsCell = withdrawsTableView.dequeueReusableCell(withIdentifier: withdrawCellIdentifier) as! WithdrawsCell
        cell.config(data)
        return cell
    }
    
}

// MARK: - InitialPageHeaderViewDelegate

extension WithdrawsScreenViewController: InitialPageHeaderViewDelegate {
    
    func mainMenuButtonIsPressed() {
        contentDelegate?.openMainMenu()
    }
    
}

