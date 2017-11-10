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
    
    //MARK: - public
    
    var musicIsPlaying = false
    var soundIsPlaying = false
    
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
    
    var soundOn: Bool {
        get {
            let defaults = UserDefaults.standard
            if let on = defaults.value(forKey: "soundOn") as? Bool {
                return on
            } else {
                defaults.set(true, forKey: "soundOn")
                return true
            }
        }
        
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "soundOn")
        }
    }
    
    var musicOn: Bool {
        get {
            let defaults = UserDefaults.standard
            if let on = defaults.value(forKey: "musicOn") as? Bool {
                return on
            } else {
                defaults.set(true, forKey: "musicOn")
                return true
            }
        }
        
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "musicOn")
        }
    }
    
    func playMusic(_ type: MusicPath) {
        if musicOn == false {
            return
        }
        let path = type.path
        if let url = Bundle.main.url(forResource: path, withExtension: "mp3") {
            music = Sound(url: url)
            music?.play(numberOfLoops: -1, completion: nil)//play music with infinite loop on background
            setMusicVolume(1.0)
            musicIsPlaying = true
        }
    }
    
    func playRandomMusic() {
        if musicOn == false {
            return
        }
        let path = MusicPath.all.randomElement.path
        if let url = Bundle.main.url(forResource: path, withExtension: "mp3") {
            music = Sound(url: url)
            music?.play(numberOfLoops: -1, completion: nil)//play music with infinite loop on background
            setMusicVolume(1.0)
            musicIsPlaying = true
        }
    }
    
    func stopMusic() {
        music?.stop()
        musicIsPlaying = false
    }
    
    func setMusicVolume(_ volume: Float) {
        music?.volume = volume
    }
    
    func playSound(_ type: SoundType, _ callback: (() -> Void)? = nil) {
        
        if soundOn == false {
            return
        }
        
        do {
            var path: String
            switch type {
            case .greeting(let routine):
                path = try SoundPath.greeting(voice: soundType, routine: routine)
            case .sound(let routine, let action, let status):
                path = try SoundPath.sound(voice: soundType, routine: routine, action: action, status: status)
            }
            
            //Stop all currently playing sounds
            self.stopSound()
            
            //WORKING Sound.play(file: "male-morning-greeting", fileExtension: "mp3", numberOfLoops: 0)
            print("PLAY SOUND \(path)")
            
            if let url = Bundle.main.url(forResource: path, withExtension: "mp3") {
                sound = Sound(url: url)
                sound?.volume = 1.0
                sound?.play() { [weak self] completed in
                    if let callback = callback {
                        callback()
                    } else {
                        self?.soundIsPlaying = false
                        if let musicPlaying = self?.musicIsPlaying, musicPlaying == true {
                            self?.setMusicVolume(1.0)
                        }
                    }
                }
                soundIsPlaying = true
                if self.musicIsPlaying {
                    self.setMusicVolume(0.5)
                }
                
            }
            
        } catch {
            print("Warning: \(error.localizedDescription)")
        }
    }
    
    func stopSound() {
        sound?.stop()
        soundIsPlaying = false
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
        return soundName//voicePath + "/" + routinePath + "/" + soundName
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
        return name//voicePath + "/" + routinePath + "/" + actionPath + "/" + name
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
        case (.rinse, .done(.other)): return "4"
        case (.rinse, .done(.congratulations)): return "5"
            
        case (.floss, .ready): return "1"
        case (.floss, .progress(_)): return "2"
        case (.floss, .done(_)): return "3"
        
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
        return "music-" + "\(self.rawValue)"
    }
    
    static var all: [MusicPath] {
        return [.music01, .music02, .music03, .music04, .music05, .music06, .music07, .music08, .music09]
    }
}

//MARK: - Helpers

private extension Array {
    var randomElement: Element {
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
}


