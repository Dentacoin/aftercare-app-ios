//
// Aftercare
// Created by Dimitar Grudev on 16.10.18.
// Copyright © 2018 Stichting Administratiekantoor Dentacoin.
//

import UIKit
import CivicConnect

class CivicProvider: NSObject {
    
    static let shared = CivicProvider()
    
    public var interface: Connect!
    
    private var callback: LoginRequestResult?
    private var loginType: ScopeRequestType?
    
    override private init() {
        super.init()
    }
    
}

extension CivicProvider: CivicProviderProtocol {
    
    func initialize() {
        if  let civicAppId = SystemMethods.Environment.value(forKey: .CivicApplicationIdentifier),
            let bundleId = SystemMethods.AppInfoPlist.value(forKey: .CFBundleIdentifier),
            let civicSecret = SystemMethods.Environment.value(forKey: .CivicSecret),
            let civicRedirectScheme = SystemMethods.BundleUrlTypes.value(for: .civic)
        {
            interface = Connect.init(
                applicationIdentifier: civicAppId,
                mobileApplicationIdentifier: bundleId,
                secret: civicSecret,
                redirectScheme: civicRedirectScheme
            )
        }
    }
    
    func requestAuthentication(from controller: UIViewController, completionHandler: @escaping LoginRequestResult) {
        requestAuthentication(from: controller, loginType: .basicSignup, completionHandler: completionHandler)
    }
    
    func requestAuthentication(from controller: UIViewController, loginType type: ScopeRequestType, completionHandler: @escaping LoginRequestResult) {
        loginType = type
        callback = completionHandler
        interface.connect(withType: type, delegate: self)
    }
    
}

extension CivicProvider: ConnectDelegate {

    func connectDidFinishWithUserData(_ userData: CivicConnect.UserData) {
        
        let response = CivicRequestData(id: userData.userId, email: nil)
        response.consent = true
        
        if self.loginType == .basicSignup {
            guard let email = getValueFrom(userData: userData.data, forKey: .email) else {
                return assertionFailure("Civic Provider Error: Missing user email data")
            }
            response.email = email
        } else if self.loginType != .anonymousLogin {
            assertionFailure("Civic Provider Error: Unsupported login type by the app")
        }
        callback?(response, nil)
    }

    func connectDidFailWithError(_ error: ConnectError) {
        let errorData = ErrorData(code: error.statusCode, error: error.message)
        callback?(nil, errorData)
    }

    func connectDidChangeStatus(_ newStatus: ConnectStatus) {
        print("Civic SDK :: newStatus \(newStatus)")
    }

}

// MARK: - Helper methods

fileprivate extension CivicProvider {
    
    func getValueFrom(userData data: [CivicConnect.UserInfo], forKey key: CivicUserInfoKey) -> String? {
        let validItems = data.map() { (item: CivicConnect.UserInfo) -> CivicConnect.UserInfo? in
            if item.label == key.rawValue {
                return item
            }
            return nil
        }.compactMap { $0 }
        return validItems.first?.value
    }
    
}

fileprivate enum CivicUserInfoKey: String {
    case email = "contact.personal.email"
    case phone = "contact.personal.phoneNumber"
}

fileprivate extension ErrorData {
    init(code: Int, error: String) {
        self.code = code
        self.errors = [error]
    }
}
