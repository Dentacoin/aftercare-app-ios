//
//  GooglePlusProvider.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/29/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class GooglePlusProvider: NSObject {
    
    static let shared = GooglePlusProvider()//singleton instance
    
    //MARK: - fileprivate constants
    
    fileprivate let defaults = UserDefaults.standard
    
    //MARK: - fileprivate vars
    
    fileprivate var loggedIn = false
    fileprivate var controller: UIViewController?
    fileprivate var completion: LoginRequestResult?
    fileprivate var googleSignInViewController: UIViewController?
    
    //singleton constructor
    override private init() {
        
        super.init()
        
        GIDSignIn.sharedInstance().uiDelegate = self//important! don't forget to add the uiDelegate too
        GIDSignIn.sharedInstance().delegate = self
    }
    
}

//MARK: - GooglePlusProviderProtocol

extension GooglePlusProvider: GooglePlusProviderProtocol {
    
    //MARK: - Public methods
    
    func requestAuthentication(from controller: UIViewController, completionHandler: @escaping LoginRequestResult) {
        
        GIDSignIn.sharedInstance().signIn()
        
        self.controller = controller
        self.completion = completionHandler
    }
    
}

extension GooglePlusProvider: DataProviderSerializedType {
    typealias EParameters = GoogleRequestData
}

//MARK: - UserDataProviderProtocol

extension GooglePlusProvider: UserDataProviderProtocol {
    
    //MARK: - public properties
    
    var email: String? {
        get {
            if let emailAddress = defaults.value(forKey: GoogleDefaultsKeys.Email.rawValue) as? String {
                return emailAddress
            }
            return nil
        }
    }
    
    var firstName: String? {
        get {
            if let name = defaults.value(forKey: GoogleDefaultsKeys.FirstName.rawValue) as? String {
                return name
            }
            return nil
        }
    }
    
    var lastName: String? {
        get {
            if let name = defaults.value(forKey: GoogleDefaultsKeys.LastName.rawValue) as? String {
                return name
            }
            return nil
        }
    }
    
    var avatarURL: String? {
        get {
            if let url = defaults.value(forKey: GoogleDefaultsKeys.Avatar.rawValue) as? String {
                return url
            }
            return nil
        }
    }
    
    var gender: String? {
        get {
            if let gend = defaults.value(forKey: GoogleDefaultsKeys.Gender.rawValue) as? String {
                return gend
            }
            return nil
        }
    }
    
    var isLoggedIn: Bool {
        get {
            return loggedIn
        }
    }
    
    var userID: String? {
        get {
            if let id = defaults.value(forKey: GoogleDefaultsKeys.UserID.rawValue) as? String {
                return id
            }
            return nil
        }
    }
    
    var token: String? {
        get {
            if let token = defaults.value(forKey: GoogleDefaultsKeys.Token.rawValue) as? String {
                return token
            }
            return nil
        }
    }
    
    //MARK: - Public methods
    
    func logout() {
        loggedIn = false
    }
    
}

//MARK: - GoogleSignIn and Firebase methods

extension GooglePlusProvider: GIDSignInUIDelegate {
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        if let vc = self.controller {
            vc.present(viewController, animated: true, completion: nil)
            self.googleSignInViewController = viewController
        }
        print("GooglePlusProvider :: present")
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        //if let completionHandler = self.completion {
            //let sessionData: [String : String] = [GoogleDefaultsKeys.Canceled.rawValue : true]
            //completionHandler(sessionData)
        //}
        print("GooglePlusProvider :: google VC dismissed")
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        if error != nil {
            print("GooglePlusProvider :: google sign-in with error: \(error)")
        }
    }
    
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        logout()
    }
    
}

extension GooglePlusProvider: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error as NSError? {
            if let completion = self.completion {
                let errorData = ErrorData(code: error.code, errors: [error.localizedDescription])
                completion(nil, errorData)
                print("GooglePlusProvider :: google did fail to sign-in with error: \(error)")
            }
            return
        }
        
        print("GooglePlusProvider :: google did sign-in")
        
        guard let authentication = user.authentication else { return }
        guard let clientID = user?.userID else { return }
        
        let sessionRequestData = GoogleRequestData(
            email: "",
            id: clientID,
            token: authentication.accessToken
        )
        
        //save locally
        //GoogleDefaultsKeys.TokenValidTo.rawValue : authentication.authentication.accessTokenExpirationDate,
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: authentication.idToken,
            accessToken: authentication.accessToken
        )
        
        Auth.auth().signIn(with: credential) { [weak self] (user, error) in
            if let error = error as NSError? {
                if let completion = self?.completion {
                    let errorData = ErrorData(code: error.code, errors: [error.localizedDescription])
                    completion(nil, errorData)
                    print("GooglePlusProvider :: google user failed to authenticate :: error: \(error)")
                }
                return
            }
            
            if let user = user {
                
                //User successfully authenticated
                print("GooglePlusProvider :: google user successfully authenticated")
                
                if let avatar = user.photoURL {
                    self?.defaults.set(avatar, forKey: GoogleDefaultsKeys.Avatar.rawValue)
                }
                if let fullName = user.displayName {
                    
                    var fullNameArr = fullName.components(separatedBy: " ")
                    self?.defaults.set(fullNameArr[0], forKey: GoogleDefaultsKeys.FirstName.rawValue)
                    
                    if fullNameArr.count > 1 {
                        self?.defaults.set(fullNameArr[1], forKey: GoogleDefaultsKeys.LastName.rawValue)
                    }
                    
                }
                if let email = user.email {
                    sessionRequestData.email = email
                }
                
                user.getIDTokenForcingRefresh(true, completion: { [weak self] (token, error) in
                    if let error = error {
                        print("GooglePlusProvider :: Error: Failed to retreive new token \(error)")
                        return
                    }
                    guard let token = token else {
                        return
                    }
                    sessionRequestData.googleAccessToken = token
                    
                    self?.defaults.synchronize()
                    if let completion = self?.completion {
                        completion(sessionRequestData, nil)
                    }
                })
                
            }
            
            self?.googleSignInViewController?.removeFromParentViewController()
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        GIDSignIn.sharedInstance().signOut()
        logout()
    }
    
}

fileprivate enum GoogleDefaultsKeys: String {
    case Error = "error"
    case Canceled = "isCanceled"
    case Token = "googleAccessToken"
    case TokenValidTo = "googleTokenValidTo"
    case UserID = "googleID"
    case Email = "goUserEmail"
    case Avatar = "googleUserAvatar"
    case FirstName = "googleUserFirstName"
    case LastName = "googleUserLastName"
    case Gender = "googleUserGender"
}
