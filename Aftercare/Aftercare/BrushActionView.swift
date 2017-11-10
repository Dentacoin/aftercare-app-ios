//
// Aftercare
// Created by Dimitar Grudev on 7.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import UIKit

class BrushActionView: UIView, ActionViewProtocol {
    
    internal var embedView: ActionView?
    internal var timer: BrushBar?
    
    //MARK: - fileprivates
    
    fileprivate lazy var readyDescriptionString:String = {
        return NSLocalizedString("Let's start with brushing your teeth. Make sure your toothbrush is not dry, and apply toothpaste as the size of peagrain. Press the start button when you are ready to brush.", comment: "")
    }()
    
    fileprivate var actionDescription01Flag = false
    fileprivate lazy var actionStep01String:String = {
        return NSLocalizedString("Starting with the upper left quadrant, brush continuously for the following 30 seconds.", comment: "")
    }()
    
    fileprivate var actionDescription02Flag = false
    fileprivate lazy var actionStep02String:String = {
        return NSLocalizedString("Now let’s brush the lower left quadrant for the following 30 seconds.", comment: "")
    }()
    
    fileprivate var actionDescription03Flag = false
    fileprivate lazy var actionStep03String:String = {
        return NSLocalizedString("It is time you move to the lower right quadrant. Brush this area for the following 30 seconds.", comment: "")
    }()
    
    fileprivate var actionDescription04Flag = false
    fileprivate lazy var actionStep04String:String = {
        return NSLocalizedString("Now let’s brush the upper right quadrant. This is the last sector, only 30 more seconds.", comment: "")
    }()
    
    fileprivate var actionDescription05Flag = false
    fileprivate lazy var actionStep05String:String = {
        return NSLocalizedString("When you are done press the STOP button.", comment: "")
    }()
    
    fileprivate lazy var doneDescriptionString:String = {
        return NSLocalizedString("Now you are done. Congratulations!", comment: "")
    }()
    
    //MARK: - Delegate
    
    var delegate: ActionViewDelegate?
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)//, ActionRecordType.brush
        setupContent()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        embedView?.frame = self.bounds
    }
    
    //MARK: - Internal logic
    
    fileprivate func setupContent() {
        loadXib()
        loadTimerView()
        setup()
    }
    
    fileprivate func loadXib() {
        embedView = Bundle.main.loadNibNamed(String(describing: ActionView.self), owner: self, options: nil)?.first! as? ActionView
        if let view = embedView {
            self.addSubview(view)
            view.frame = self.bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.backgroundColor = .clear
            view.delegate = self
            view.config(type: .brush)
        }
    }
    
    fileprivate func loadTimerView() {
        guard let timer = Bundle.main.loadNibNamed(
            String(describing: BrushBar.self),
            owner: self, options: nil
            )?.first as? BrushBar else {
                return
        }
        if let containerFrame = embedView?.timerContainer.frame {
            var timerFrame = timer.frame
            timerFrame.size.height = containerFrame.size.height
            timerFrame.origin.x = (containerFrame.size.width - timerFrame.size.width) / 2
            timerFrame.origin.y = (containerFrame.size.height - timerFrame.size.height) / 2
            timer.frame = timerFrame
        }
        timer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        embedView?.timerContainer.addSubview(timer)
        self.timer = timer
    }
    
    //MARK: - Theme And Appearance
    
    fileprivate func setup() {
        
        embedView?.actionBarsContainer.lastBar.setTitle(NSLocalizedString("LAST BRUSH", comment: ""))
        embedView?.actionBarsContainer.leftBar.setTitle(NSLocalizedString("BRUSH LEFT", comment: ""))
        embedView?.actionBarsContainer.earnedBar.setTitle(NSLocalizedString("DCN EARNED", comment: ""))
        
        embedView?.actionFootherContainer.setActionButtonLabel(NSLocalizedString("BRUSH", comment: ""), withState: .blue)
        
    }
    
    //MARK: - brush specific logic
    
    fileprivate func formatCountdownTimerData(_ seconds: Double) -> String? {
        var formatedData = ""
        guard let hour = embedView?.OneHour else { return nil }
        guard let minute = embedView?.OneMinute else { return nil }
        let minutes = Int((seconds.truncatingRemainder(dividingBy: hour)) / minute)
        let seconds = Int(seconds.truncatingRemainder(dividingBy: minute))
        formatedData += String(minutes)
        formatedData += ":"//delimiter minutes : seconds
        formatedData += seconds > 9 ? String(seconds) : "0" + String(seconds)
        return formatedData
    }
    
    //MARK: - Public
    
    func setupTutorials() {
        embedView?.showTutorials()
    }
}

//MARK: - Proxy Delegate Protocol

extension BrushActionView: ActionViewProxyDelegateProtocol {
    
    func timerUpdated(_ seconds: Double) {
        guard let timer = self.timer else { return }
        timer.timerLabel.text = self.formatCountdownTimerData(seconds)
        
        let seconds: Int = Int(seconds)
        
        if seconds >= 0, seconds < 30 {
            if !actionDescription01Flag {
                actionDescription01Flag = true
                timer.highlightSection(.UpperRight)
                if let routine = UserDataContainer.shared.routine {
                    SoundManager.shared.playSound(SoundType.sound(routine.type, .brush, .progress(seconds)))
                    embedView?.descriptionTextView.text = actionStep01String
                }
            }
        }
        
        if seconds > 30, seconds < 60 {
            if !actionDescription02Flag {
                actionDescription02Flag = true
                timer.highlightSection(.DownRight)
                if let routine = UserDataContainer.shared.routine {
                    SoundManager.shared.playSound(SoundType.sound(routine.type, .brush, .progress(seconds)))
                    embedView?.descriptionTextView.text = actionStep02String
                }
            }
        }
        
        if seconds > 60, seconds < 90 {
            if !actionDescription03Flag {
                actionDescription03Flag = true
                timer.highlightSection(.DownLeft)
                if let routine = UserDataContainer.shared.routine {
                    SoundManager.shared.playSound(SoundType.sound(routine.type, .brush, .progress(seconds)))
                    embedView?.descriptionTextView.text = actionStep03String
                }
            }
        }
        
        if seconds > 90, seconds < 120 {
            if !actionDescription04Flag {
                actionDescription04Flag = true
                timer.highlightSection(.UpperLeft)
                if let routine = UserDataContainer.shared.routine {
                    SoundManager.shared.playSound(SoundType.sound(routine.type, .brush, .progress(seconds)))
                    embedView?.descriptionTextView.text = actionStep04String
                }
            }
        }
        
        if seconds > 120 {
            if !actionDescription05Flag {
                actionDescription05Flag = true
                timer.highlightSection(.None)
                if let routine = UserDataContainer.shared.routine {
                    SoundManager.shared.playSound(SoundType.sound(routine.type, .brush, .progress(seconds)))
                    embedView?.descriptionTextView.text = actionStep05String
                }
            }
        }
    }
    
    func stateChanged(_ newState: ActionState) {
        
        if let routine = UserDataContainer.shared.routine {
            
            if newState == .Ready {
                embedView?.actionFootherContainer.setActionButtonLabel(NSLocalizedString("START", comment: ""), withState: .blue)
                SoundManager.shared.playSound(SoundType.greeting(routine.type))
                embedView?.descriptionTextView.text = readyDescriptionString
            } else if newState == .Action {
                embedView?.actionFootherContainer.setActionButtonLabel(NSLocalizedString("STOP", comment: ""), withState: .red)
            } else if newState == .Done {
                guard let timer = self.timer else { return }
                timer.timerLabel.text = "0:00"
                timer.highlightSection(.None)
                SoundManager.shared.playSound(SoundType.sound(routine.type, .brush, .done(.other)))
                embedView?.actionFootherContainer.setActionButtonLabel(NSLocalizedString("BRUSH", comment: ""), withState: .blue)
                embedView?.descriptionTextView.text = doneDescriptionString
            } else if newState == .Initial {
                embedView?.toggleDescriptionText(false)
                return
            }
            if UserDataContainer.shared.routine != nil {
                embedView?.toggleDescriptionText(true)
            }
            
        } else {
            
            if newState == .Initial {
                guard let timer = self.timer else { return }
                timer.timerLabel.text = "0:00"
                timer.highlightSection(.None)
                embedView?.actionFootherContainer.setActionButtonLabel(NSLocalizedString("FLOSS", comment: ""), withState: .blue)
            } else {
                embedView?.actionFootherContainer.setActionButtonLabel(NSLocalizedString("STOP", comment: ""), withState: .red)
            }
        }
        
    }
    
}
