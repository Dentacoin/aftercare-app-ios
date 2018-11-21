//
//  APIRouter.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/25/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Alamofire

struct APIRouter: APIRouterProtocol {
    
    static var basePath: String {
        get {
            guard let apiURL = SystemMethods.Environment.value(forKey: .EnvironmentAPIURL) else { return "" }
            return "https://" + apiURL
        }
    }
    
    typealias EmptyType = Dictionary<String, String>
    
    struct LoginWithEmail: Creatable {
        typealias EParameters = EmailRequestData
        var route: String = "login"
    }

    struct LoginWithFacebook: Creatable {
        typealias EParameters = FacebookRequestData
        var route: String = "login"
    }

    struct LoginWithTwitter: Creatable {
        typealias EParameters = TwitterRequestData
        var route: String = "login"
    }

    struct LoginWithGoogle: Creatable {
        typealias EParameters = GoogleRequestData
        var route: String = "login"
    }
    
    struct LoginWithCivic: Creatable {
        typealias EParameters = CivicRequestData
        var route: String = "login"
    }
    
    struct SignUpWithEmail: Creatable {
        typealias EParameters = EmailRequestData
        var route: String = "userreg"
    }

    struct SignUpWithFacebook: Creatable {
        typealias EParameters = FacebookRequestData
        var route: String = "userreg"
    }

    struct SignUpWithTwitter: Creatable {
        typealias EParameters = TwitterRequestData
        var route: String = "userreg"
    }

    struct SignUpWithGoogle: Creatable {
        typealias EParameters = GoogleRequestData
        var route: String = "userreg"
    }
    
    struct SignUpWithCivic: Creatable {
        typealias EParameters = CivicRequestData
        var route: String = "userreg"
    }
    
    struct Logout: Readable {
        typealias EParameters = EmptyType
        var route: String = "logout"
    }
    
    struct GetUser: Readable {
        typealias EParameters = EmptyType
        var route: String = "user"
    }
    
    struct GetGoals: Readable {
        typealias EParameters = EmptyType
        var route: String = "goals"
    }
    
    struct UploadAvatar: Creatable {
        typealias EParameters = EmptyType
        var route: String = "upload_avatar"
    }
    
    struct RecordRoutine: Creatable {
        typealias EParameters = RoutineData
        var route: String = "journey/routines"
    }
    
    struct RequestRoutines: Readable {
        typealias EParameters = [RoutineData]
        var route: String = "journey/routines"
    }
    
    struct RequestJourney: Readable {
        typealias EParameters = JourneyData
        var route: String = "journey"
    }
    
    struct RequestActionData: Readable {
        typealias EParameters = [ActionScreenData]
        var route: String = "dashboard"
    }
    
    struct ResetPassword: Creatable {
        typealias EParameters = ResetPasswordData
        var route: String = "reset"
    }
    
    struct UpdateUser: Creatable {
        typealias EParameters = UpdateUserRequestData
        var route: String = "user"
    }
    
    struct EmailConfirmation: Readable {
        typealias EParameters = EmptyType
        var route: String = "confirm"
    }
    
    struct DeleteUser: Creatable {
        typealias EParameters = DeleteUserRequest
        var route: String = "user/delete"
    }
    
    struct RequestOralHealth: Readable {
        typealias EParameters = EmptyType
        var route: String = "oralhealth"
    }
    
    struct Transaction: Creatable {
        typealias EParameters = TransactionData
        var route: String = "transactions"
    }
    
    struct Transactions: Readable {
        typealias EParameters = EmptyType
        var route: String = "transactions"
    }
    
    struct RequestCaptcha: Readable {
        typealias EParameters = CaptchaData
        var route = "captcha"
    }
}
