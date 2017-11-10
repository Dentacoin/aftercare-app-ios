//
// Aftercare
// Created by Dimitar Grudev on 9.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import SwiftySound

class SoundManager {
    
    //MARK: - singleton
    
    static let shared = SoundManager()
    private init() { }
    
    //MARK: - Fileprivate variables and constants
    
    fileprivate var sound: Sound?
    fileprivate var music: Sound?
    
    //music IDs
    
    var soundType: VoicePath {
        get {
            let defaults = UserDefaults.standard
            if let type = defaults.value(forKey: "soundVoice") {
                return VoicePath(rawValue: type as! String)!
            } else {
                defaults.set(VoicePath.male.rawValue, forKey: "soundVoice")
                return VoicePath.male
            }
        }
        
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue.rawValue, forKey: "soundVoice")
        }
    }
    
    func playSound(_ type: SoundType, _ callback: (() -> Void)? = nil) {
        do {
            var path: String
            switch type {
            case .greeting(let routine):
                path = try SoundPath.greeting(voice: soundType, routine: routine)
            case .sound(let routine, let action, let status):
                path = try SoundPath.sound(voice: soundType, routine: routine, action: action, status: status)
            }
            
            
            if let sound = self.sound {
                //If already playing some sound, stop it
                sound.stop()
            }
            if let url = URL(string: "/test-1.wav") {
                print("PLAY SOUND AT PATH: \(url.absoluteURL)")
                sound = Sound(url: url)
                sound?.volume = 1.0
                sound?.play() { completed in
                    if let callback = callback {
                        callback()
                    }
                }
            }
        } catch {
            print("Warning: \(error.localizedDescription)")
        }
    }
    
}

enum SoundType {
    case greeting(RoutinePath)
    case sound(RoutinePath, ActionPath, StatusPath)
}

protocol Pathable {
    var path: String? { get }
}

enum VoicePath: String, Pathable {
    case male
    case female
    
    var path: String? {
        switch self {
        case .male: return "male"
        case .female: return "female"
        }
    }
}

enum RoutinePath: Pathable {
    case morning
    case evening
    
    var path: String? {
        switch self {
        case .morning: return "morning"
        case .evening: return "evening"
        }
    }
}

enum ActionPath: Pathable {
    case brush
    case floss
    case rinse
    
    var path: String? {
        switch self {
        case .brush: return "brush"
        case .floss: return "floss"
        case .rinse: return "rinse"
        }
    }
}

enum DoneStagePath {
    case congratulations
    case other
}

enum StatusPath {
    case ready
    case progress(Int)
    case done(DoneStagePath)
}

enum SoundPathError: Error {
    case invalidPath
    case invalidAction
}

enum SoundPath {
    static func greeting(voice: VoicePath, routine: RoutinePath) throws -> String {
        guard let voicePath = voice.path else {
            throw SoundPathError.invalidPath
        }
        guard let routinePath = routine.path else {
            throw SoundPathError.invalidPath
        }
//        guard let resourcePath = Bundle.main.resourcePath else {
//            throw SoundPathError.invalidPath
//        }
        let soundName = voicePath + "-" + routinePath + "-" + "greeting"
        return voicePath + "/" + routinePath + "/" + soundName
    }
    
    static func sound(voice: VoicePath, routine: RoutinePath, action: ActionPath, status: StatusPath) throws -> String {
        guard let voicePath = voice.path else {
            throw SoundPathError.invalidPath
        }
        guard let routinePath = routine.path else {
            throw SoundPathError.invalidPath
        }
        guard let actionPath = action.path else {
            throw SoundPathError.invalidPath
        }
//        guard let resourcePath = Bundle.main.resourcePath else {
//            throw SoundPathError.invalidPath
//        }
        
        switch (routine, action) {
        case (.morning, .floss): throw SoundPathError.invalidAction
        default: break
        }
        
        switch status {
        case .done(let stage):
            switch (action, stage) {
            case (.brush, .other): throw SoundPathError.invalidAction
            case (.floss, .other): throw SoundPathError.invalidAction
            default: break
            }
        default: break
        }
        
        let name = voicePath + "-" + routinePath + "-" + actionPath + "-" + NameHelper(action, status)
        return voicePath + "/" + routinePath + "/" + actionPath + "/" + name
    }
    
    private static func NameHelper(_ action: ActionPath, _ status: StatusPath) -> String {
        switch (action, status) {
        case (.brush, .ready): return "1"
        case (.brush, .progress(let seconds)):
            switch seconds {
            case 0..<30: return "2"
            case 30..<60: return "3"
            case 60..<90: return "4"
            case 90..<120: return "5"
            default: return "6"
            }
        case (.brush, .done): return "7"
            
        case (.rinse, .ready): return "1"
        case (.rinse, .progress(let seconds)):
            switch seconds {
            case 0..<10: return "2"
            default: return "3"
            }
        case (.rinse, .done): return "7"
            
        case (.floss, .ready): return "1"
        case (.floss, .progress(_)): return "2"
        case (.floss, .done): return "3"
        }
    }
    
}

// Music Path

enum MusicPath: Int, Pathable {
    case music01 = 1
    case music02
    case music03
    case music04
    case music05
    case music06
    case music07
    case music08
    case music09
    
    var path: String? {
        return "music/music-" + "\(self.rawValue)"
    }
}



