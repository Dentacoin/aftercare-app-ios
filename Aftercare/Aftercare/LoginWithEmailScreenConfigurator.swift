//
//  LoginScreenConfigurator.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/22/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation

class LoginWithEmailScreenConfigurator {
    
    //MARK: - Singleton
    
    static let shared: LoginWithEmailScreenConfigurator = LoginWithEmailScreenConfigurator()
    private init() { }
    
    //MARK: - Public
    
    func configure(viewController: LoginWithEmailScreenViewController) {
        
        let router = LoginWithEmailScreenRouter(viewController: viewController)
        let presenter = LoginWithEmailScreenPresenter(output: viewController)
        let coordinator = LoginWithEmailScreenCoordinator(output: presenter)
        
        viewController.output = coordinator
        viewController.router = router
    }
}
