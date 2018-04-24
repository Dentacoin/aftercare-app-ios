//
// Aftercare
// Created by Dimitar Grudev on 7.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import UIKit

class RinseActionView: UIView, ActionViewProtocol {
    
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
        super.init(coder: aDecoder)//, ActionRecordType.rinsed
        setupContent()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        embedView?.frame = self.bounds
        calculateTimerFrame()
    }
    
    //MARK: - Fileprivates
    
    fileprivate lazy var readyMorningDescriptionString:String = {
        return "message_morning_routine_3".localized()
    }()
    
    fileprivate lazy var readyEveningDescriptionString:String = {
        return "message_evening_rinse_start".localized()
    }()
    
    fileprivate var actionDescription01Flag = false
    fileprivate lazy var actionDescription01String:String = {
        return "message_rinse_1".localized()
    }()
    
    fileprivate var actionDescription02Flag = false
    fileprivate lazy var actionDescription02String:String = {
        return "message_rinse_2".localized()
    }()
    
    fileprivate var actionDoneFlag = false
    
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
            view.config(type: .rinsed)
        }
    }
    
    fileprivate func loadTimerView() {
        guard let timer = Bundle.main.loadNibNamed(
            String(describing: CircularBar.self),
            owner: self, options: nil
        )?.first as? CircularBar else {
            return
        }
        timer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        calculateTimerFrame()
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
        
        embedView?.actionBarsContainer.lastBar.setTitle("dashboard_lbl_last_rinse".localized())
        embedView?.actionBarsContainer.leftBar.setTitle("dashboard_lbl_rinse_left".localized())
        embedView?.actionBarsContainer.dayBar.setTitle("dashboard_lbl_day".localized())
        
        embedView?.actionFootherContainer.setActionButtonLabel("dashboard_btn_start_rinse".localized(), withState: .blue)
        embedView?.autoDismissDoneStateAfter = 0
    }
    
    //MARK: - rinse specific logic
    
    fileprivate func formatCountdownTimerData(_ seconds: Double) -> String? {
        var formatedData = ""
        guard let hour = embedView?.OneHour else { return nil }
        guard let minute = embedView?.OneMinute else { return nil }
        let minutes = Int((seconds.truncatingRemainder(dividingBy: hour)) / minute)
        let totalSeconds = UserDataContainer.shared.RinseActionDurationInSeconds
        let seconds = Int(totalSeconds - seconds.truncatingRemainder(dividingBy: minute))
        formatedData += String(minutes)
        formatedData += ":"//delimiter minutes : seconds
        formatedData += seconds > 9 ? String(seconds) : "0" + String(seconds)
        return formatedData
    }
    
    fileprivate func secondsToAngle(_ seconds: Double) -> Double {
        let totalSeconds = UserDataContainer.shared.RinseActionDurationInSeconds
        if seconds > totalSeconds {
            return 0
        }
        let scale = 360 / totalSeconds
        return 360 - (seconds * scale)
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

extension RinseActionView: ActionViewProxyDelegateProtocol {
    
    func timerUpdated(_ seconds: Double) {
        guard let timer = self.timer else { return }
        timer.centerLabel.text = self.formatCountdownTimerData(seconds)
        timer.bar.angle = self.secondsToAngle(seconds)
        
        if seconds >= 0, seconds < 10 {
            if !actionDescription01Flag {
                actionDescription01Flag = true
                if let routine = UserDataContainer.shared.routine {
                    SoundManager.shared.playSound(SoundType.sound(routine.type, .rinse, .progress(Int(seconds))))
                    embedView?.descriptionTextView.text = actionDescription01String
                }
            }
        }
        
        if seconds >= 10, seconds < 20 {
            if !actionDescription02Flag {
                actionDescription02Flag = true
                if let routine = UserDataContainer.shared.routine {
                    SoundManager.shared.playSound(SoundType.sound(routine.type, .rinse, .progress(Int(seconds))))
                    embedView?.descriptionTextView.text = actionDescription02String
                }
            }
        }
        
        if seconds >= UserDataContainer.shared.RinseActionDurationInSeconds, actionDoneFlag == false {
            actionDoneFlag = true
            self.embedView?.onActionButtonPressed()
        }
    }
    
    func stateChanged(_ newState: ActionState) {
        
        if let routine = UserDataContainer.shared.routine {
        
            if newState == .Ready {
                
                embedView?.actionFootherContainer.setActionButtonLabel("dashboard_btn_start".localized(), withState: .blue)
                if routine.type == .morning {
                    embedView?.descriptionTextView.text = readyMorningDescriptionString
                } else {
                    embedView?.descriptionTextView.text = readyEveningDescriptionString
                }
                SoundManager.shared.playSound(SoundType.sound(routine.type, .rinse, .ready))
                
            } else if newState == .Action {
                
                embedView?.actionFootherContainer.setActionButtonLabel("dashboard_btn_stop".localized(), withState: .red)
                
            } else if newState == .Done {
                
                resetTimer()
                
            } else if newState == .Initial {
                embedView?.toggleDescriptionText(false)
                return
            }
            
            embedView?.toggleDescriptionText(true)
        
        } else {
            
            if newState == .Initial {
                resetTimer()
            } else {
                embedView?.actionFootherContainer.setActionButtonLabel("dashboard_btn_stop".localized(), withState: .red)
            }
            
        }
    }
    
    fileprivate func resetTimer() {
        
        //reset the flags
        actionDescription01Flag = false
        actionDescription02Flag = false
        actionDoneFlag = false
        
        embedView?.actionFootherContainer.setActionButtonLabel("dashboard_btn_start_rinse".localized(), withState: .blue)
        
        guard let timer = self.timer else { return }
        timer.centerLabel.text = "0:00"
        timer.bar.angle = 0
        
    }
    
}
