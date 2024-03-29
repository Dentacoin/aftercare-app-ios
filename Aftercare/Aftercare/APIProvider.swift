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
                case .failure(let error):
                    let nserror = error as NSError
                    errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
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
        }else if let param = params as? AppleRequestData {
            urlRequest = APIRouter.SignUpWithApple.post(parameters: param)
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
                case .failure(let error):
                    let nserror = error as NSError
                    errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
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
                case .failure(let error):
                    let nserror = error as NSError
                    errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
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
        }else if let param = params as? AppleRequestData {
            urlRequest = APIRouter.LoginWithApple.post(parameters: param)
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
                case .failure(let error):
                    let nserror = error as NSError
                    errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
            }
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(nil, error)
            } else if let error = errorData {
                onComplete(nil, error)
            }
        }
    }
    
    //TODO: rename this method to requestActionScreenData
    static func requestActionData(_ onComplete: @escaping (_ response: ActionScreenData?, _ error: ErrorData?) -> Void) {
        let urlRequest = APIRouter.RequestActionData.get()
        var errorData: ErrorData?
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<ActionScreenData>) in
            switch response.result {
            case .success(let data):
                onComplete(data, nil)
            case .failure(let error):
                let nserror = error as NSError
                errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
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
            case .failure(let error):
                let nserror = error as NSError
                errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
            }
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(nil, error)
            } else if let error = errorData {
                onComplete(nil, error)
            }
        }
    }
    
    // MARK: - Retrieve the current journey | GET /journey
    
    static func retreiveCurrentJourney(
        onComplete: @escaping (_ journey: JourneyData?, _ error: ErrorData?) -> Void
        ) {
        
        var errorData: ErrorData?
        let urlRequest = APIRouter.RequestJourney.get()
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<JourneyData>) in
            switch response.result {
            case .success(let journey):
                onComplete(journey, nil)
            case .failure(let error):
                let nserror = error as NSError
                errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
            }
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(nil, error)
            } else if let error = errorData {
                onComplete(nil, error)
            }
        }
    }
    
    // MARK: - Adding routine record to a journey | POST /journey/routine
    // This starts new journey if there is no active one at the time.
    
    static func recordRoutine(
        _ routine: RoutineData,
        onComplete: @escaping (_ routine: RoutineData?, _ error: ErrorData?) -> Void
        ) {
        
        var errorData: ErrorData?
        let urlRequest = APIRouter.RecordRoutine.post(parameters: routine)
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<RoutineData>) in
            switch response.result {
            case .success(let routine):
                onComplete(routine, nil)
            case .failure(let error):
                let nserror = error as NSError
                errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
            }
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(nil, error)
            } else if let error = errorData {
                onComplete(nil, error)
            }
        }
    }
    
    // MARK: - Retrieving recorded routines for the journey | GET /journey/routines
    
    static func retreiveRecordRoutines(
        onComplete: @escaping (_ routine: [RoutineData]?, _ error: ErrorData?) -> Void
        ) {
        
        var errorData: ErrorData?
        let urlRequest = APIRouter.RequestRoutines.get()
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<[RoutineData]>) in
            switch response.result {
            case .success(let routines):
                onComplete(routines, nil)
            case .failure(let error):
                let nserror = error as NSError
                errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
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
                case .failure(let error):
                    let nserror = error as NSError
                    errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
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
            case .failure(let error):
                let nserror = error as NSError
                errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
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
            case .failure(let error):
                let nserror = error as NSError
                errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
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
                case .failure(let error):
                    let nserror = error as NSError
                    errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
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
        onComplete: @escaping (_ transactions: [TransactionData]?, _ error: ErrorData?) -> Void)
    {
        
        var errorData: ErrorData?
        let urlRequest = APIRouter.Transaction.post(parameters: params)
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<[TransactionData]>) in
            switch response.result {
            case .success(let history):
                onComplete(history, nil)
            case .failure(let error):
                let nserror = error as NSError
                errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
            }
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(nil, error)
            } else if let error = errorData {
                onComplete(nil, error)
            }
        }
    }
    
    static func getAllTransactions(
        _ onComplete: @escaping (_ transactions: [TransactionData]?, _ error: ErrorData?) -> Void
        ) {
        
        var errorData: ErrorData?
        let urlRequest = APIRouter.Transactions.get()
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<[TransactionData]>) in
            switch response.result {
                case .success(let history):
                    onComplete(history, nil)
                case .failure(let error):
                    let nserror = error as NSError
                    errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
            }
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(nil, error)
            } else if let error = errorData {
                onComplete(nil, error)
            }
        }
    }
    
    static func requestEmailConfirmation (
        _ onComplete: @escaping (_ confirmationResent: Bool, _ error: ErrorData?) -> Void
        ) {

        var errorData: ErrorData?
        let urlRequest = APIRouter.EmailConfirmation.get()
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<SuccessResponse>) in
            switch response.result {
            case .success(let success):
                // Code still can be == 400 is too many verification request are sent by the user
                // so we double check for the code to be == 200
                if success.code == 200 {
                    onComplete(true, nil)
                }
            case .failure(let error):
                let nserror = error as NSError
                errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
            }
        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
            if let error = response.result.value {
                onComplete(false, error)
            } else if let error = errorData {
                onComplete(false, error)
            }
        }
    }
    
    static func requestDeleteUser(
        _ params: DeleteUserRequest,
        _ onComplete: @escaping (_ deleted: Bool, _ error: ErrorData?
    ) -> Void) {
        
        let urlRequest = APIRouter.DeleteUser.post(parameters: params)
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<ErrorData>) in
            
            let response = response.result.value
            if response?.code == 200 {
                onComplete(true, nil)
            } else {
                onComplete(false, response)
            }
        }
    }
    
    static func requestCaptcha(_ onComplete: @escaping (CaptchaData?, ErrorData?) -> Void) {
        var errorData: ErrorData?
        let urlRequest = APIRouter.RequestCaptcha.get()
        Alamofire.request(urlRequest).responseDecodableObject() { (response: DataResponse<CaptchaData>) in
            switch response.result {
                case .success(let captcha):
                    onComplete(captcha, nil)
                case .failure(let error):
                    let nserror = error as NSError
                    errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
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
//            case .failure(let error):
//                let nserror = error as NSError
//                let errorData = ErrorData(code: nserror.code, errors: [nserror.localizedDescription])
//                onComplete(nil, errorData)
//            }
//        }.responseDecodableObject() { (response: DataResponse<ErrorData>) in
//            if let error = response.result.value {
//                onComplete(nil, error)
//            }
//        }
//    }
    
}
