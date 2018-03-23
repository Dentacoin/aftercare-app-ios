//
// Aftercare
// Created by Dimitar Grudev on 7.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import UIKit

class FlossActionView: UIView, ActionViewProtocol {
    
    internal var embedView: ActionView?
    internal var timer: CircularBar?
    
    //MARK: - Delegate
    
    var delegate: ActionViewDelegate?
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContent()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupContent()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        embedView?.frame = self.bounds
        calculateTimerFrame()
    }
    
    //MARK: - Fileprivates
    
    fileprivate lazy var readyDescriptionString:String = {
        return NSLocalizedString("Let’s start by flossing your teeth. Pull around 25 cm of dental floss from your floss dispenser. Wrap the ends of the floss around your index and middle fingers. Press the start button when you are ready to floss.", comment: "")
    }()
    
    fileprivate lazy var actionDescriptionString:String = {
        return NSLocalizedString("Hold the floss tightly around each tooth in a C-shape. Move the floss back and forth in a push-pull motion and up and down against the side of each tooth", comment: "")
    }()
    
    fileprivate lazy var doneDescriptionString:String = {
        return NSLocalizedString("Great job, flossing!", comment: "")
    }()
    
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
            view.config(type: .flossed)
        }
    }
    
    fileprivate func loadTimerView() {
        guard let timer = Bundle.main.loadNibNamed(
            String(describing: CircularBar.self),
            owner: self, options: nil
        )?.first as? CircularBar else {
            return
        }
        calculateTimerFrame()
        timer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        embedView?.timerContainer.addSubview(timer)
        self.timer = timer
    }
    
    fileprivate func calculateTimerFrame() {
        if let containerFrame = embedView?.timerContainer.frame {
            if var timerFrame = timer?.frame {
                timerFrame.size.height = containerFrame.size.height
                timerFrame.size.width = containerFrame.size.width
                timer?.frame = timerFrame
            }
        }
    }
    
    //MARK: - Theme And Appearance
    
    fileprivate func setup() {
        
        embedView?.actionBarsContainer.lastBar.setTitle(NSLocalizedString("LAST FLOSS", comment: ""))
        embedView?.actionBarsContainer.leftBar.setTitle(NSLocalizedString("FLOSS LEFT", comment: ""))
        embedView?.actionBarsContainer.earnedBar.setTitle(NSLocalizedString("DCN EARNED", comment: ""))
        
        embedView?.actionFootherContainer.setActionButtonLabel(NSLocalizedString("Floss", comment: ""), withState: .blue)
        embedView?.autoDismissDoneStateAfter = 4
        
    }
    
    //MARK: - floss specific logic
    
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
    
    fileprivate func secondsToAngle(_ seconds: Double) -> Double {
        let totalSeconds = UserDataContainer.shared.FlossActionDurationInSeconds
        if seconds > totalSeconds {
            return 360
        }
        let scale = 360 / totalSeconds
        return seconds * scale
    }
    
    //MARK: - Public API
    
    func screenWillEnterFullscreen() {
        embedView?.actionFootherContainer.isStatisticsButtonHidden = true
    }
    
    func screenWillExitFullscreen() {
        embedView?.actionFootherContainer.isStatisticsButtonHidden = false
    }
    
}

//MARK: - Proxy Delegate Protocol

extension FlossActionView: ActionViewProxyDelegateProtocol {
    
    func timerUpdated(_ milliseconds: Double) {
        guard let timer = self.timer else { return }
        timer.centerLabel.text = self.formatCountdownTimerData(milliseconds)
        timer.bar.angle = self.secondsToAngle(milliseconds)
    }
    
    func stateChanged(_ newState: ActionState) {
        
        if let routine = UserDataContainer.shared.routine {
            
            if newState == .Ready {
                embedView?.actionFootherContainer.setActionButtonLabel(NSLocalizedString("START", comment: ""), withState: .blue)
                SoundManager.shared.playSound(SoundType.sound(routine.type, .floss, .ready))
                embedView?.descriptionTextView.text = readyDescriptionString
            } else if newState == .Action {
                embedView?.actionFootherContainer.setActionButtonLabel(NSLocalizedString("STOP", comment: ""), withState: .red)
                SoundManager.shared.playSound(SoundType.sound(routine.type, .floss, .progress(0)))
                embedView?.descriptionTextView.text = actionDescriptionString
            } else if newState == .Done {
                
                resetTimer()
                SoundManager.shared.playSound(SoundType.sound(routine.type, .floss, .done(.congratulations)))
                embedView?.descriptionTextView.text = doneDescriptionString
                
            } else if newState == .Initial {
                embedView?.toggleDescriptionText(false)
                return
            }
            
            embedView?.toggleDescriptionText(true)
            
        } else {
            
            if newState == .Initial {
                resetTimer()
            } else {
                embedView?.actionFootherContainer.setActionButtonLabel(NSLocalizedString("STOP", comment: ""), withState: .red)
            }
            
        }
    }
    
    fileprivate func resetTimer() {
        
        embedView?.actionFootherContainer.setActionButtonLabel(NSLocalizedString("FLOSS", comment: ""), withState: .blue)
        
        guard let timer = self.timer else { return }
        timer.centerLabel.text = "0:00"
        timer.bar.angle = 0
        
    }
    
}
