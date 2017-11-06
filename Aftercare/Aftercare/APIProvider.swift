//
//  APIProvider.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/25/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import Alamofire
import CodableAlamofire

struct APIProvider : APIProviderProtocol {
    
    //MARK: - fileprivates
    
    static fileprivate var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    //MARK: - public API
    
    static func signUp(
        withEmail params: EmailRequestData,
        onComplete: @escaping AuthenticationResult
        ) {
        
        var errorData: ErrorData?
        let urlRequest = APIRouter.SignUpWithEmail.post(parameters: params)
        
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<UserSessionData>) in
            switch response.result {
                case .success(let userSession):
                    onComplete(userSession, nil)
                break
                case .failure(let error):
                    let nserror = error as NSError
                    errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
                break
            }
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(nil, error)
            } else if let error = errorData {
                onComplete(nil, error)
            }
        }
    }
    
    static func signUpWithSocial(
        params: AuthenticationRequestProtocol,
        onComplete: @escaping AuthenticationResult
        ) {
        
        var errorData: ErrorData?
        var urlRequest: URLRequestConvertible?
        
        if let param = params as? FacebookRequestData {
            urlRequest = APIRouter.SignUpWithFacebook.post(parameters: param)
        } else if let param = params as? TwitterRequestData {
            urlRequest = APIRouter.SignUpWithTwitter.post(parameters: param)
        } else if let param = params as? GoogleRequestData {
            urlRequest = APIRouter.SignUpWithGoogle.post(parameters: param)
        }
        
        guard let request = urlRequest else {
            return
        }
        
        Alamofire.request(request).responseDecodableObject() { (response: DataResponse<UserSessionData>) in
            //print("success response: \(response)")
            switch response.result {
                case .success(let userSession):
                    onComplete(userSession, nil)
                break
                case .failure(let error):
                    let nserror = error as NSError
                    errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
                break
            }
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(nil, error)
            } else if let error = errorData {
                onComplete(nil, error)
            }
        }
    }
    
    static func login(
        withEmail params: EmailRequestData,
        onComplete: @escaping AuthenticationResult
        ) {
        var errorData: ErrorData?
        let urlRequest = APIRouter.LoginWithEmail.post(parameters: params)
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<UserSessionData>) in
            switch response.result {
                case .success(let userSession):
                    onComplete(userSession, nil)
                break
                case .failure(let error):
                    let nserror = error as NSError
                    errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
                break
            }
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(nil, error)
            } else if let error = errorData {
                onComplete(nil, error)
            }
        }
    }
    
    static func loginWithSocialNetwork(
        params: AuthenticationRequestProtocol,
        onComplete: @escaping AuthenticationResult
        ) {
        
        var errorData: ErrorData?
        var urlRequest: URLRequestConvertible?
        
        if let param = params as? FacebookRequestData {
            urlRequest = APIRouter.LoginWithFacebook.post(parameters: param)
        } else if let param = params as? TwitterRequestData {
            urlRequest = APIRouter.LoginWithTwitter.post(parameters: param)
        } else if let param = params as? GoogleRequestData {
            urlRequest = APIRouter.LoginWithGoogle.post(parameters: param)
        }
        
        guard let request = urlRequest else { return }

        Alamofire.request(request).responseDecodableObject() { (response: DataResponse<UserSessionData>) in
            switch response.result {
                case .success(let session):
                    onComplete(session, nil)
                break
                case .failure(let error):
                    let nserror = error as NSError
                    errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
                break
            }
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(nil, error)
            } else if let error = errorData {
                onComplete(nil, error)
            }
        }
    }
    
    static func requestActionData(_ onComplete: @escaping (_ response: ActionScreenData?, _ error: ErrorData?) -> Void) {
        let urlRequest = APIRouter.RequestActionData.get()
        var errorData: ErrorData?
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<ActionScreenData>) in
            switch response.result {
            case .success(let data):
                onComplete(data, nil)
                break
            case .failure(let error):
                let nserror = error as NSError
                errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
                break
            }
            
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(nil, error)
            } else if let error = errorData {
                onComplete(nil, error)
            }
        }
    }
    
    static func logout() {
        if  UserDataContainer.shared.hasValidSession == true {
            let urlRequest = APIRouter.Logout.get()
            Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<ErrorData>) in
                switch response.result {
                case .success(let value):
                    print("logout() :: successful logout \(value)")
                    break
                case .failure(let error):
                    print("logout() :: response error: \(String(describing: error))")
                }
            }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
                if let error = response.result.value {
                    print("logout() :: error: \(error)")
                }
            }
        }
    }
    
    static func updateUser(_ userData: UpdateUserRequestData, onComplete: @escaping (_ userData: UserData?, _ errorData: ErrorData?) -> Void) {
        var errorData: ErrorData?
        let urlRequest = APIRouter.UpdateUser.post(parameters: userData)
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<UserData>) in
            switch response.result {
            case .success(let action):
                onComplete(action, nil)
                break
            case .failure(let error):
                let nserror = error as NSError
                errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
                break
            }
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(nil, error)
            } else if let error = errorData {
                onComplete(nil, error)
            }
        }
    }
    
    static func recordAction(record: ActionRecordData, onComplete: @escaping (_ processedAction: ActionData?, _ error: ErrorData?) -> Void) {
        var errorData: ErrorData?
        let urlRequest = APIRouter.RecordAction.post(parameters: record)
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<ActionData>) in
            switch response.result {
                case .success(let action):
                    onComplete(action, nil)
                break
                case .failure(let error):
                    let nserror = error as NSError
                    errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
                break
            }
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(nil, error)
            } else if let error = errorData {
                onComplete(nil, error)
            }
        }
    }
    
    static func recordActions(_ records: [ActionRecordData], onComplete: @escaping (_ processedAction: [ActionsResponseList]?, _ error: ErrorData?) -> Void) {
        var errorData: ErrorData?
        let urlRequest = APIRouter.RecordActions.post(parameters: records)
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<[ActionsResponseList]>) in
            switch response.result {
            case .success(let action):
                onComplete(action, nil)
                break
            case .failure(let error):
                let nserror = error as NSError
                errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
                break
            }
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(nil, error)
            } else if let error = errorData {
                onComplete(nil, error)
            }
        }
    }
    
    static func retreiveOralHealthData(_ onComplete: @escaping (_ result: [OralHealthData]?, _ error: ErrorData?) -> Void) -> Void {
        var errorData: ErrorData?
        let urlRequest = APIRouter.RequestOralHealth.get()
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<[OralHealthData]>) in
            switch response.result {
                case .success(let oralHealthArray):
                    onComplete(oralHealthArray, nil)
                break
                case .failure(let error):
                    let nserror = error as NSError
                    errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
                break
            }
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(nil, error)
            } else if let error = errorData {
                onComplete(nil, error)
            }
        }
    }
    
    static func retreiveUserInfo(onComplete: @escaping (_ userInfo: UserData?, _ error: ErrorData?) -> Void) -> Void {
        var errorData: ErrorData?
        let urlRequest = APIRouter.GetUser.get()
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<UserData>) in
            switch response.result {
            case .success(let userData):
                onComplete(userData, nil)
                break
            case .failure(let error):
                let nserror = error as NSError
                errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
                break
            }
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(nil, error)
            } else if let error = errorData {
                onComplete(nil, error)
            }
        }
    }
    
    static func retreiveUserGoals(
        onComplete: @escaping (
            _ response: [GoalData]?,
            _ error: ErrorData?) -> Void
        ) {
        
        var errorData: ErrorData?
        let urlRequest = APIRouter.GetGoals.get()
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<[GoalData]>) in
            switch response.result {
            case .success(let userGoals):
                onComplete(userGoals, nil)
                break
            case .failure(let error):
                let nserror = error as NSError
                errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
                break
            }
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(nil, error)
            } else if let error = errorData {
                onComplete(nil, error)
            }
        }
    }
    
    static func requestResetPassword(email: String) {
        let requestData = ResetPasswordData(email: email)
        let urlRequest = APIRouter.ResetPassword.post(parameters: requestData)
        Alamofire.request(urlRequest).responseString() { (response: DataResponse<String>) in
            //print("Reset Password request Response: \(String(describing: response.result.value))")
        }
    }
    
    static func loadUserAvatar(_ path: String, onComplete: @escaping (_ response: UIImage?, _ error: ErrorData?) -> Void) {
        var errorData: ErrorData?
        if let url = URL(string: path) {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = HTTPMethod.get.rawValue
            Alamofire.request(urlRequest).responseImage() { response in
            switch response.result {
                case .success(let image):
                    onComplete(image, nil)
                    break
                case .failure(let error):
                    let nserror = error as NSError
                    errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
                    break
                }
            }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
                if let error = response.result.value {
                    onComplete(nil, error)
                } else if let error = errorData {
                    onComplete(nil, error)
                }
            }
        }
    }
    
    static func requestCollectionOfDCN(
        _ params: TransactionData,
        onComplete: @escaping (_ transactions: [TransactionData]?, _ error: ErrorData?
    ) -> Void) {
        
        var errorData: ErrorData?
        let urlRequest = APIRouter.Transaction.post(parameters: params)
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<[TransactionData]>) in
            switch response.result {
            case .success(let history):
                onComplete(history, nil)
                break
            case .failure(let error):
                let nserror = error as NSError
                errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
                break
            }
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(nil, error)
            } else if let error = errorData {
                onComplete(nil, error)
            }
        }
    }
    
    //MARK: Internal methods
    
//    internal func makeRequest<T>(request: RequestConverter<T>, responseType: Y) {
//        Alamofire.request(request).responseDecodableObject() { (response: DataResponse<Y>) in
//            switch response.result {
//            case .success(let result):
//                onComplete(result, nil)
//                break
//            case .failure(let error):
//                let nserror = error as NSError
//                let errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
//                onComplete(nil, errorData)
//                break
//            }
//        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
//            if let error = response.result.value {
//                onComplete(nil, error)
//            }
//        }
//    }
    
}
