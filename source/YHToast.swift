//
//  YHToast.swift
//  Swift3Project
//
//  Created by Yilei on 1/5/17.
//  Copyright © 2017 lionhylra.com. All rights reserved.
//

import UIKit

public class YHToast {
    public enum YHToastStyle {
        case `default`(tintColor: UIColor, backgroundColor: UIColor)
        case blurred(UIBlurEffectStyle)
    }
    
    
    
    public enum YHToastPosition {
        case center
        case top
        case bottom
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }
    
    
    public struct YHToastConfiguration {
        public var style: YHToastStyle
        public var cornerRadius: CGFloat
        public var position: YHToastPosition
        public var maximumWidthRatio: CGFloat
        public var margin: CGFloat
        public var animated: Bool
        public var durationForShowAnimation: TimeInterval
        public var durationForHideAnimation: TimeInterval
    }
    
    
    
    public static let shared = YHToast()
    
    
    // MARK: - UI Properties -
    private var _window: UIWindow?
    
    fileprivate var window: UIWindow! {
        get {
            if _window == nil {
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.windowLevel = (UIApplication.shared.keyWindow?.windowLevel ?? UIWindowLevelNormal) + 1
                window.isUserInteractionEnabled = false
                let rootViewController = UIViewController()
                window.rootViewController = rootViewController
                _window = window
            }
            return _window
        }
        set {
            _window = newValue
        }
    }
    
    fileprivate var rootView: UIView {
        return window.rootViewController!.view
    }
    
    fileprivate let _contentView: YHToastView = YHToastView()
    
    
    public var textLabel: UILabel {
        return _contentView.textLabel
    }
    
    public var contentView: UIView {
        return _contentView
    }
    
    
    // MARK: - Configuration -
    public var defaultConfiguration: YHToastConfiguration
        = YHToastConfiguration(style: .blurred(.dark),
                               cornerRadius: 10,
                               position: .center,
                               maximumWidthRatio: 0.8,
                               margin: 20,
                               animated: true,
                               durationForShowAnimation: 0.25,
                               durationForHideAnimation: 0.45)
    
    
    // MARK: - private properties -
    private var positioningConstraints: [NSLayoutConstraint] = []
    
    fileprivate var animatorForShow: UIViewPropertyAnimator?
    
    fileprivate var animatorForHide: UIViewPropertyAnimator?
    
    fileprivate var timer: Timer?
    
    // MARK: - Initializer -
    init() {
        
    }
    
    
    deinit {
        _contentView.removeFromSuperview()
        window.isHidden = true
        window = nil
    }
    
    
    // MARK: - animation methods -
    private func performShowAnimation(configuration: YHToastConfiguration, animationCompleted: @escaping () -> Void) {
        if !configuration.animated {
            _contentView.alpha = 1
            animationCompleted()
            return
        }
        
        switch configuration.style {
        case .default(_, _):
            animatorForShow = UIViewPropertyAnimator(duration: configuration.durationForShowAnimation, curve: .linear, animations: { [weak self] in
                self?._contentView.alpha = 1
            })
            animatorForShow?.addCompletion({ (_) in
                animationCompleted()
            })
            animatorForShow?.startAnimation()
        case .blurred(_):
            _contentView.alpha = 1
            let snapshotView = _contentView.snapshotView(afterScreenUpdates: true)!
            snapshotView.frame = _contentView.frame
            rootView.addSubview(snapshotView)
            _contentView.alpha = 0
            snapshotView.alpha = 0
            animatorForShow = UIViewPropertyAnimator(duration: configuration.durationForShowAnimation, curve: .linear, animations: {
                snapshotView.alpha = 1
            })
            
            animatorForShow?.addCompletion({ [weak self] (_) in
                snapshotView.removeFromSuperview()
                self?._contentView.alpha = 1
                animationCompleted()
            })
            
            animatorForShow?.startAnimation()
        }
    }
    
    
    private func performHideAnimation(configuration: YHToastConfiguration, animationCompleted: @escaping () -> Void) {
        if !configuration.animated {
            _contentView.alpha = 0
            animationCompleted()
            return
        }
        
        switch configuration.style {
        case .default(_, _):
            animatorForShow = UIViewPropertyAnimator(duration: configuration.durationForShowAnimation, curve: .linear, animations: { [weak self] in
                self?._contentView.alpha = 0
            })
            animatorForShow?.addCompletion({ (_) in
                animationCompleted()
            })
            animatorForShow?.startAnimation()
        case .blurred(_):
            let currentAlpha = _contentView.alpha
            _contentView.alpha = 1
            let snapshotView = _contentView.snapshotView(afterScreenUpdates: true)!
            snapshotView.frame = _contentView.frame
            rootView.addSubview(snapshotView)
            _contentView.alpha = 0
            snapshotView.alpha = currentAlpha
            animatorForShow = UIViewPropertyAnimator(duration: configuration.durationForShowAnimation, curve: .linear, animations: {
                snapshotView.alpha = 0
            })
            
            animatorForShow?.addCompletion({ (_) in
                snapshotView.removeFromSuperview()
                animationCompleted()
            })
            
            animatorForShow?.startAnimation()
        }
    }
    
    
    // MARK: - Public Methods -
    public func show(message: String, duration: TimeInterval?, configuration: YHToastConfiguration? = nil) {
        animatorForShow?.stopAnimation(false)
        animatorForShow?.finishAnimation(at: .current)
        animatorForHide?.stopAnimation(false)
        animatorForHide?.finishAnimation(at: .current)
        timer?.invalidate()
        window.isHidden = false
        
        let configuration = configuration ?? defaultConfiguration
        
        if !_contentView.isDescendant(of: rootView) {
            rootView.addSubview(_contentView)
        }
        
        _contentView.textLabel.text = message
        configurateContentView(_contentView, with: configuration)
        _contentView.layoutIfNeeded()//This line makes the _contentView to adjust it's size immediately according to the text content
        
        performShowAnimation(configuration: configuration) { [weak self] in
            guard let duration = duration else {
                return
            }
            
            self?.timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: { [weak self] (_) in
                self?.performHideAnimation(configuration: configuration) { [weak self] in
                    self?._contentView.removeFromSuperview()
                    self?.window.isHidden = true
                    self?.window = nil
                }
            })
        }
    }
    
    
    public func show(message: String, duration: TimeInterval?, style: YHToastStyle?, position: YHToastPosition?) {
        let configuration = YHToastConfiguration(style: style ?? defaultConfiguration.style,
                                                 cornerRadius: defaultConfiguration.cornerRadius,
                                                 position: position ?? defaultConfiguration.position,
                                                 maximumWidthRatio: defaultConfiguration.maximumWidthRatio,
                                                 margin: defaultConfiguration.margin,
                                                 animated: defaultConfiguration.animated,
                                                 durationForShowAnimation: defaultConfiguration.durationForShowAnimation,
                                                 durationForHideAnimation: defaultConfiguration.durationForHideAnimation)
        show(message: message, duration: duration, configuration: configuration)
    }
    
    
    
    public func hide(configuration: YHToastConfiguration? = nil) {
        animatorForShow?.stopAnimation(false)
        animatorForShow?.finishAnimation(at: .current)
        animatorForHide?.stopAnimation(false)
        animatorForHide?.finishAnimation(at: .current)
        
        timer?.invalidate()
        let configuration = configuration ?? defaultConfiguration
        performHideAnimation(configuration: configuration) { [weak self] in
            self?._contentView.removeFromSuperview()
            self?.window.isHidden = true
            self?.window = nil
        }
    }
    
    
    private func configurateContentView(_ contentView: YHToastView, with configuration: YHToastConfiguration) {
        
        _contentView.style = configuration.style
        _contentView.layer.cornerRadius = configuration.cornerRadius
        updatePositioningConstraints(position: configuration.position, margin: configuration.margin, maxWidthRatio: configuration.maximumWidthRatio)
    }
    
    
    private func updatePositioningConstraints(position: YHToastPosition, margin: CGFloat, maxWidthRatio: CGFloat) {
        NSLayoutConstraint.deactivate(positioningConstraints)
        positioningConstraints = []
        switch position {
        case .center, .bottom, .top:
            positioningConstraints.append(
                NSLayoutConstraint(item: _contentView, attribute: .centerX, relatedBy: .equal, toItem: rootView, attribute: .centerX, multiplier: 1, constant: 0)
            )
        case .bottomLeft, .topLeft:
            positioningConstraints.append(
                NSLayoutConstraint(item: _contentView, attribute: .leading, relatedBy: .equal, toItem: rootView, attribute: .leading, multiplier: 1, constant: margin)
            )
        case .bottomRight, .topRight:
            positioningConstraints.append(
                NSLayoutConstraint(item: _contentView, attribute: .trailing, relatedBy: .equal, toItem: rootView, attribute: .trailing, multiplier: 1, constant: -margin)
            )
        }
        
        switch position {
        case .center:
            positioningConstraints.append(
                NSLayoutConstraint(item: _contentView, attribute: .centerY, relatedBy: .equal, toItem: rootView, attribute: .centerY, multiplier: 1, constant: 0)
            )
        case .bottom, .bottomLeft, .bottomRight:
            positioningConstraints.append(
                NSLayoutConstraint(item: _contentView, attribute: .bottom, relatedBy: .equal, toItem: rootView, attribute: .bottom, multiplier: 1, constant: -margin)
            )
        case .top, .topLeft, .topRight:
            positioningConstraints.append(
                NSLayoutConstraint(item: _contentView, attribute: .top, relatedBy: .equal, toItem: rootView, attribute: .top, multiplier: 1, constant: margin)
            )
        }
        
        
        positioningConstraints.append(
            NSLayoutConstraint(item: _contentView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: rootView, attribute: .width, multiplier: maxWidthRatio, constant: 0)
        )
        NSLayoutConstraint.activate(positioningConstraints)
    }
}




fileprivate class YHToastView: UIView {

    let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    
    var style: YHToast.YHToastStyle = .blurred(.dark) {
        didSet {
            toastStyleUpdated()
        }
    }
    
    
    fileprivate let blurEffectView = UIVisualEffectView()
    
    fileprivate let vibrancyEffectView = UIVisualEffectView()

    
    init() {
        super.init(frame: CGRect.zero)
        
        layer.cornerRadius = 10
        clipsToBounds = true
        alpha = 0
        isUserInteractionEnabled = false
        toastStyleUpdated()
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(blurEffectView)
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        vibrancyEffectView.frame = blurEffectView.contentView.bounds
        vibrancyEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.frame = bounds
        
        
        
        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            NSLayoutConstraint(item: textLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: textLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: textLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -8),
            NSLayoutConstraint(item: textLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -8)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func toastStyleUpdated() {
        switch style {
        case .blurred(let effectStyle):
            let blurEffect = UIBlurEffect(style: effectStyle)
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
            blurEffectView.effect = blurEffect
            vibrancyEffectView.effect = vibrancyEffect
            
            switch effectStyle {
            case .dark:
                textLabel.textColor = UIColor.white
            case .light, .extraLight:
                textLabel.textColor = UIColor.darkText
            default:
                textLabel.textColor = UIColor.darkText
            }
            
            backgroundColor = nil
            blurEffectView.isHidden = false
        case .default(let tintColor, let backgroundColor):
            self.backgroundColor = backgroundColor
            textLabel.textColor = tintColor
            
            blurEffectView.isHidden = true
        }
    }
}
