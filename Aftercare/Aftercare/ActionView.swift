//
//  ActionView.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/13/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit
import EasyTipView

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
    
    var actionState: ActionState = .Initial
    
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
            y: containerHeight * 0.5,
            width: containerWidth,
            height: (containerHeight * 0.5) + bottomInset
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
    
    open func showTutorials() {
        actionBarsContainer.showTutorials()
        actionFootherContainer.showTutorials()
        totalBar.showTutorials()
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
        
        if let total = data.totalDCN {
            totalBar.setTotalValue(total)
        }
        
        var screenDashboardData: ActionDashboardData?
        
        guard let type = self.actionViewRecordType else { return }
        switch type {
        case .brush:
            screenDashboardData = data.brush
            break
        case .flossed:
            screenDashboardData = data.flossed
            break
        case .rinsed:
            screenDashboardData = data.rinsed
            break
        }
        
        guard let dashboard = screenDashboardData else { return }
        
        //set bar values
        
        actionBarsContainer.setLastBarValue(dashboard.lastTime, type)
        actionBarsContainer.setLeftBarValue(dashboard.left, forType: type)
        actionBarsContainer.setEarnedBarValue(dashboard.earned)
        
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
    
    //MARK: - @IBAction
    
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
            self.startCountdownTime = Date()
            self.timerRunning = true
            
            //set the screen not to sleep
            UIApplication.shared.isIdleTimerDisabled = true
            
            //Notify the delegate
            delegate?.timerStarted()
        }
    }
    
    fileprivate func stopCountdown() {
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
        self.endCountdownTime = Date()
        self.timerRunning = false
        
        //set the screen not to sleep
        UIApplication.shared.isIdleTimerDisabled = false
        
        //Notify the delegate
        delegate?.timerStopped()
    }
    
    fileprivate func clearTimerData() {
        self.secondsCount = 0
        self.startCountdownTime = nil
        self.endCountdownTime = nil
    }
    
    fileprivate func tryToCreateNewRecord() {
        if self.secondsCount >= UserDataContainer.shared.ActionMinimumRecordTimeInSeconds {
            //create new record
            guard let startTime = self.startCountdownTime else { return }
            guard let endTime = self.endCountdownTime else { return }
            guard let type = self.actionViewRecordType else { return }
            let record = ActionRecordData(startTime: startTime.iso8601, endTime: endTime.iso8601, type: type)
            
            
            let defaults = UserDefaults.standard
            if defaults.value(forKey: "startOf90DaysPeriod") == nil {
                //If there is not start date of the 90 days period we create one
                //this mean the 90 days period start from now
                let now = Date()
                let startOfThePeriod = now.iso8601
                defaults.set(startOfThePeriod, forKey: "startOf90DaysPeriod")
            }
            
            //API call to record the successfuly completed action
            APIProvider.recordAction(record: record) { validAction, error in
                if let action = validAction {
                    print("Successfuly record new action: \(action)")
                    UserDataContainer.shared.syncWithServer()
                }
                if let error = error {
                    print("Error on attempt to record new action: \(error)")
                }
            }
            
            //Notify the delegate
            self.delegate?.actionComplete()
        }
    }
    
    @objc fileprivate func updateTimer() {
        self.secondsCount += UpdateIntervalInMilliseconds
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
    
    func onActionButtonPressed() {
        
        if UserDataContainer.shared.routine != nil {
            if actionState == .Initial {
                actionState = .Ready
                delegate?.stateChanged(actionState)
            } else if actionState == .Done {
                //Change state to Ready
                actionState = .Initial
                delegate?.stateChanged(actionState)
                return
            } else if actionState == .Ready {
                //Change state to Action
                actionState = .Action
                self.perform(Selector.executeActionSelector, with: nil, afterDelay: 0.0)
            } else {
                //Change state to Done
                actionState = .Done
                self.perform(Selector.executeActionSelector, with: nil, afterDelay: 0.0)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: { [weak self] in
                    if self?.actionState == .Done {//if it's still Done change it automatically to Initial
                        self?.actionState = .Initial
                        self?.delegate?.stateChanged((self?.actionState)!)
                    }
                })
            }
        } else {
            if actionState == .Initial {
                actionState = .Action
            } else {
                actionState = .Initial
            }
            delegate?.stateChanged(actionState)
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

//MARK: -

enum ActionState {
    case Initial
    case Ready
    case Action
    case Done
}

//MARK: - ActionViewProtocol

protocol ActionViewProtocol {
    var actionViewRecordType: ActionRecordType { get }
    func updateData(_ data: ActionScreenData)
    func setupTutorials()
}

//MARK: - Selectors

extension Selector {
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

