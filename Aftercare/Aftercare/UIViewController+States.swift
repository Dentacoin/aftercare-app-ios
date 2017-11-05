//
//  UIViewController+States.swift
//  Aftercare
//
//  Created by Dimitar Grudev on 26.10.17.
//  Copyright © 2017 Dimitar Grudev. All rights reserved.
//

import Foundation
import UIKit

private var stateViewKey: UInt8 = 0
private var stateViewTypeKey: UInt8 = 0

extension UIViewController {
    
    var stateView: UIView? {
        get { return objc_getAssociatedObject(self, &stateViewKey) as? UIView }
        set { objc_setAssociatedObject(self, &stateViewKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    var stateType: StateType? {
        get { return objc_getAssociatedObject(self, &stateViewTypeKey) as? StateType }
        set { objc_setAssociatedObject(self, &stateViewTypeKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    func showState(_ state: State) {
        
        if state.stateType == self.stateType { return }
        self.stateType = state.stateType
        
        switch state.stateType {
            case .emptyState: showEmptyView(state)
            case .errorState: showErrorView(state)
            case .loadingState: showLoadingView(state)
            case .none: removeState()
        }
        
    }
    
    func removeState() {
        removeStateView()
        self.stateType = .none
    }
    
    private func removeStateView() {
        
        self.stateView?.removeFromSuperview()
        self.stateType = .none
        
//        UIView.animate(
//            withDuration: 0.5,
//            delay: 0,
//            options: UIViewAnimationOptions.curveEaseOut,
//            animations: {
//                self.stateView?.alpha = 0
//            }, completion: { [weak self] _ in
//                self?.stateView?.removeFromSuperview()
//                self?.stateType = .none
//            }
//        )
        
    }
    
    //MARK: - Private Methods
    
    fileprivate func showEmptyView(_ state: State) {
        
        removeStateView()

        let emptyView: EmptyStateView! = EmptyStateView.loadViewFromNib()
        addToParentAndAssignConstraints(emptyView, self.view)

        //Style View
        emptyView.backgroundColor = .white
        emptyView.titleLabel?.font = UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)
        emptyView.titleLabel?.textColor = UIColor.dntCeruleanBlue

        emptyView.titleLabel?.text = state.title

        stateView = emptyView
        
    }
    
    fileprivate func showErrorView(_ state: State) {
        
        removeStateView()

        let errorView: ErrorStateView! = ErrorStateView.loadViewFromNib()
        addToParentAndAssignConstraints(errorView, self.view)

        //Style View
        errorView.backgroundColor = .white
        errorView.titleLabel?.font = UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)
        errorView.titleLabel?.textColor = UIColor.dntCharcoalGrey

        errorView.titleLabel?.text = state.title

        stateView = errorView
        
    }
    
    fileprivate func showLoadingView(_ state: State) {
        removeStateView()
        
        let loadingView: LoadingStateView! = LoadingStateView.loadViewFromNib()
        addToParentAndAssignConstraints(loadingView, self.view)
        
        loadingView.loadingLabel?.font = UIFont.dntLatoLightFont(size: UIFont.dntLabelFontSize)
        loadingView.loadingLabel?.textColor = UIColor.white
        loadingView.square.layer.cornerRadius = 10
        loadingView.square.alpha = 0.4
        loadingView.activityIndicator?.startAnimating()

        loadingView.loadingLabel?.text = state.title
        loadingView.effectView.alpha = 0
        
        stateView = loadingView
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: UIViewAnimationOptions.curveEaseOut,
            animations: {
                loadingView.effectView.alpha = 0.5
            },
            completion: nil
        )
        
    }
    
    fileprivate func addToParentAndAssignConstraints(_ child: UIView, _ parent: UIView) {
        
        parent.addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        
        let top: NSLayoutConstraint
        if let holder = (self as? ContentConformer)?.headerView {
            top = NSLayoutConstraint(
                item: child,
                attribute: .top,
                relatedBy: .equal,
                toItem: holder,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0.0
            )
        } else {
            top = NSLayoutConstraint(
                item: child,
                attribute: .top,
                relatedBy: .equal,
                toItem: parent,
                attribute: .top,
                multiplier: 1.0,
                constant: 0.0
            )
        }
        
        let leading = NSLayoutConstraint(
            item: child,
            attribute: .leading,
            relatedBy: .equal,
            toItem: parent,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0.0
        )
        
        let trailing = NSLayoutConstraint(
            item: child,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: parent,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0.0
        )
        
        let bottom = NSLayoutConstraint(
            item: child,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: parent,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0.0
        )
        
        parent.addConstraint(leading)
        parent.addConstraint(trailing)
        parent.addConstraint(top)
        parent.addConstraint(bottom)
    }
    
}

//MARK: - States

enum StateType {
    case emptyState
    case loadingState
    case errorState
    case none
}

struct State {
    
    var stateType: StateType
    var title: String?
    
    public init(_ _stateType: StateType, _ _title: String? = nil) {
        self.stateType = _stateType
        self.title = _title
    }
    
}

//State Classes

class EmptyStateView: ReusableXibView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override class func nibName() -> String {
        return "EmptyState"
    }
}

class LoadingStateView: ReusableXibView {
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var square: UIView!
    @IBOutlet weak var effectView: UIVisualEffectView!
    
    var progress: Int = 0 {
        didSet {
            //updateProgress()
        }
    }
    
    override class func nibName() -> String {
        return "LoadingState"
    }
    
//    private func updateProgress() {
//        if progress < 0 || progress > 100 {
//            return
//        }
//
//        for index in 0..<progressImageViewCollection.count {
//            self.progressImageViewCollection[index].image = UIImage(named: "no_progress")
//        }
//
//        let steps = progress / 20
//        for step in 0..<steps {
//            self.progressImageViewCollection[step].image = UIImage(named: "progress")
//        }
//    }
    
}

class ErrorStateView: ReusableXibView {

    @IBOutlet weak var titleLabel: UILabel!

    override class func nibName() -> String {
        return "ErrorState"
    }
}

