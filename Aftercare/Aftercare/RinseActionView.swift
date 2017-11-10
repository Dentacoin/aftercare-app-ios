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
    }
    
    //MARK: - Fileprivates
    
    fileprivate lazy var readyDescriptionString:String = {
        return NSLocalizedString("Now let’s proceed with the third step of your evening dental routine. Rinsing.", comment: "")
    }()
    
    fileprivate var actionDescription01Flag = false
    fileprivate lazy var actionDescription01String:String = {
        return NSLocalizedString("Try to swish until the end of the timer.", comment: "")
    }()
    
    fileprivate var actionDescription02Flag = false
    fileprivate lazy var actionDescription02String:String = {
        return NSLocalizedString("Don't worry if you can't get to the 30 seconds the first time, it gets easier each time you try.", comment: "")
    }()
    
    fileprivate lazy var doneDescriptionString:String = {
        return NSLocalizedString("You're done, spit the solution out in the sink You have completed your last brush for the day. Amazing job! Have a nice rest and come back in the morning.", comment: "")
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
        if let containerFrame = embedView?.timerContainer.frame {
            var timerFrame = timer.frame
            let aspectRatio = timerFrame.size.width / timerFrame.size.height
            timerFrame.size.height = min(containerFrame.size.height, containerFrame.size.width) * 0.8
            timerFrame.size.width = (timerFrame.size.height * aspectRatio)
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
        
        embedView?.actionBarsContainer.lastBar.setTitle(NSLocalizedString("LAST RINSE", comment: ""))
        embedView?.actionBarsContainer.leftBar.setTitle(NSLocalizedString("RINSE LEFT", comment: ""))
        embedView?.actionBarsContainer.earnedBar.setTitle(NSLocalizedString("DCN EARNED", comment: ""))
        
        embedView?.actionFootherContainer.setActionButtonLabel(NSLocalizedString("RINSE", comment: ""), withState: .blue)
        
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
        let scale = 360 / UserDataContainer.shared.RinseActionDurationInSeconds
        return 360 - (seconds * scale)
    }
}

//MARK: - Proxy Delegate Protocol

extension RinseActionView: ActionViewProxyDelegateProtocol {
    
    func timerUpdated(_ milliseconds: Double) {
        guard let timer = self.timer else { return }
        timer.centerLabel.text = self.formatCountdownTimerData(milliseconds)
        timer.bar.angle = self.secondsToAngle(milliseconds)
    }
    
    func stateChanged(_ newState: ActionState) {
        if newState == .Ready {
            embedView?.actionFootherContainer.setActionButtonLabel(NSLocalizedString("START", comment: ""), withState: .blue)
            embedView?.descriptionTextView.text = readyDescriptionString
        } else if newState == .Action {
            embedView?.actionFootherContainer.setActionButtonLabel(NSLocalizedString("STOP", comment: ""), withState: .red)
        } else if newState == .Done {
            guard let timer = self.timer else { return }
            timer.centerLabel.text = "0:00"
            timer.bar.angle = 0
            embedView?.actionFootherContainer.setActionButtonLabel(NSLocalizedString("RINSE", comment: ""), withState: .blue)
            embedView?.descriptionTextView.text = doneDescriptionString
        } else if newState == .Initial {
            embedView?.toggleDescriptionText(false)
            return
        }
        embedView?.toggleDescriptionText(true)
    }
    
}
