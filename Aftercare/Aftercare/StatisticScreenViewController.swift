//
//  StatisticScreen.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 9/9/17.
//  Copyright © 2017 Stichting Administratiekantoor Dentacoin. All rights reserved.
//

import Foundation
import UIKit

class StatisticScreenViewController: UIViewController, ContentConformer {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var headerView: UIView?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    var contentDelegate: ContentDelegate?
    
    //MARK: - Public
    
    var header: InitialPageHeaderView! {
        return headerView as! InitialPageHeaderView
    }
    
    //MARK: - fileprivates
    
    typealias StatisticsCell = (
        cellType: String,
        label: String?,
        data: ActionDashboardData?,
        kind: ActionRecordType?
    )
    
    fileprivate var timeLeftTitle = NSLocalizedString("TIME LEFT", comment: "")
    fileprivate var averageTimeTitle = NSLocalizedString("AVERAGE TIME", comment: "")
    
    fileprivate var data: [StatisticsCell] = [
        (
            cellType: String(describing: StatisticsOptionsCell.self),
            label: nil,
            data: nil,
            kind: nil
        ),
        (
            cellType: String(describing: StatisticsLabelCell.self),
            label: NSLocalizedString("Floss Statistic", comment: ""),
            data: nil,
            kind: ActionRecordType.flossed
        ),
        (
            cellType: String(describing: StatisticsCircularBarsCell.self),
            label: NSLocalizedString("TIMES FLOSSED", comment: ""),
            data: UserDataContainer.shared.actionScreenData?.flossed,
            kind: .flossed
        ),
        (
            cellType: String(describing: StatisticsLabelCell.self),
            label: NSLocalizedString("Brush Statistic", comment: ""),
            data: nil,
            kind: ActionRecordType.brush
        ),
        (
            cellType: String(describing: StatisticsCircularBarsCell.self),
            label: NSLocalizedString("TIMES BRUSHED", comment: ""),
            data: UserDataContainer.shared.actionScreenData?.brush,
            kind: .brush
        ),
        (
            cellType: String(describing: StatisticsLabelCell.self),
            label: NSLocalizedString("Rinse Statistic", comment: ""),
            data: nil,
            kind: ActionRecordType.rinsed
        ),
        (
            cellType: String(describing: StatisticsCircularBarsCell.self),
            label: NSLocalizedString("TIMES RINSED", comment: ""),
            data: UserDataContainer.shared.actionScreenData?.rinsed,
            kind: .rinsed
        )
    ]
    
    fileprivate var selectedOption: ScheduleOptionTypes = .dailyData
    fileprivate var calculatedConstraints = false
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            if !calculatedConstraints {
                calculatedConstraints = true
                let topPadding = self.view.safeAreaInsets.top
                headerHeightConstraint.constant += topPadding
            }
        }
    }
    
    //MARK: - Internal logic
    
}

//MARK: - Apply theme and appearance

extension StatisticScreenViewController {
    
    fileprivate func setup() {
        
        header.updateTitle(NSLocalizedString("Statistic", comment: ""))
        
        tableView.register(
                UINib(
                    nibName: String(describing: StatisticsOptionsCell.self),
                    bundle: nil
                ),
                forCellReuseIdentifier: String(describing: StatisticsOptionsCell.self)
        )
        
        tableView.register(
            UINib(
                nibName: String(describing: StatisticsLabelCell.self),
                bundle: nil
            ),
            forCellReuseIdentifier: String(describing: StatisticsLabelCell.self)
        )
        
        tableView.register(
            UINib(
                nibName: String(describing: StatisticsCircularBarsCell.self),
                bundle: nil
            ),
            forCellReuseIdentifier: String(describing: StatisticsCircularBarsCell.self)
        )
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        
        //these two settings help us use auto layout for the cells and
        //their size to be determined by its contents
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160
        
        tableView.reloadData()
        
    }
    
}

//MARK: - InitialPageHeaderViewDelegate

extension StatisticScreenViewController: InitialPageHeaderViewDelegate {
    
    func mainMenuButtonIsPressed() {
        contentDelegate?.openMainMenu()
    }
    
}

//MARK: - UITableViewDelegate

extension StatisticScreenViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellData = self.data[indexPath.row]
        let cellType = cellData.cellType
        let cellKind = cellData.kind
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType, for: indexPath)
        cell.backgroundColor = .clear
        if let cell = cell as? StatisticsTableViewCellProtocol {
            cell.setupAppearance()
        }
        
        if let cell = cell as? StatisticsOptionsCell {
            cell.updateOptionButtons(self.selectedOption)
        }
        
        if let cell = cell as? StatisticsLabelCell {
            cell.titleLabel.text = cellData.label
        }
        
        if let cell = cell as? StatisticsCircularBarsCell {
            if let optionData = cellData.data {
                
                let data: ScheduleData?
                switch self.selectedOption {
                    case .dailyData:
                        data = optionData.daily
                    case .weeklyData:
                        data = optionData.weekly
                    case .monthlyData:
                        data = optionData.monthly
                }
                
                if let actionsTakenData = data?.times {
                    let actionsValueTitle = String(actionsTakenData)
                    let actionsValueProgress = UserDataContainer.shared.getStatisticsActionsTakenProgress(
                        Double(actionsTakenData),
                        forKind: cellData.kind!,
                        ofType: selectedOption
                    )
                    
                    cell.actionsTakenBar.setValue(actionsValueTitle, actionsValueProgress)
                    cell.actionsTakenBar.setTitle(cellData.label ?? "")
                }
                
                if let timeLeftData = data?.left {
                    
                    let actionsValueProgress = UserDataContainer.shared.getStatisticsTimeLeftProgress(
                        Double(timeLeftData),
                        forKind: cellData.kind!,
                        ofType: selectedOption
                    )
                    let timeLeftLabel = SystemMethods.Utils.secondsToHumanReadableFormat(timeLeftData)
                    
                    cell.timeLeftBar.setValue(timeLeftLabel, actionsValueProgress)
                    cell.timeLeftBar.setTitle(self.timeLeftTitle)
                }
                
                if let averageTimeData = data?.average {
                    let averageValue = UserDataContainer.shared.getStatisticsAverageTimeProgress(Double(averageTimeData), cellKind!)
                    let averageValueTitle = SystemMethods.Utils.secondsToHumanReadableFormat(averageTimeData)
                    cell.averageTimeBar.setValue(averageValueTitle, averageValue)
                    cell.averageTimeBar.setTitle(self.averageTimeTitle)
                }
                
            }
        }
        
        if cellType == String(describing: StatisticsOptionsCell.self) {
            let cell = cell as? StatisticsOptionsCell
            cell?.delegate = self
        }
        
        return cell
    }
    
}

//MARK: - UITableViewDataSource

extension StatisticScreenViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
}

//MARK: - StatisticsOptionsCellDelegate

extension StatisticScreenViewController: StatisticsOptionsCellDelegate {
    
    func optionChanged(_ option: ScheduleOptionTypes) {
        self.selectedOption = option
        tableView.reloadData()
    }
    
}

enum ScheduleOptionTypes {
    case dailyData
    case weeklyData
    case monthlyData
}
