//
//  LoginScreenConfigurator.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/22/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation

class LoginScreenConfigurator {
    
    //MARK: - Singleton
    
    static let shared: LoginScreenConfigurator = LoginScreenConfigurator()
    private init() { }
    
    //MARK: - Public
    
    func configure(viewController: LoginScreenViewController) {
        
        let router = LoginScreenRouter(viewController: viewController)
        let presenter = LoginScreenPresenter(output: viewController)
        let coordinator = LoginScreenCoordinator(output: presenter)
        
        viewController.output = coordinator
        viewController.router = router
    }
}
