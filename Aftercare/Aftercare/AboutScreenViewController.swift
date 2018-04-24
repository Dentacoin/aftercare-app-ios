//
//  AboutScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/9/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

class AboutScreenViewController: UIViewController, ContentConformer {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    //MARK: - delegate
    
    var contentDelegate: ContentDelegate?
    
    //MARK: - Public
    
    var header: InitialPageHeaderView! {
        return headerView as! InitialPageHeaderView
    }
    
    //MARK: - fileprivates
    
    fileprivate var calculatedConstraints = false
    
    //MARK: - lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.delegate = self
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        header.updateTitle("about_hdl_about".localized())
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
    
    //MARK: - Private logic
    
    fileprivate func setup() {
        
        //add app version at the bottom of the text field
        guard let dict = Bundle.main.infoDictionary else { return }
        guard let version: String = dict["CFBundleShortVersionString"] as? String else { return }
        guard let build: String = dict["CFBundleVersion"] as? String else { return }
        
        appVersionLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntLabelFontSize)
        appVersionLabel.textColor = UIColor.dntCeruleanBlue
        appVersionLabel.text = "\(version).\(build)"
    }
    
}

extension AboutScreenViewController: InitialPageHeaderViewDelegate {
    
    func mainMenuButtonIsPressed() {
        contentDelegate?.openMainMenu()
    }
    
}
