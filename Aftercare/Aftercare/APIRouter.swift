//
//  APIRouter.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/25/17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import Alamofire

struct APIRouter: APIRouterProtocol {
    
    static var basePath: String {
        get {
            guard let apiProtocol = SystemMethods.Environment.value(forKey: .EnvironmentAPIProtocol) else { return "" }
            guard let apiURL = SystemMethods.Environment.value(forKey: .EnvironmentAPIURL) else { return "" }
            return apiProtocol + "://" + apiURL
        }
    }
    
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
        //typealias EParameters = UserDataProviderProtocol.EParameters
        var route: String = "userreg"
    }
    
    struct Logout: Readable {
        typealias EParameters = Dictionary<String, String>
        var route: String = "logout"
    }
    
    struct GetUser: Readable {
        typealias EParameters = Dictionary<String, String>
        var route: String = "user"
    }
    
    struct GetGoals: Readable {
        typealias EParameters = Dictionary<String, String>
        var route: String = "goals"
    }
    
    struct UploadAvatar: Creatable {
        typealias EParameters = Dictionary<String, Any>
        var route: String = "upload_avatar"
    }
    
    struct RecordAction: Creatable {
        typealias EParameters = ActionRecordData
        var route: String = "records"
    }
    
    struct RecordActions: Creatable {
        typealias EParameters = [ActionRecordData]
        var route: String = "multiple-records"
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
    
    struct RequestOralHealth: Readable {
        typealias EParameters = Dictionary<String, String>
        var route: String = "oralhealth"
    }
    
    struct Transaction: Creatable {
        typealias EParameters = TransactionData
        var route: String = "transactions"
    }
}
