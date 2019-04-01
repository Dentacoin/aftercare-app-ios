//
//  SystemMethods.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 8/31/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

enum SystemMethods {
    
    enum User {
        
        static func validateFirstName(_ name: String) -> Bool {
            return validateName(name)
        }
        
        static func validateLastName(_ name: String) -> Bool {
            return validateName(name)
        }
        
        static func validateEmail(_ email: String) -> Bool {
            if email.isEmpty { return false }
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
            let emailTest = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
            return emailTest.evaluate(with: email)
        }
        
        static func validatePhone(_ phone: String) -> Bool {
            if phone.isEmpty { return false }
            if phone.count < 5 { return false }
            return true//TODO: - validate phone data
        }
        
        static func validatePassword(_ password: String) -> Bool {
            return password.count >= 8
        }
        
        static func validateZipCode(_ zip: String) -> Bool {
            return !zip.isEmpty
        }
        
        //MARK: - fileprivates
        
        static fileprivate func validateName(_ name: String) -> Bool  {
            return name.count > 2
        }
        
    }
    
    enum Files {
        
        static let decodeQueue: OperationQueue = {
            let queue = OperationQueue()
            queue.underlyingQueue = DispatchQueue(label: "com.dentacoin.dentacare-app.imageDecoder", attributes: .concurrent)
            queue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
            return queue
        }()
        
        static func retrieveImage(urlString : String, completion: @escaping (UIImage?) -> Void) {
            
            let queue = decodeQueue.underlyingQueue
            let request = Alamofire.request(urlString, method: .get)
            let imageRequest = ImageRequest(request: request)
            let serializer = DataRequest.imageResponseSerializer()
            
            imageRequest.request.response(queue: queue, responseSerializer: serializer) { response in
                guard let image = response.result.value else {
                    completion(nil)//no image
                    return
                }
                imageRequest.decodeOperation = self.decode(image) { image in
                    completion(image)
                }
            }
        }
        
        static func saveImageLocally(image: UIImage, imageId: String) {
            let path = fileInDocumentsDirectory(filename: imageId + ".jpg")
            guard let jpgImageData = image.jpegData(compressionQuality: 1.0) else { return }
            try? jpgImageData.write(to: URL(fileURLWithPath: path))
            UserDefaultsManager.shared.setValue(path, forKey: imageId)
        }
        
        //decode image
        fileprivate static func decode(_ image: UIImage, completion: @escaping (UIImage) -> Void) -> DecodeOperation {
            let operation = DecodeOperation(image: image, completion: completion)
            decodeQueue.addOperation(operation)
            return operation
        }
        
        // Get the documents Directory
        fileprivate static func documentsDirectory() -> String {
            return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        }
        
        // Get path for a file in the directory
        fileprivate static func fileInDocumentsDirectory(filename: String) -> String {
            return documentsDirectory().appending("/" + filename)
        }
        
    }
    
    enum Goals {
        
        static func scanForNewGoals() -> [GoalData]? {
            let DefaultsKeyAchievedGoals = "achievedGoalsList"
            guard let allGoals = UserDataContainer.shared.goalsData else {
                print("SystemMethods.Goals : Can't retreive goalsData")
                return nil
            }
            guard var achievedGoals: [String] = UserDefaultsManager.shared.getValue(forKey: DefaultsKeyAchievedGoals) else {
                print("SystemMethods.Goals :  : no record for achieved goals")
                
                var newGoalsIDs: [String] = []
                //collect all achieved goals IDs in array
                for goal in allGoals {
                    if goal.completed {
                        newGoalsIDs.append(goal.id)
                    }
                }
                
                //save all achieved in Defaults and return all achieved
                if newGoalsIDs.count > 0 {
                    UserDefaultsManager.shared.setValue(newGoalsIDs, forKey: DefaultsKeyAchievedGoals)
                }
                
                return nil
            }
            
            var newlyAchieved: [GoalData] = []
            
            //search for newly achieved goals
            for goal in allGoals {
                if goal.completed {
                    let goalID = goal.id
                    //if this goal is not already saved
                    if !achievedGoals.contains(goalID) {
                        //add new ID to already saved
                        achievedGoals.append(goalID)
                        //add newly achieved goal in separate array to be returned
                        newlyAchieved.append(goal)
                    }
                }
            }
            
            //save all in User Defaults
            if achievedGoals.count > 0 {
                UserDefaultsManager.shared.setValue(achievedGoals, forKey: DefaultsKeyAchievedGoals)
            }
            
            return newlyAchieved
        }
        
    }
    
    enum Environment {
        
        static func value(forKey key: EnvironmentKey) -> String? {
            
            if let environmentValues = Bundle.main.object(forInfoDictionaryKey: "EnvironmentVariables") as? Dictionary<String, Any> {
                if let value = environmentValues[key.rawValue] as? String {
                    return value
                }
            }
            
            return nil
        }
        
        enum EnvironmentKey: String {
            case TwitterKey
            case TwitterSecretKey
            case GooglePlacesAPIKey
            case EnvironmentAPIURL
        }
        
    }
    
    enum Utils {
        
        static func millisecondsSinceAppStart() -> Double {
            var kinfo = kinfo_proc()
            var size = MemoryLayout<kinfo_proc>.stride
            var mib : [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
            sysctl(&mib, u_int(mib.count), &kinfo, &size, nil, 0)
            let start_time = kinfo.kp_proc.p_starttime
            var time : timeval = timeval(tv_sec: 0, tv_usec: 0)
            gettimeofday(&time, nil)
            let currentTimeMilliseconds = Double(Int64(time.tv_sec) * 1000) + Double(time.tv_usec) / 1000.0
            let processTimeMilliseconds = Double(Int64(start_time.tv_sec) * 1000) + Double(start_time.tv_usec) / 1000.0
            return currentTimeMilliseconds - processTimeMilliseconds
        }
        
        static func dateFrom(string dateString: String) -> Date? {
            return DateFormatter.iso8601.date(from: dateString)
        }
        
        static func secondsToISO8601Format(_ seconds: Int) -> String {
            
            //format time to hh:mm:ss ISO8601 standard
            
            var formatedData = ""
            let hours = Int(seconds / 3600)
            let minutes = Int((seconds % 3600) / 60)
            let seconds = Int((seconds % 3600) % 60)
            
            //add hours if more than zero
            if hours > 0 {
                formatedData += (hours > 9 ? String(hours) : "0\(hours)") + ":"
            }
            
            formatedData += "\(minutes):"//add minutes
            formatedData += (seconds > 9 ? String(seconds) : "0\(seconds)")//add seconds
            
            return formatedData
        }
        
        static func normalize(_ min: CGFloat, _ max: CGFloat, _ n: CGFloat) -> CGFloat {
            return (n - min) * (1 / (max - min))
        }
        
        static func reverseNormalization(_ normalizedValue: CGFloat, _ minRange: CGFloat, _ maxRange: CGFloat) -> CGFloat {
            return (normalizedValue * (maxRange - minRange)) + minRange
        }
    }
    
}
