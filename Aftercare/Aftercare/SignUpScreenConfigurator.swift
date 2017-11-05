//
//  SignUpScreenConfigurator.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/22/17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import Foundation

class SignUpScreenConfigurator {
    
    //MARK: - Singleton
    
    static let shared: SignUpScreenConfigurator = SignUpScreenConfigurator()
    private init() {}
    
    //MARK: - Public
    
    func configure(viewController: SignUpScreenViewController) {
        
        let router = SignUpScreenRouter(viewController: viewController)
        let presenter = SignUpScreenPresenter(output: viewController)
        let coordinator = SignUpScreenCoordinator(output: presenter)
        
        viewController.output = coordinator
        viewController.router = router
    }
}
