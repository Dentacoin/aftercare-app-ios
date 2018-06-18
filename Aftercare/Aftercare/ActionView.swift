//
//  ActionView.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/13/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

class ActionView: UIView {
    
    //IBOutlets
    
    @IBOutlet weak var totalBar: TotalDCNBar!
    @IBOutlet weak var timerContainer: UIView!
    @IBOutlet weak var actionBarsContainer: ActionBarsView!
    @IBOutlet weak var actionFootherContainer: ActionFooterView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var edgeGesture: UIScreenEdgePanGestureRecognizer!
    
    //MARK: - delegates
    
    weak var delegate: ActionViewDelegate?
    
    //MARK: - Public
    
    var actionState: ActionState = .initial
    var autoDismissDoneStateAfter: Double = 4//time in seconds
    
    //MARK: - Fileprivates
    
    internal let UpdateIntervalInMilliseconds: Double = 0.1
    internal let OneSecond: Double = 1
    internal let OneMinute: Double = 60
    internal let OneHour: Double = 3600
    
    fileprivate var timer: Timer?
    fileprivate var secondsCount: Double = 0
    fileprivate var timerRunning = false
    fileprivate var startCountdownTime: Date?
    fileprivate var endCountdownTime: Date?
    fileprivate var stoppingCountdown = false
    
    fileprivate var statisticsPanelOpened: Bool = false {
        didSet {
            edgeGesture.isEnabled = !statisticsPanelOpened
        }
    }
    
    fileprivate let statisticsView: StatisticsView = {
        let statistics: StatisticsView = Bundle.main.loadNibNamed(
            String(describing: StatisticsView.self),
            owner: self,
            options: nil
            )?.first as! StatisticsView
        return statistics
    }()
    
    fileprivate var statisticsOpenedFrame: CGRect = CGRect.zero
    fileprivate var statisticsClosedFrame: CGRect = CGRect.zero
    
    //this value is for bottom safe area inset on iPhoneX. It's difficult to get those insets from the parent from this view
    //and for sake of simplicity i hardcode this in order to settings view hide fully after closed. This value doesn't change
    //the animation and expected functionality on other types of iphones and iOS versions
    fileprivate var bottomInset: CGFloat = 37
    
    //MARK: - Internals
    
    internal var actionViewRecordType: ActionRecordType?
    
    //MARK: - Lifecycle
    
    convenience init(frame: CGRect, _ actionType: ActionRecordType) {
        self.init(frame: frame)
    }
    
    convenience init?(coder aDecoder: NSCoder, _ actionType: ActionRecordType) {
        self.init(coder: aDecoder)
    }
    
    deinit {
        //remove observers
        let notifications = NotificationCenter.default
        notifications.removeObserver(self)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        calculateStatisticsViewFrames()
    }
    
    //MARK: internal logic
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //if statistics screen is opened
        if statisticsPanelOpened == true {
            //get the first touch
            if let touch = touches.first {
                //get the touch location
                let location = touch.location(in: self)
                //and get the statistics screen bounds
                let frame = statisticsView.frame
                //check whether the touch is inside the statistics screen or outside of it
                if !frame.contains(location) {
                    //if the touch is outside, close the statistics screen
                    closeStatisticsScreen()
                }
            }
        }
    }
    
    fileprivate func setup() {
        
        totalBar.delegate = self
        actionFootherContainer.delegate = self
        
        //setup statistics menu
        statisticsView.delegate = self
        self.addSubview(statisticsView)
        statisticsView.layoutIfNeeded()
        
        //register to notifications
        let notifications = NotificationCenter.default
        
        notifications.addObserver(
            self,
            selector: Selector.closeStatisticsSelector,
            name: Notification.Name.CloseStatisticsNotification,
            object: nil
        )
        
        notifications.addObserver(
            self,
            selector: Selector.openStatisticsSelector,
            name: Notification.Name.OpenStatisticsNotification,
            object: nil
        )
        
        self.clipsToBounds = false
    }
    
    fileprivate func calculateStatisticsViewFrames() {
        let containerHeight = self.frame.size.height
        let containerWidth = self.frame.size.width
        self.statisticsClosedFrame = CGRect(
            x: 0,
            y: containerHeight + bottomInset,
            width: containerWidth,
            height: (containerHeight * 0.5) + bottomInset
        )
        
        self.statisticsOpenedFrame = CGRect(
            x: 0,
            y: containerHeight * 0.40,
            width: containerWidth,
            height: (containerHeight * 0.60) + bottomInset
        )
        
        statisticsView.frame = statisticsClosedFrame
    }
    
    //MARK: - Public Api
    
    open func config(type actionType: ActionRecordType) {
        
        self.actionViewRecordType = actionType
        
        if let type = self.actionViewRecordType {
            statisticsView.config(type: type)
        }
        
        if let data = UserDataContainer.shared.actionScreenData {
            self.updateData(data)
        }
        
    }
    
    open func closeStatisticsScreen(_ animated: Bool = true) {
        
        let endFrame = self.statisticsClosedFrame
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: { [weak self] () -> Void in
                self?.statisticsView.frame = endFrame
                }, completion: { [weak self] success in
                    if success {
                        self?.statisticsPanelOpened = false
                        NotificationCenter.default.post(name: NSNotification.Name.CloseStatisticsNotification, object: self)
                    }
                }
            )
        } else {
            self.statisticsView.frame = endFrame
            self.statisticsPanelOpened = false
        }
    }
    
    open func openStatisticsScreen(_ animated: Bool = true) {
        
        let endFrame = self.statisticsOpenedFrame
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: { [weak self] () -> Void in
                self?.statisticsView.frame = endFrame
                }, completion: { [weak self] success in
                    if success {
                        self?.statisticsPanelOpened = true
                        NotificationCenter.default.post(name: NSNotification.Name.OpenStatisticsNotification, object: self)
                    }
                }
            )
        } else {
            self.statisticsView.frame = endFrame
            self.statisticsPanelOpened = true
        }
        
    }
    
    //MARK: - update data
    
    func updateData(_ data: ActionScreenData) {
        
        totalBar.setTotalValue(data.earnedDCN + data.pendingDCN)
        
        var screenDashboardData: ActionDashboardData?
        
        guard let type = self.actionViewRecordType else { return }
        switch type {
        case .brush:
            screenDashboardData = data.brush
        case .flossed:
            screenDashboardData = data.flossed
        case .rinsed:
            screenDashboardData = data.rinsed
        }
        
        guard let dashboard = screenDashboardData else { return }
        
        var daysPassed = 0
        var daysTotal = -1
        if let journey = UserDataContainer.shared.journey {
            daysPassed = journey.day
            daysTotal = journey.targetDays
        }
        //set bar values
        
        actionBarsContainer.setLastBarValue(dashboard.lastTime, type)
        actionBarsContainer.setLeftBarValue(dashboard.left, forType: type)
        actionBarsContainer.setDayBarValue(daysPassed, fromTotalOf: daysTotal)
        
        if let type = self.actionViewRecordType {
            statisticsView.config(type: type)
        }
        
        self.statisticsView.updateData(data)
    }
    
    func toggleDescriptionText(_ toggle: Bool) {
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            
            if toggle {
                self?.descriptionTextView.alpha = 1
                self?.actionBarsContainer.alpha = 0
            } else {
                self?.descriptionTextView.alpha = 0
                self?.actionBarsContainer.alpha = 1
            }
            
        })
        
    }
    
    func stateDidChangeTo(_ newState: ActionState) {
        self.actionState = newState
        self.delegate?.stateChanged(newState)
    }
    
    func screenWillEnterFullscreen() {
        actionFootherContainer.isStatisticsButtonHidden = true
    }
    
    func screenWillExitFullscreen() {
        actionFootherContainer.isStatisticsButtonHidden = false
    }
    
    //MARK: - @IBAction
    
    // TODO: make this guesture working again
    @IBAction func onSwipeGueastureSettingsScreen(_ sender: UIScreenEdgePanGestureRecognizer) {
        
        if sender.state == .began || sender.state == .changed {
            
            let containerHalfHeight = frame.size.height * 0.5
            var location = sender.location(in: self)
            
            if location.y < containerHalfHeight {
                location.y = containerHalfHeight
            }
            
            self.statisticsView.frame = CGRect(
                x: 0,
                y: Int(location.y),
                width: Int(frame.size.width),
                height: Int(containerHalfHeight)
            )
            
        }
        
        if sender.state == .ended || sender.state == .cancelled {
            
            let location = sender.location(in: self)
            let yOffset = frame.size.height - location.y
            
            if yOffset > statisticsView.frame.size.height * 0.5 {
                //show statistics view
                
                // TODO: Use UIViewPropertyAnimator instead of old UIView.animate in the whole App not just here
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    if let frame = self?.statisticsOpenedFrame {
                        self?.statisticsView.frame = frame
                    }
                    }, completion: { [weak self] success in
                        if success {
                            self?.statisticsPanelOpened = true
                        }
                    }
                )
            } else {//hide statistics view
                
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    if let frame = self?.statisticsClosedFrame {
                        self?.statisticsView.frame = frame
                    }
                    }, completion: { [weak self] success in
                        if success {
                            self?.statisticsPanelOpened = false
                        }
                    }
                )
            }
            
        }
        
    }
    
    //MARK: - Timer logic
    
    fileprivate func startCountdown() {
        if self.timer == nil {
            self.timer = Timer.scheduledTimer(
                timeInterval: UpdateIntervalInMilliseconds,
                target: self,
                selector: Selector.updateTimerSelector,
                userInfo: nil,
                repeats: true
            )
            startCountdownTime = Date()
            self.timerRunning = true
            
            //set the screen not to sleep
            UIApplication.shared.isIdleTimerDisabled = true
            
            //Notify the delegate
            delegate?.timerStarted()
        }
    }
    
    fileprivate func stopCountdown() {
        timer?.invalidate()
        timer = nil
        endCountdownTime = Date()
        timerRunning = false
        
        //set the screen not to sleep
        UIApplication.shared.isIdleTimerDisabled = false
        if UserDataContainer.shared.routine == nil {
            //Notify the delegate
            delegate?.timerStopped()
        }
    }
    
    fileprivate func clearTimerData() {
        secondsCount = 0
        startCountdownTime = nil
        endCountdownTime = nil
    }
    
    fileprivate func tryToCreateNewRecord() {
        if self.secondsCount >= UserDataContainer.shared.ActionMinimumRecordTimeInSeconds {
            //create new record
            guard let startTime = self.startCountdownTime else {
                delegate?.actionComplete(nil)//action complete with invalid record
                return
            }
            guard let endTime = self.endCountdownTime else {
                delegate?.actionComplete(nil)//action complete with invalid record
                return
            }
            guard let type = self.actionViewRecordType else {
                delegate?.actionComplete(nil)//action complete with invalid record
                return
            }
            let record = ActionRecordData(startTime: startTime.iso8601, endTime: endTime.iso8601, type: type)
            
            //Notify the delegate
            delegate?.actionComplete(record)
            
        } else {
            //action complete with invalid record
            delegate?.actionComplete(nil)
        }
    }
    
    @objc fileprivate func updateTimer() {
        secondsCount += UpdateIntervalInMilliseconds
        delegate?.timerUpdated(secondsCount)
    }
    
    @objc func executeAction() {
        if self.timerRunning {
            self.stopCountdown()
            self.tryToCreateNewRecord()
            self.clearTimerData()
        } else {
            startCountdown()
        }
    }
    
    //MARK: - KVO Selectors
    
    @objc fileprivate func closeStatisticsNotification() {
        if self.statisticsPanelOpened {
            self.closeStatisticsScreen(false)
        }
    }
    
    @objc fileprivate func openStatisticsNotification() {
        if !self.statisticsPanelOpened {
            self.openStatisticsScreen(false)
        }
    }
    
}

//MARK: - ActionFooterViewDelegate

extension ActionView: ActionFooterViewDelegate {
    func onStatisticsButtonPressed() {
        if self.timerRunning { return }
        openStatisticsScreen()
    }
    
    internal func onActionButtonPressed() {
        
        if UserDataContainer.shared.routine != nil {
            if actionState == .initial {
                actionState = .ready
            } else if actionState == .ready {
                    actionState = .action
                    self.perform(Selector.executeActionSelector, with: nil, afterDelay: 0.0)
            } else if actionState == .done {
                actionState = .initial
            } else {
                
                actionState = .done
                self.perform(Selector.executeActionSelector, with: nil, afterDelay: 0.0)
                self.actionFootherContainer.actionButton.isEnabled = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + self.autoDismissDoneStateAfter, execute: { [weak self] in
                    if self?.actionState == .done {//if it's still done change it automatically to initial
                        self?.actionState = .initial
                        self?.delegate?.stateChanged((self?.actionState)!)
                        self?.actionFootherContainer.actionButton.isEnabled = true
                        self?.delegate?.timerStopped()
                    }
                })
            }
        } else {
            if actionState == .initial {
                actionState = .action
                SoundManager.shared.playRandomMusic()
            } else {
                actionState = .initial
                delegate?.timerStopped()
            }
            self.perform(Selector.executeActionSelector, with: nil, afterDelay: 0.0)
        }
        
        delegate?.stateChanged(actionState)
    }
    
}

//MARK: - TotalDCNBarDelegate

extension ActionView: TotalDCNBarDelegate {
    func onTotalBarPressed() {
        if timerRunning { return }
        delegate?.requestToOpenCollectScreen()
    }
}

//MARK: - StatisticsDelegate

extension ActionView: StatisticsDelegate {
    func closeStatisticsPressed() {
        closeStatisticsScreen()
    }
}

//MARK: - ActionState

enum ActionState {
    case initial
    case ready
    case action
    case done
}

//MARK: - ActionViewProtocol

protocol ActionViewProtocol {
    
    var actionViewRecordType: ActionRecordType { get }
    var embedView: ActionView? { get }
    
    func updateData(_ data: ActionScreenData)
    func screenWillEnterFullscreen()
    func screenWillExitFullscreen()
    func stateDidChangeTo(_ newState: ActionState)
    
}

//MARK: - Selectors

fileprivate extension Selector {
    static let closeStatisticsSelector = #selector(ActionView.closeStatisticsNotification)
    static let openStatisticsSelector = #selector(ActionView.openStatisticsNotification)
    static let updateTimerSelector = #selector(ActionView.updateTimer)
    static let executeActionSelector = #selector(ActionView.executeAction)
}

//MARK: - Notifications

extension Notification.Name {
    static let CloseStatisticsNotification = Notification.Name("CloseStatisticsNotification")
    static let OpenStatisticsNotification = Notification.Name("OpenStatisticsNotification")
}

//MARK: - Helpers
//TODO: - move these Helper extensions to more proper place

extension Date {
    var iso8601: String {
        return DateFormatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return DateFormatter.iso8601.date(from: self)// "Mar 22, 2017, 10:22 AM"
    }
}

