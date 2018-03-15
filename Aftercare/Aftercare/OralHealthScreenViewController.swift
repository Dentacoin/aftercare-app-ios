//
//  OralHealthScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/9/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

class OralHealthScreenViewController: UIViewController, ContentConformer {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Delegates
    
    var contentDelegate: ContentDelegate?
    
    //MARK: - Public
    
    var header: InitialPageHeaderView! {
        return headerView as! InitialPageHeaderView
    }
    
    //MARK: - fileprivates
    
    fileprivate var oralHealthData: [OralHealthData]?
    fileprivate let cellIdentifier = String(describing: OralHealthTableCell.self)
    fileprivate var webViewIsOpen = false
    fileprivate var showTitleBar = false
    fileprivate var calculatedConstraints = false
    
    fileprivate var webView: UIWebView = {
        let webView = UIWebView()
        return webView
    }()

    fileprivate var webViewController: UIViewController = {
        let controller = UIViewController()
        return controller
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        header.updateTitle(NSLocalizedString("Oral Health", comment: ""))
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(!showTitleBar, animated: false)
        showTitleBar = false
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
    
    //MARK: - Internal logic
    
    fileprivate func requestOralHealthData() {
        APIProvider.retreiveOralHealthData() { [weak self] result, error in
            
            if let error = error?.toNSError() {
                UIAlertController.show(
                    controllerWithTitle: NSLocalizedString("Error", comment: ""),
                    message: error.localizedDescription,
                    buttonTitle: NSLocalizedString("Ok", comment: "")
                )
                
                let errorState = State(.errorState, NSLocalizedString("Error...", comment: ""))
                self?.showState(errorState)
                
                return
            }
            
            self?.oralHealthData = result
            
            if let count = self?.oralHealthData?.count, count == 0 {
                let emptyState = State(.emptyState, NSLocalizedString("No Content Found!", comment: ""))
                self?.showState(emptyState)
            }
            
            self?.reloadData()
            
        }
    }
    
    fileprivate func reloadData() {
        self.tableView.reloadData()
    }
}

//MARK: - Apply theme and appearance

extension OralHealthScreenViewController {
    
    fileprivate func setup() {
        
        header.updateTitle(NSLocalizedString("Oral Health", comment: ""))
        
        tableView.register(
            UINib(
                nibName: cellIdentifier,
                bundle: nil
            ),
            forCellReuseIdentifier: cellIdentifier
        )
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        //tableView.allowsSelection = false
        
        //these two settings help us use auto layout for the cells and
        //their size to be determined by its contents
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 216
        
        requestOralHealthData()
    }
    
}

//MARK: - UITableViewDelegate

extension OralHealthScreenViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: OralHealthTableCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? OralHealthTableCell
        if let cell = cell {
            guard let data = self.oralHealthData?[indexPath.row] else { return cell }
            cell.setup(data)
            cell.backgroundColor = .clear
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let data = self.oralHealthData?[indexPath.row] else { return }
        guard let url = URL(string: data.contentURL ?? "") else { return }
        
        //open the url outside the app in browser
        //UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
        showTitleBar = true
        self.navigationController?.pushViewController(webViewController, animated: true)
        
        webView.frame = webViewController.view.frame
        webView.backgroundColor = .white
        webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        webViewController.view.addSubview(webView)
        webView.loadRequest(URLRequest(url: url))
        
    }
    
}

//MARK: - UITableViewDataSource

extension OralHealthScreenViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.oralHealthData?.count ?? 0
    }
    
}

//MARK: - InitialPageHeaderViewDelegate

extension OralHealthScreenViewController: InitialPageHeaderViewDelegate {
    
    func mainMenuButtonIsPressed() {
        contentDelegate?.openMainMenu()
    }
    
}
