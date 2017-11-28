//
//  APIProviderProtocols.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/25/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

protocol APIProviderProtocol {
    
    static func login(
        withEmail params: EmailRequestData,
        onComplete: @escaping AuthenticationResult
    )
    
    static func loginWithSocialNetwork(
        params: AuthenticationRequestProtocol,
        onComplete: @escaping AuthenticationResult
    )
    
    static func signUp(
        withEmail params: EmailRequestData,
        onComplete: @escaping AuthenticationResult
    )
    
    static func signUpWithSocial(
        params: AuthenticationRequestProtocol,
        onComplete: @escaping AuthenticationResult
    )
    
    static func logout() -> Void
    
    static func recordActions(
        _ records: [ActionRecordData],
        onComplete: @escaping (_ processedAction: [ActionsResponseList]?, _ error: ErrorData?) -> Void
    )
    
    static func retreiveOralHealthData(
        _ onComplete: @escaping (_ result: [OralHealthData]?, _ error: ErrorData?) -> Void
    ) -> Void
    
    static func retreiveUserInfo(
        onComplete: @escaping (_ userInfo: UserData?, _ error: ErrorData?) -> Void
    )
    
    static func updateUser(
        _ userData: UpdateUserRequestData,
        onComplete: @escaping (_ userData: UserData?, _ errorData: ErrorData?) -> Void
    )
    
    static func recordAction(
        record: ActionRecordData,
        onComplete: @escaping (_ processedAction: ActionRecordData?, _ error: ErrorData?) -> Void
    )
    
    static func retreiveUserGoals(
        onComplete: @escaping (_ response: [GoalData]?, _ error: ErrorData?) -> Void
    )
    
    static func requestResetPassword(
        email: String
    )
    
    static func loadUserAvatar(
        _ path: String,
        onComplete: @escaping (_ response: UIImage?, _ error: ErrorData?) -> Void
    )
    
    static func requestCollectionOfDCN(
        _ params: TransactionData,
        onComplete: @escaping (_ transactions: [TransactionData]?, _ error: ErrorData?
        ) -> Void)
}

typealias AuthenticationResult = (_ result: UserSessionData?, _ error: ErrorData?) -> Void
typealias LoginRequestResult = (_ result: AuthenticationRequestProtocol?, _ error: ErrorData?) -> Void

protocol DataProviderSerializedType {
    associatedtype EParameters = Encodable
}

protocol UserDataProviderProtocol {
    var email: String? { get }
    var firstName: String? { get }
    var lastName: String? { get }
    var avatarURL: String? { get }
    var gender: String? { get }
    var isLoggedIn: Bool { get }
    func logout()
}

protocol EmailProviderProtocol {}

protocol SocialLoginProviderProtocol {
    func requestAuthentication(
        from controller: UIViewController,
        completionHandler: @escaping LoginRequestResult
    )
}

protocol FacebookProviderProtocol: SocialLoginProviderProtocol {}
protocol TwitterProviderProtocol: SocialLoginProviderProtocol {}
protocol GooglePlusProviderProtocol: SocialLoginProviderProtocol {}
