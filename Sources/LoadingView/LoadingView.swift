//
//  LoadingView.swift
//  Rise
//
//  Created by Владимир Королев on 10.10.2019.
//  Copyright © 2019 VladimirBrejcha. All rights reserved.
//

import UIKit

public enum LoadingViewState: Equatable {
    case hidden
    case loading
    case info (message: String)
    case error (message: String)
}

@IBDesignable
open class LoadingView: UIView {
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.alpha = 0
        return label
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let animationView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.alpha = 0
        return view
    }()
    
    private let errorContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.alpha = 0
        return view
    }()
        
    // MARK: - Background view
    private let defaultCornerRadius: CGFloat = 12
    @IBInspectable public var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    private let defaultBackgroundColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.03)
    @IBInspectable public var color: UIColor? {
        get { backgroundColor }
        set { backgroundColor = newValue }
    }
    
    // MARK: - Repeat button
    private let repeatButton: Button = {
        let button = Button()
        button.addTarget(self, action: #selector(repeatTouchUp(_:)), for: .touchUpInside)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return button
    }()
    
    private let defaultButtonTitle: String = "repeat"
    @IBInspectable public var buttonTitle: String? {
        get { repeatButton.titleLabel?.text }
        set { repeatButton.setTitle(newValue, for: .normal) }
    }
    
    @IBInspectable public var buttonCornerRadius: CGFloat {
        get { repeatButton.layer.cornerRadius }
        set { repeatButton.layer.cornerRadius = newValue }
    }
    
    @IBInspectable public var buttonColor: UIColor? {
        get { repeatButton.backgroundColor }
        set { repeatButton.backgroundColor = newValue }
    }
    
    public var repeatTouchUpHandler: ((UIButton) -> Void)?
    
    // MARK: - Loading animation
    private var initialAnimationSetup: (() -> Void)?
    private var afterBackgroundAnimationSetup: (() -> Void)?
    
    public var loadingAnimation: Animation? {
        didSet {
            loadingAnimation?.add(on: animationView.layer)
        }
    }
    
    // MARK: - State
    public var animateStateChanges: Bool = true
    private let initialState: LoadingViewState = .hidden
    public var state: LoadingViewState = .hidden {
        didSet {
            if oldValue == state { return }
            
            log("state changed from \(oldValue) to \(state)")
            
            let animation = makeAnimation(from: oldValue, to: state)
            animateStateChanges
                ? execute(animation: animation)
                : animation()
        }
    }
    
    private let animator: UIViewPropertyAnimator = {
        UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
    }()
    
    // MARK: - Init -
    override public init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
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
        
        repeatButton.setTitle(defaultButtonTitle, for: .normal)
        layer.cornerRadius = defaultCornerRadius
        backgroundColor = defaultBackgroundColor
        state = initialState
        
        initialAnimationSetup = { [weak self] in
            guard let self = self else { return }
            if self.loadingAnimation == nil {
                self.loadingAnimation = PulsingCircleAnimation()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func willEnterForeground() {
        afterBackgroundAnimationSetup = { [weak self] in
            guard let self = self else { return }
            self.loadingAnimation?.removeFromSuperlayer()
            self.loadingAnimation?.add(on: self.animationView.layer)
        }
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if initialAnimationSetup != nil {
            initialAnimationSetup?()
            initialAnimationSetup = nil
            return
        }
        
        afterBackgroundAnimationSetup?()
        afterBackgroundAnimationSetup = nil
    }

    
    @objc private func repeatTouchUp(_ sender: Button) {
        repeatTouchUpHandler?(sender)
    }
    
    // MARK: - Private -
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
        
        if oldState == .hidden {
            return showBoth(oldView, newView)
        } else if newState == .hidden {
            return hideBoth(oldView, newView)
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

