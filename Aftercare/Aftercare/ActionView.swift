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
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var timerBar: CircularBar!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var edgeGesture: UIScreenEdgePanGestureRecognizer!
    
    @IBOutlet weak var lastBar: SmallCircularBar!
    @IBOutlet weak var leftBar: SmallCircularBar!
    @IBOutlet weak var earnedBar: SmallCircularBar!
    @IBOutlet weak var statisticsButton: UIButton!
    @IBOutlet weak var totalDCNView: UIView!
    
    //MARK: - delegates
    
    weak var delegate: ActionViewDelegate?
    
    //MARK: - fileprivate constants
    
    fileprivate let UpdateIntervalInMilliseconds: Double = 0.1
    fileprivate let OneSecond: Double = 1
    fileprivate let OneMinute: Double = 60
    fileprivate let OneHour: Double = 3600
    
    //MARK: - fileprivates
    
    fileprivate var actionViewRecordType: ActionRecordType?
    
    fileprivate var actionButtonLabelStop = NSLocalizedString("STOP", comment: "")
    fileprivate var actionButtonLabel: String?
    fileprivate var lastBarLabel: String?
    fileprivate var leftBarLabel: String?
    fileprivate var earnedLabel: String?
    fileprivate var totalLabelString: String?
    
    //this value is for bottom safe area inset on iPhoneX. It's difficult to get those insets from the parent from this view
    //and for sake of simplicity i hardcode this in order to settings view hide fully after closed. This value doesn't change
    //the animation and expected functionality on other types of iphones and iOS versions
    fileprivate var bottomInset: CGFloat = 37
    
    fileprivate var timer: Timer?
    fileprivate var secondsCount: Double = 0
    fileprivate var timerRunning = false
    fileprivate var startCountdownTime: Date?
    fileprivate var endCountdownTime: Date?
    fileprivate var stoppingCountdown = false
    fileprivate var statisticsOpenedFrame: CGRect = CGRect.zero
    fileprivate var statisticsClosedFrame: CGRect = CGRect.zero
    fileprivate var tutorialsAlreadySetup = false
    
    fileprivate var statisticsPanelOpened: Bool = false {
        didSet {
            edgeGesture.isEnabled = !statisticsPanelOpened
        }
    }
    
    fileprivate let statisticsView: StatisticsView = {
        let statistics: StatisticsView = Bundle.main.loadNibNamed(
            "StatisticsView",
            owner: self,
            options: nil
            )?.first as! StatisticsView
        return statistics
    }()
    
    //MARK: - Lifecycle
    
    convenience init(frame: CGRect, _ actionType: ActionRecordType) {
        self.init(frame: frame)
    }
    
    convenience init?(coder aDecoder: NSCoder, _ actionType: ActionRecordType) {
        self.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !tutorialsAlreadySetup {
            tutorialsAlreadySetup = true
            setupTutorials()
        }
    }
    
    //MARK: - public api
    
    open func config(type actionType: ActionRecordType) {
        
        self.actionViewRecordType = actionType
        
        switch actionType {
            case .flossed:
                
                actionButtonLabel = NSLocalizedString("FLOSS", comment: "")
                lastBarLabel = NSLocalizedString("LAST FLOSS", comment: "")
                leftBarLabel = NSLocalizedString("FLOSS LEFT", comment: "")
                earnedLabel = NSLocalizedString("DCN EARNED", comment: "")
                
                break
            case .brush:
                
                actionButtonLabel = NSLocalizedString("BRUSH", comment: "")
                lastBarLabel = NSLocalizedString("LAST BRUSH", comment: "")
                leftBarLabel = NSLocalizedString("BRUSH LEFT", comment: "")
                earnedLabel = NSLocalizedString("DCN EARNED", comment: "")
            
                break
            case .rinsed:
                
                actionButtonLabel = NSLocalizedString("RINSE", comment: "")
                lastBarLabel = NSLocalizedString("LAST RINSE", comment: "")
                leftBarLabel = NSLocalizedString("RINSE LEFT", comment: "")
                earnedLabel = NSLocalizedString("DCN EARNED", comment: "")
            
                break
        }
        
        totalLabelString = NSLocalizedString("TOTAL", comment: "")
        
        lastBar.setTitle(lastBarLabel ?? "")
        leftBar.setTitle(leftBarLabel ?? "")
        earnedBar.setTitle(earnedLabel ?? "")
        totalLabel.text = totalLabelString
        
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
                        self?.delegate?.statisticsScreenClosed(self!)
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
                        self?.delegate?.statisticsScreenOpened(self!)
                    }
                }
            )
        } else {
            self.statisticsView.frame = endFrame
            self.statisticsPanelOpened = true
        }
        
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
            
            //change action button appearance
            actionButton.setTitle(actionButtonLabelStop, for: .normal)
            actionButton.setTitle(actionButtonLabelStop, for: .highlighted)
            let themeManager = ThemeManager.shared
            themeManager.setDCBlueTheme(to: actionButton, ofType: .ButtonDefaultRedGradient)
            
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
        
        //change action button appearance
        actionButton.setTitle(actionButtonLabel, for: .normal)
        actionButton.setTitle(actionButtonLabel, for: .highlighted)
        let themeManager = ThemeManager.shared
        themeManager.setDCBlueTheme(to: actionButton, ofType: .ButtonDefaultBlueGradient)
        
        //set the screen not to sleep
        UIApplication.shared.isIdleTimerDisabled = false
        
        //Notify the delegate
        delegate?.timerStopped()
    }
    
    fileprivate func clearTimerData() {
        self.secondsCount = 0
        self.startCountdownTime = nil
        self.endCountdownTime = nil
        self.timerBar.bar.angle = 0
        self.timerBar.centerLabel.text = formatCountdownTimerData(self.secondsCount)
    }
    
    fileprivate func tryToCreateNewRecord() {
        if self.secondsCount >= UserDataContainer.shared.ActionMinimumRecordTimeInSeconds {
            //create new record
            guard let startTime = self.startCountdownTime else { return }
            guard let endTime = self.endCountdownTime else { return }
            guard let type = self.actionViewRecordType else { return }
            let record = ActionRecordData(startTime: startTime.iso8601, endTime: endTime.iso8601, type: type)
            
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
    
    fileprivate func formatCountdownTimerData(_ seconds: Double) -> String? {
        var formatedData = ""
        let minutes = Int((self.secondsCount.truncatingRemainder(dividingBy: OneHour)) / OneMinute)
        let seconds = Int(self.secondsCount.truncatingRemainder(dividingBy: OneMinute))
        formatedData += String(minutes)//minutes > 9 ? String(minutes) : "0" + String(minutes)
        formatedData += ":"//delimiter minutes : seconds
        formatedData += seconds > 9 ? String(seconds) : "0" + String(seconds)
        return formatedData
    }
    
    fileprivate func secondsToAngle(_ seconds: Double) -> Double {
        let scale = 360 / UserDataContainer.shared.ActionDurationInSeconds
        return seconds * scale
    }
    
    @objc fileprivate func updateTimer() {
        //if !self.stoppingCountdown {
            self.secondsCount += UpdateIntervalInMilliseconds
            self.timerBar.centerLabel.text = self.formatCountdownTimerData(self.secondsCount)
            self.timerBar.bar.angle = self.secondsToAngle(self.secondsCount)
        //}
        if self.secondsCount > UserDataContainer.shared.ActionDurationInSeconds {//|| self.stoppingCountdown == true {
            //self.stoppingCountdown = false
            self.stopCountdown()
            self.tryToCreateNewRecord()
            self.clearTimerData()
        }
    }
    
    @objc func executeAction() {
        if self.timerRunning {
            //self.stoppingCountdown = true
            self.stopCountdown()
            self.tryToCreateNewRecord()
            self.clearTimerData()
        } else {
            startCountdown()
        }
        self.actionButton.isUserInteractionEnabled = true
    }
    
    //MARK: - update data
    
    func updateData(_ data: ActionScreenData) {
        
        if let total = data.totalDCN {
            self.totalValueLabel.text = String(total) + " DCN"
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
        
        //calculate last bar value
        let lastTimeProgress = UserDataContainer.shared.getActionsLastTimeBarProgress(Double(dashboard.lastTime))
        let lastTimeLabel = SystemMethods.Utils.secondsToHumanReadableFormat(dashboard.lastTime)
        self.lastBar.setValue(lastTimeLabel, lastTimeProgress)
        
        //calculate left actions value
        let leftProgress = UserDataContainer.shared.getActionsLeftBarProgress(Double(dashboard.left), forType: type)
        self.leftBar.setValue(String(dashboard.left), leftProgress)
        
        //this bar has no value progress
        self.earnedBar.setValue(String(dashboard.earned))
        
        self.statisticsView.updateData(data)
    }
    
}

//MARK: - Apply theme and appearance

extension ActionView {
    
    fileprivate func setup() {
        
        let themeManager = ThemeManager.shared
        actionButton.setTitle(actionButtonLabel, for: .normal)
        actionButton.setTitle(actionButtonLabel, for: .highlighted)
        themeManager.setDCBlueTheme(to: actionButton, ofType: .ButtonDefaultBlueGradient)
        
        totalLabel.textColor = .dntWarmGrey
        totalLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntNanoLabelSize)
        
        totalValueLabel.textColor = .dntCeruleanBlue
        totalLabel.font = UIFont.dntLatoLightFont(size: UIFont.dntButtonFontSize)
        
        //setup statistics menu
        statisticsView.delegate = self
        self.addSubview(statisticsView)
        statisticsView.layoutIfNeeded()
        
        let screenHeight = UIScreen.main.bounds.size.height
        
        self.statisticsClosedFrame = CGRect(
            x: 0,
            y: screenHeight + bottomInset,
            width: self.frame.size.width,
            height: self.frame.size.height * 0.6
        )
        
        self.statisticsOpenedFrame = CGRect(
            x: 0,
            y: self.frame.size.height * 0.4,
            width: self.frame.size.width,
            height: self.frame.size.height * 0.6
        )
        
        statisticsView.frame = statisticsClosedFrame
        
        self.clipsToBounds = false
    }
    
    fileprivate func setupTutorials() {
        
        if actionViewRecordType != .flossed {
            return
        }
        
        let tooltips: [(id: String ,text: String, forView: UIView, arrowAt: EasyTipView.ArrowPosition)] = [
            (
                id: TutorialIDs.totalDcn.rawValue,
                text: NSLocalizedString("This is the total amount of DCN you've earned.", comment: ""),
                forView: self.totalDCNView,
                arrowAt: EasyTipView.ArrowPosition.top
            ), (
                id: TutorialIDs.lastActivityTime.rawValue,
                text: NSLocalizedString("Last recorded time", comment: ""),
                forView: self.lastBar,
                arrowAt: EasyTipView.ArrowPosition.top
            ), (
                id: TutorialIDs.leftActivitiesCount.rawValue,
                text: NSLocalizedString("Remaining activities for today", comment: ""),
                forView: self.leftBar,
                arrowAt: EasyTipView.ArrowPosition.bottom
            ), (
                id: TutorialIDs.dcnEarned.rawValue,
                text: NSLocalizedString("Earned DCN from this activity", comment: ""),
                forView: self.earnedBar,
                arrowAt: EasyTipView.ArrowPosition.top
            ), (
                id: TutorialIDs.dashboardStatistics.rawValue,
                text: NSLocalizedString("Tap to open statistics", comment: ""),
                forView: self.statisticsButton,
                arrowAt: EasyTipView.ArrowPosition.bottom
            )
        ]
        
        for tooltip in tooltips {
            showTooltip(
                tooltip.text,
                forView: tooltip.forView,
                at: tooltip.arrowAt,
                id: tooltip.id
            )
        }
        
    }
    
    fileprivate func showTooltip(_ text: String, forView: UIView, at position: EasyTipView.ArrowPosition, id: String) {
        
        //check if already seen by the user in this app session. "True" means still valid for this session
        var active = UserDataContainer.shared.getTutorialSessionToggle(id)//session state
        active = UserDataContainer.shared.getTutorialToggle(id)//between session state
        
        if  active {
            
            var preferences = ThemeManager.shared.tooltipPreferences
            preferences.drawing.arrowPosition = position
            
            let tooltipText = NSLocalizedString(
                text,
                comment: ""
            )
            
            EasyTipView.show(
                forView: forView,
                withinSuperview: self,
                text: tooltipText,
                preferences: preferences,
                delegate: self,
                id: id
            )
            
            //set to false so next time user opens the same screen this will not show
            UserDataContainer.shared.setTutorialSessionToggle(id, false)
            
        }
    }
    
}

//MARK: - IBActions

extension ActionView {
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        self.perform(Selector.executeActionSelector, with: nil, afterDelay: 0.0)
    }
    
    @IBAction func statisticScreenButtonPressed(_ sender: UIButton) {
        if self.timerRunning { return }
        openStatisticsScreen()
    }
    
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
    
    @IBAction func collectScreenButtonPressed(_ sender: UIButton) {
        if timerRunning { return }
        delegate?.requestToOpenCollectScreen()
    }
    
}

//MARK: - EasyTipViewDelegate

extension ActionView: EasyTipViewDelegate {
    
    func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        //turn off tooltip if dismissed by the user
        UserDataContainer.shared.setTutorialToggle(tipView.accessibilityIdentifier ?? "", false)
    }
    
}

//MARK: - StatisticsDelegate

extension ActionView: StatisticsDelegate {
    internal func closeStatisticsPressed() {
        closeStatisticsScreen()
    }
}

//MARK: - Selectors

fileprivate extension Selector {
    static let updateTimerSelector = #selector(ActionView.updateTimer)
    static let executeActionSelector = #selector(ActionView.executeAction)
}

//MARK: - Helpers

extension Date {
    var iso8601: String {
        return DateFormatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return DateFormatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
    }
}
