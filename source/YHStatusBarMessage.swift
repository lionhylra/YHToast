//
//  StatusBarMessage.swift
//  Swift3Project
//
//  Created by Yilei on 27/3/17.
//  Copyright © 2017 lionhylra.com. All rights reserved.
//

import UIKit

@available(iOS 10.0, *)
public class YHStatusBarMessage {
    
    public static let shared = YHStatusBarMessage()
    private weak var timer: Timer?
    
    // MARK: - Life Cycle -
    fileprivate init() {}
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    
    // MARK: - UI Properties -
    fileprivate lazy var containerWindow: UIWindow = {
        let containerWindow = UIWindow(frame: UIScreen.main.bounds)
        
        let windowController = WindowController()
        containerWindow.rootViewController = windowController
        containerWindow.windowLevel = UIWindowLevelNormal
        containerWindow.isUserInteractionEnabled = false
        
        let rootView: UIView = containerWindow.rootViewController!.view
        
        rootView.addSubview(self.alertView)
        
        self.alertView.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSLayoutAttribute] = [.leading, .trailing]
        attributes.forEach { (attribute) in
            NSLayoutConstraint(item: self.alertView, attribute: attribute, relatedBy: .equal, toItem: rootView, attribute: attribute, multiplier: 1, constant: 0).isActive = true
        }
        self.topLayoutConstraint = NSLayoutConstraint(item: self.alertView, attribute: .top, relatedBy: .equal, toItem: rootView, attribute: .top, multiplier: 1, constant: -self.alertViewHeight)
        self.topLayoutConstraint?.isActive = true
        return containerWindow
    }()
    
    fileprivate lazy var alertView = UIView()
    
    public fileprivate(set) lazy var textLabel: UILabel = {
        let label = UILabel()
        self.alertView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: self.alertView, attribute: .top, multiplier: 1, constant: self.statusBarHeight),
            NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: self.alertView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: self.alertView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: self.alertView, attribute: .bottom, multiplier: 1, constant: 0)
        ]
        NSLayoutConstraint.activate(constraints)
        
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 13)
        
        return label
    }()
    
    fileprivate var topLayoutConstraint: NSLayoutConstraint?
    
    fileprivate var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    fileprivate var alertViewHeight: CGFloat {
        return textLabel.sizeThatFits(UIScreen.main.bounds.size).height + statusBarHeight
    }
    
    fileprivate var showAnimator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 500)
    
    fileprivate var hideAnimator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 500)
    
    
    // MARK: - Configuration properties -
    public var statusBarStyle: UIStatusBarStyle? {
        set {
            (containerWindow.rootViewController as? WindowController)?.statusBarStyle = newValue
        }
        get {
            return (containerWindow.rootViewController as? WindowController)?.statusBarStyle
        }
    }
    
    public var isShown: Bool = false
    
    
    public var backgroundColor: UIColor! {
        get {
            return alertView.backgroundColor
        }
        
        set {
            alertView.backgroundColor = newValue
        }
    }
    
    
    
    /// Show the message under the status bar
    ///
    /// - Parameters:
    ///   - message: The text to show
    ///   - duration: if nil, the message view won't hide automatically. if a TimeInterval is given, it will hide automatically after the duration.
    ///   - animated: a flag indicating whether it animates to show/hide
    public func show(message: String, duration: TimeInterval?, animated: Bool = true) {
        textLabel.text = message
        
        containerWindow.isHidden = false
        
        if !isShown {
            topLayoutConstraint?.constant = -alertViewHeight
            containerWindow.rootViewController?.view.layoutIfNeeded()//draw the view at original position
        }
        
        timer?.invalidate()
        
        performShowAnimation(animated: animated) { [weak self] in
            guard let duration = duration else {
                return
            }
            
            self?.timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: { (timer) in
                self?.performHideAnimation(animated: animated)
            })
        }
    }
    
    
    
    public func hide(animated: Bool = true) {
        timer?.invalidate()
        
        performHideAnimation(animated: animated)
    }
    
    
    
    private func performShowAnimation(animated: Bool, animationCompleted: @escaping () -> Void) {
        topLayoutConstraint?.constant = 0
        let animation: ()->Void = { [unowned self] in
            self.containerWindow.rootViewController?.view.layoutIfNeeded()
            if let keyWindow = UIApplication.shared.keyWindow {
                keyWindow.frame.origin.y = self.alertViewHeight
                keyWindow.frame.size.height = UIScreen.main.bounds.height - self.alertViewHeight
            }
        }
        
        hideAnimator.stopAnimation(true)
        showAnimator.stopAnimation(true)
        
        showAnimator.addAnimations(animation)
        showAnimator.addCompletion { [unowned self] (position) in
            if position == .end {
                self.isShown = true
                animationCompleted()
            }
        }
        showAnimator.startAnimation()
    }
    

    
    private func performHideAnimation(animated: Bool) {
        
        if hideAnimator.isRunning {
            return
        }
        
        if showAnimator.isRunning {
            showAnimator.stopAnimation(true)
        }
        
        topLayoutConstraint?.constant = -alertViewHeight
        let animation: ()->Void = { [unowned self] in
            self.containerWindow.rootViewController?.view.layoutIfNeeded()
            if let keyWindow = UIApplication.shared.keyWindow {
                keyWindow.frame.origin.y = 0
                keyWindow.frame.size.height = UIScreen.main.bounds.height
            }
        }
        hideAnimator.addAnimations(animation)
        hideAnimator.addCompletion { [unowned self] (position) in
            if position == .end {
                self.containerWindow.isHidden = true
                self.isShown = false
            }
        }
        
        if !hideAnimator.isRunning {
            hideAnimator.startAnimation()
        }
        
    }
}


// MARK: - Convenience method -
extension YHStatusBarMessage {
    public func showErrorMessage(_ text: String) {
        textLabel.font = UIFont.systemFont(ofSize: 13)
        textLabel.textColor = UIColor.white
        backgroundColor = UIColor.red
        statusBarStyle = UIStatusBarStyle.lightContent
        show(message: text, duration: nil)
    }
}



// MARK: - Helper class -
fileprivate class WindowController: UIViewController {
    
    var statusBarStyle: UIStatusBarStyle? {
        didSet{
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle ?? UIApplication.shared.statusBarStyle
    }
}
