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
        return (headerView as! InitialPageHeaderView)
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
        guard let version = SystemMethods.AppInfoPlist.value(forKey: .CFBundleShortVersionString) else { return }
        guard let build = SystemMethods.AppInfoPlist.value(forKey: .CFBundleVersion) else { return }
        
        appVersionLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntLabelFontSize)
        appVersionLabel.textColor = UIColor.dntCeruleanBlue
        appVersionLabel.text = "\(version).\(build)"
        
        let localizedHeading = "about_hdl_heading".localized()
        let localizedAbout = "about_txt_about_ios".localized()
        let aboutText = NSMutableAttributedString()
        aboutText.bold(localizedHeading).normal("\n\n").normal(localizedAbout).normal("\n\n" + "about_url_dentacare".localized())
        
        aboutTextView.attributedText = aboutText
    }
    
}

extension AboutScreenViewController: InitialPageHeaderViewDelegate {
    
    func mainMenuButtonIsPressed() {
        contentDelegate?.openMainMenu()
    }
    
}

// Attributed String Helpers

fileprivate extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.dntLatoBlackFont(size: UIFont.dntLargeTextSize)!]
        let boldString = NSMutableAttributedString(string: text, attributes: attrs)
        append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.dntLatoRegularFontWith(size: UIFont.dntNormalTextSize)!]
        let normal = NSAttributedString(string: text, attributes: attrs)
        append(normal)
        return self
    }
}
