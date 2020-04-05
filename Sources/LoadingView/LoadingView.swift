//  LoadingView.swift
//
//  Created by Владимир Королев on 21.03.2020.
//  Copyright © 2020 VladimirBrejcha. All rights reserved.
//

import UIKit

/// Declares `state` of a `LoadingView`.
public enum LoadingViewState: Equatable {
    /// View is fully hidden.
    case hidden
    /// View is showing loading animation.
    case loading
    /// View is showing information with the given `message`.
    case info (message: String)
    /// View is showing error with the given messsage and repeat button.
    case error (message: String)
}

@IBDesignable
open class LoadingView: UIView {
    // MARK: - Self -
    @IBInspectable public var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    @IBInspectable public var color: UIColor? {
        get { backgroundColor }
        set { backgroundColor = newValue }
    }
    
    // MARK: - States -
    
    /// Logs every `state` change
    /// Default is `false`
    public var logStateChanges: Bool = false
    
    /// Declares if `state` should be changed with animation;
    /// Default is `true`.
    public var animateStateChanges: Bool = true
    
    /// Returns `self` state;
    /// Sets `self` state and updates UI;
    /// If `animateStateChanges` set to `true` then cross dissolve animation will be used for UI update;
    /// Default is `.hidden`.
    public var state: LoadingViewState = .hidden {
        didSet {
            if oldValue == state { return }
            
            if logStateChanges {
                log("state changed from \(String(describing: oldValue)) to \(String(describing: state))")
            }
            
            let animation = makeAnimation(from: oldValue, to: state)
            animateStateChanges
                ? execute(animation: animation)
                : animation()
        }
    }
    private let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
    
    // MARK: - State: Loading -
    private let animationView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.alpha = 0
        return view
    }()
    
    private typealias OnDraw = () -> Void
    private var onDraw: OnDraw?
    private func append(to oldDraw: OnDraw?, _ draw: @escaping OnDraw) -> OnDraw { {
        oldDraw?()
        draw()
    } }
    
    /// Returns animation used for `.loading` state;
    /// Sets animation used for `.loading` state (removing old animation);
    /// Setting this value will call `setNeedsDisplay` on `self`;
    /// Default is `PulsingCircleAnimation`.
    public var loadingAnimation: Animation = PulsingCircleAnimation() {
        didSet {
            onDraw = append(to: onDraw, { [weak self] in
                guard let self = self else { return }
                oldValue.removeFromSuperlayer()
                self.loadingAnimation.add(on: self.animationView.layer)
            })
            setNeedsDisplay()
        }
    }
    
    // MARK: - State: Info -
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.text = "An example information message"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.alpha = 0
        return label
    }()
    
    public var infoLabelFont: UIFont {
        get { infoLabel.font }
        set { infoLabel.font = newValue }
    }
    
    @IBInspectable public var infoLabelColor: UIColor {
        get { infoLabel.textColor }
        set { infoLabel.textColor = newValue }
    }
    
    // MARK: - State: Error -
    private let errorContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.alpha = 0
        return view
    }()
    
    // MARK: - Error label
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.text = "An error occurred"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    public var errorLabelFont: UIFont {
        get { errorLabel.font }
        set { errorLabel.font = newValue }
    }
    
    @IBInspectable public var errorLabelColor: UIColor {
        get { errorLabel.textColor }
        set { errorLabel.textColor = newValue }
    }
    
    // MARK: - Repeat button
    private let repeatButton: Button = {
        let button = Button()
        button.setTitle("repeat", for: .normal)
        button.addTarget(self, action: #selector(repeatTouchUp(_:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return button
    }()

    @IBInspectable public var buttonTitle: String? {
        get { repeatButton.titleLabel?.text }
        set { repeatButton.setTitle(newValue, for: .normal) }
    }
    
    @IBInspectable public var buttonTitleFont: UIFont? {
        get { repeatButton.titleLabel?.font }
        set { repeatButton.titleLabel?.font = newValue }
    }
    
    @IBInspectable public var buttonTitleColor: UIColor? {
        get { repeatButton.titleColor(for: .normal) }
        set { repeatButton.setTitleColor(newValue, for: .normal) }
    }
    
    @IBInspectable public var buttonCornerRadius: CGFloat {
        get { repeatButton.layer.cornerRadius }
        set { repeatButton.layer.cornerRadius = newValue }
    }
    
    @IBInspectable public var buttonColor: UIColor? {
        get { repeatButton.backgroundColor }
        set { repeatButton.backgroundColor = newValue }
    }
    
    /// Called on every `repeatButton` touch up inside.
    public var repeatTouchUpHandler: ((UIButton) -> Void)?
    
    // MARK: - LifeCycle -
    override public init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        clipsToBounds = true
        layer.cornerRadius = 12
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.03)
        alpha = 0
        
        addSubview(infoLabel)
        addSubview(animationView)
        addSubview(errorContainerView)
        errorContainerView.addSubview(repeatButton)
        errorContainerView.addSubview(errorLabel)
        
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        infoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        animationView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        animationView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        animationView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

        errorContainerView.translatesAutoresizingMaskIntoConstraints = false
        errorContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        errorContainerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
        errorContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        errorContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        errorContainerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        errorContainerView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        repeatButton.translatesAutoresizingMaskIntoConstraints = false
        repeatButton.heightAnchor.constraint(lessThanOrEqualToConstant: 30).isActive = true
        repeatButton.widthAnchor.constraint(equalToConstant: 90).isActive = true
        repeatButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 10).isActive = true
        repeatButton.centerXAnchor.constraint(equalTo: errorContainerView.centerXAnchor).isActive = true
        repeatButton.bottomAnchor.constraint(equalTo: errorContainerView.bottomAnchor).isActive = true

        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.centerXAnchor.constraint(equalTo: errorContainerView.centerXAnchor).isActive = true
        errorLabel.topAnchor.constraint(equalTo: errorContainerView.topAnchor).isActive = true
        errorLabel.leadingAnchor.constraint(equalTo: errorContainerView.leadingAnchor).isActive = true
        errorLabel.trailingAnchor.constraint(equalTo: errorContainerView.trailingAnchor).isActive = true
        
        onDraw = { [weak self] in
            guard let self = self else { return }
            self.loadingAnimation.add(on: self.animationView.layer)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func willEnterForeground() {
        onDraw = append(to: onDraw) { [weak self] in
            guard let self = self else { return }
            self.loadingAnimation.removeFromSuperlayer()
            self.loadingAnimation.add(on: self.animationView.layer)
        }
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        onDraw?()
        onDraw = nil
    }
    
    @objc private func repeatTouchUp(_ sender: Button) {
        repeatTouchUpHandler?(sender)
    }
    
    private typealias AnimatorAnimation = () -> Void
    private typealias ViewAnimation = (UIView, UIView) -> AnimatorAnimation
    
    private func makeView(for state: LoadingViewState) -> UIView {
        switch state {
        case .hidden:
            return self
        case .loading:
            return animationView
        case .info(let message):
            infoLabel.text = message
            return infoLabel
        case .error(let message):
            errorLabel.text = message
            return errorContainerView
        }
    }
    
    private func makeAnimation(from oldState: LoadingViewState, to newState: LoadingViewState) -> AnimatorAnimation {
        let oldView = makeView(for: oldState)
        let newView = makeView(for: newState)
        if newState == .hidden {
            return hideBoth(oldView, newView)
        } else if oldState == .hidden {
            return showBoth(oldView, newView)
        } else {
            return crossDissolve(oldView, newView)
        }
    }
    
    private func execute(animation: @escaping AnimatorAnimation) {
        if animator.state != .inactive {
            animator.stopAnimation(false)
            animator.finishAnimation(at: .end)
        }
        animator.addAnimations(animation)
        animator.startAnimation()
    }
    
    private let crossDissolve: ViewAnimation = { oldView, newView in {
        oldView.alpha = 0
        newView.alpha = 1
        }
    }
    private let hideBoth: ViewAnimation = { oldView, newView in {
        oldView.alpha = 0
        newView.alpha = 0
        }
    }
    private let showBoth: ViewAnimation = { oldView, newView in {
        oldView.alpha = 1
        newView.alpha = 1
        }
    }
}

