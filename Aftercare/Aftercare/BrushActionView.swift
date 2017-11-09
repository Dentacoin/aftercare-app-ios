//
// Aftercare
// Created by Dimitar Grudev on 7.11.17.
// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
//

import Foundation
import UIKit

class BrushActionView: UIView, ActionViewProtocol {
    
    internal var embedView: ActionView?
    
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
    }
    
    //MARK: - Theme And Appearance
    
    fileprivate func setup() {
        
        embedView?.actionBarsContainer.lastBar.setTitle(NSLocalizedString("LAST BRUSH", comment: ""))
        embedView?.actionBarsContainer.leftBar.setTitle(NSLocalizedString("BRUSH LEFT", comment: ""))
        embedView?.actionBarsContainer.earnedBar.setTitle(NSLocalizedString("DCN EARNED", comment: ""))
        
        embedView?.actionFootherContainer.setActionButtonLabel(NSLocalizedString("BRUSH", comment: ""), withState: .blue)
        
    }
    
}

//MARK: - Proxy Delegate Protocol

extension BrushActionView: ActionViewProxyDelegateProtocol { }
