//
//  WelcomeScreenViewController.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/7/17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import UIKit

class WelcomeScreenViewController : UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var userFirstAndLastNames: UILabel!
    
    //MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
        //sync data with the server
        UserDataContainer.shared.syncWithServer()
    }
    
    fileprivate let controller: MainMenuViewController! =
        UIStoryboard.main.instantiateViewController()
    
}

//MARK: - Theme and components setup

extension WelcomeScreenViewController {
    
    func setup() {
        
        self.welcomeLabel.font = UIFont.dntLatoRegularFontWith(size: UIFont.dntTitleFontSize)
        self.welcomeLabel.textColor = .white
        self.welcomeLabel.text = NSLocalizedString("WELCOME", comment: "")
        
        self.userFirstAndLastNames.font = UIFont.dntLatoLightFont(size: UIFont.dntTitleFontSize)
        self.userFirstAndLastNames.textColor = .white
        
        guard let data = UserDataContainer.shared.userInfo else { return }
        
        let firstName = data.firstName ?? ""
        let lastName = data.lastName ?? ""
        self.userFirstAndLastNames.text = firstName + " " + lastName
        
        guard let avatar = UserDataContainer.shared.userAvatar else {
            loadAvatar()
            return
        }
        
        updateAvatarAndNavigateToNextScreen(avatar)
  
    }
    
    func loadAvatar() {
        UserDataContainer.shared.loadUserAvatar() { [weak self] _ in
            guard let avatar = UserDataContainer.shared.userAvatar else { return }
            self?.updateAvatarAndNavigateToNextScreen(avatar)
        }
    }
    
    func updateAvatarAndNavigateToNextScreen(_ avatar: UIImage) {
        setAvatar(avatar)
        showNextScreenAfterTime()
    }

    func showNextScreenAfterTime() {
        _ = controller.view
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: { [weak self] in
            self?.presentContentViewController()
            //Setup Notifications
            _ = NotificationsManager.shared
        })
    }
    
    func setAvatar(_ image: UIImage) {
        self.userAvatarImage.image = image
        self.userAvatarImage.clipsToBounds = true
        self.userAvatarImage.layer.cornerRadius = self.userAvatarImage.bounds.size.width / 2
    }
    
    func presentContentViewController() {
        if let navController = self.navigationController {
            navController.pushViewController(controller, animated: true)
        }
    }
    
}
