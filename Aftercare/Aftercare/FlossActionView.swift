//
// Aftercare
// Created by Dimitar Grudev on 7.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import UIKit

class FlossActionView: UIView, ActionViewProtocol {
    
    internal var embedView: ActionView?
    
    //MARK: - Delegate
    
    var delegate: ActionViewDelegate?
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContent()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)//, ActionRecordType.flossed
        setupContent()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        embedView?.frame = self.bounds
    }
    
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
    }
    
    //MARK: - Theme And Appearance
    
    fileprivate func setup() {
        
        embedView?.actionBarsContainer.lastBar.setTitle(NSLocalizedString("LAST FLOSS", comment: ""))
        embedView?.actionBarsContainer.leftBar.setTitle(NSLocalizedString("FLOSS LEFT", comment: ""))
        embedView?.actionBarsContainer.earnedBar.setTitle(NSLocalizedString("DCN EARNED", comment: ""))
        
        embedView?.actionFootherContainer.setActionButtonLabel(NSLocalizedString("FLOSS", comment: ""), withState: .blue)
        
    }
}

//MARK: - Proxy Delegate Protocol

extension FlossActionView: ActionViewProxyDelegateProtocol { }
