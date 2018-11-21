//
// Aftercare
// Created by Dimitar Grudev on 9.10.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
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
