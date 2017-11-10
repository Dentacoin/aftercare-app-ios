//
//  APIRouterProtocols.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/25/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Alamofire
import UserNotifications
import Firebase

protocol APIRouterProtocol {
    
}

protocol URLRouter {
    static var basePath: String { get }
}

protocol Routable {
    associatedtype EParameters: Encodable
    var route: String {get set}
    init()
}

protocol Readable: Routable {}

protocol Creatable: Routable {}

protocol Updatable: Routable {}

protocol Deletable: Routable {}

protocol Uploadable: Routable {}

//Default implementations of protocols

extension Routable {
    // Create instance of Object that conforms to Routable
    init() {
        self.init()
    }
}

extension Readable {
    static func get() -> RequestConverter<EParameters> {
        let temp = Self.init()
        let route = "\(temp.route)"
        return RequestConverter(method: .get, route: route)
    }
}

extension Creatable {
    static func post(parameters: EParameters?) -> RequestConverter<EParameters> {
        let temp = Self.init()
        let route = "\(temp.route)"
        return RequestConverter(method: .post, route: route, parameters: parameters)
    }
}

extension Updatable {
    static func put(urlParameters: String, parameters: EParameters?) -> RequestConverter<EParameters> {
        let temp = Self.init()
        let route = "\(temp.route)/\(urlParameters)"
        return RequestConverter(method: .put, route: route, parameters: parameters)
    }
}

extension Deletable {
    static func delete(urlParameters: String) -> RequestConverter<EParameters> {
        let temp = Self.init()
        let route = "\(temp.route)/\(urlParameters)"
        return RequestConverter(method: .delete, route: route)
    }
}

extension Uploadable {
    static func upload(data: Data) -> RequestConverter<EParameters> {
        let temp = Self.init()
        let route = "\(temp.route)"
        return RequestConverter(method: .get, route: route)
    }
    
}

//Convertable

protocol RequestConverterProtocol: URLRequestConvertible {
    associatedtype EParameters: Encodable
    var method: HTTPMethod {get set}
    var route: String {get set}
    var parameters: EParameters? {get set}
}

struct RequestConverter<T: Encodable>: RequestConverterProtocol {
    
    var method: HTTPMethod
    var route: String
    var parameters: T?
    
    init(method: HTTPMethod, route: String, parameters: EParameters? = nil) {
        self.method = method
        self.route = route
        self.parameters = parameters
    }
    
    func asURLRequest() throws -> URLRequest {
        
        let url = try APIRouter.basePath.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(route))
        urlRequest.httpMethod = method.rawValue
        
        var header: [String : String] = urlRequest.allHTTPHeaderFields ?? [:]
        
        if method != HTTPMethod.get {
            header.updateValue("application/json", forKey: "Content-Type")
            header.updateValue("application/json", forKey: "Accept")
        }
        
        if let token = UserDataContainer.shared.sessionToken {
            header.updateValue("Bearer " + token, forKey: "Authorization")
            if let tokenData = Messaging.messaging().fcmToken {
                //print("PUSH NOTIFICATIONS FIREBASE TOKEN: \(tokenData)")
                header.updateValue(tokenData, forKey: "FirebaseToken")
            }
        }
        
        urlRequest.allHTTPHeaderFields = header
        
        if method != HTTPMethod.get {
            let encoder = JSONEncoder()
            do {
                let encoded = try encoder.encode(self.parameters)
                urlRequest.httpBody = encoded
            } catch {
                print("Critical Error: Trying to encode data")
            }
        }
        
        return urlRequest
        
    }
}
