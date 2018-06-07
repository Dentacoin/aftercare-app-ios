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
        return "message_evening_brush_start".localized()
    }()
    
    fileprivate var actionDescription01Flag = false
    fileprivate lazy var actionStep01String:String = {
        return "message_brush_1".localized()
    }()
    
    fileprivate var actionDescription02Flag = false
    fileprivate lazy var actionStep02String:String = {
        return "message_brush_2".localized()
    }()
    
    fileprivate var actionDescription03Flag = false
    fileprivate lazy var actionStep03String:String = {
        return "message_brush_3".localized()
    }()
    
    fileprivate var actionDescription04Flag = false
    fileprivate lazy var actionStep04String:String = {
        return "message_brush_4".localized()
    }()
    
    fileprivate var actionDescription05Flag = false
    fileprivate lazy var actionStep05String:String = {
        return "message_brush_press_stop_when_ready".localized()
    }()
    
    fileprivate lazy var doneDescriptionString:String = {
        return "message_brush_congratulations".localized()
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
            
            //Because of the shadow being part of the teeth timer background it looks uncentered and shifted a bit to the left
            //We use 6 pixels shift to the right to conpensate this and timer to look perfectly centered
            timerFrame.origin.x += 6
            
            timerFrame.origin.y = (containerFrame.size.height - timerFrame.size.height) / 2
            timer.frame = timerFrame
        }
        timer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        embedView?.timerContainer.addSubview(timer)
        self.timer = timer
    }
    
    //MARK: - Theme And Appearance
    
    fileprivate func setup() {
        
        embedView?.actionBarsContainer.lastBar.setTitle("dashboard_lbl_last_brush".localized().uppercased())
        embedView?.actionBarsContainer.leftBar.setTitle("dashboard_lbl_brush_left".localized().uppercased())
        embedView?.actionBarsContainer.dayBar.setTitle("dashboard_lbl_day".localized().uppercased())
        
        embedView?.actionFootherContainer.setActionButtonLabel("dashboard_btn_start_brush".localized(), withState: .blue)
        embedView?.autoDismissDoneStateAfter = 4
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
    
    //MARK: - Public API
    
    func screenWillEnterFullscreen() {
        embedView?.actionFootherContainer.isStatisticsButtonHidden = true
    }
    
    func screenWillExitFullscreen() {
        embedView?.actionFootherContainer.isStatisticsButtonHidden = false
    }
}

//MARK: - Proxy Delegate Protocol

extension BrushActionView: ActionViewProxyDelegateProtocol {
    
    func timerUpdated(_ seconds: Double) {
        guard let timer = self.timer else { return }
        timer.timerLabel.text = self.formatCountdownTimerData(seconds)
        
        let seconds: Int = Int(seconds)
        
        switch seconds {
        case 0...30:
            if !actionDescription01Flag {
                actionDescription01Flag = true
                timer.highlightSection(.upperLeft)
                if let routine = UserDataContainer.shared.routine {
                    SoundManager.shared.playSound(SoundType.sound(routine.type, .brush, .progress(seconds)))
                    embedView?.descriptionTextView.text = actionStep01String
                }
            }
        case 30...60:
            if !actionDescription02Flag {
                actionDescription02Flag = true
                timer.highlightSection(.downLeft)
                if let routine = UserDataContainer.shared.routine {
                    SoundManager.shared.playSound(SoundType.sound(routine.type, .brush, .progress(seconds)))
                    embedView?.descriptionTextView.text = actionStep02String
                }
            }
        case 60...90:
            if !actionDescription03Flag {
                actionDescription03Flag = true
                timer.highlightSection(.downRight)
                if let routine = UserDataContainer.shared.routine {
                    SoundManager.shared.playSound(SoundType.sound(routine.type, .brush, .progress(seconds)))
                    embedView?.descriptionTextView.text = actionStep03String
                }
            }
        case 90...120:
            if !actionDescription04Flag {
                actionDescription04Flag = true
                timer.highlightSection(.upperRight)
                if let routine = UserDataContainer.shared.routine {
                    SoundManager.shared.playSound(SoundType.sound(routine.type, .brush, .progress(seconds)))
                    embedView?.descriptionTextView.text = actionStep04String
                }
            }
        default:
            if !actionDescription05Flag {
                actionDescription05Flag = true
                timer.highlightSection(.none)
                if let routine = UserDataContainer.shared.routine {
                    SoundManager.shared.playSound(SoundType.sound(routine.type, .brush, .progress(seconds)))
                    embedView?.descriptionTextView.text = actionStep05String
                }
            }
        }
    }
    
    func stateChanged(_ newState: ActionState) {
        
        if let routine = UserDataContainer.shared.routine {
            
            if newState == .ready {
                embedView?.actionFootherContainer.setActionButtonLabel("dashboard_btn_start".localized(), withState: .blue)
                SoundManager.shared.playSound(SoundType.sound(routine.type, .brush, .ready))
                embedView?.descriptionTextView.text = readyDescriptionString
            } else if newState == .action {
                embedView?.actionFootherContainer.setActionButtonLabel("dashboard_btn_stop".localized(), withState: .red)
            } else if newState == .done {
                resetTimer()
                //this is the same sound for morning and evening routine
                SoundManager.shared.playSound(SoundType.sound(.morning, .brush, .done(.congratulations)))
                embedView?.descriptionTextView.text = doneDescriptionString
            } else if newState == .initial {
                embedView?.toggleDescriptionText(false)
                return
            }
            
            embedView?.toggleDescriptionText(true)
            
        } else {
            
            if newState == .initial {
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
        actionDescription03Flag = false
        actionDescription04Flag = false
        actionDescription05Flag = false
        
        embedView?.actionFootherContainer.setActionButtonLabel("dashboard_btn_start_brush".localized(), withState: .blue)
        
        guard let timer = self.timer else { return }
        timer.timerLabel.text = "0:00"
        timer.highlightSection(.none)
        
    }
    
}
