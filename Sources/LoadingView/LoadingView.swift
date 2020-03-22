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
            loadingAnimation?.add(on: animationView)
        }
    }
    
    // MARK: - State
    public var animateStateChanges: Bool = true
    private let initialState: LoadingViewState = .hidden
    public var state: LoadingViewState = .hidden {
        didSet {
            if oldValue == state { return }
            
            log("state changed from \(oldValue) to \(state)")
            
            crossDisolve(from: chooseView(for: oldValue),
                         to: prepareView(for: state),
                         animated: animateStateChanges)
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
        initialAnimationSetup = { [weak self] in
            guard let self = self else { return }
            if self.loadingAnimation == nil {
                self.loadingAnimation = PulsingCircleAnimation()
            }
        }
        state = initialState
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive),
                                               name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc private func applicationWillResignActive() {
        afterBackgroundAnimationSetup = { [weak self] in
            guard let self = self else { return }
            self.loadingAnimation?.add(on: self.animationView)
        }
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        initialAnimationSetup?()
        initialAnimationSetup = nil
        
        afterBackgroundAnimationSetup?()
        afterBackgroundAnimationSetup = nil
    }

    
    @objc private func repeatTouchUp(_ sender: Button) {
        repeatTouchUpHandler?(sender)
    }
    
    // MARK: - Private -
    private func chooseView(for state: LoadingViewState) -> UIView? {
        switch state {
        case .hidden:
            return nil
        case .error:
            return errorContainerView
        case .info:
            return infoLabel
        case .loading:
            loadingAnimation?.animate(false)
            return animationView
        }
    }
    
    private func prepareView(for state: LoadingViewState) -> UIView? {
        switch state {
        case .hidden:
            return nil
        case .error(let error):
            errorLabel.text = error
            return errorContainerView
        case .info(let info):
            infoLabel.text = info
            return infoLabel
        case .loading:
            loadingAnimation?.animate(true)
            return animationView
        }
    }
    
    private func crossDisolve(from oldView: UIView?, to newView: UIView?, animated: Bool) {
        if animator.state != .inactive {
            animator.stopAnimation(false)
            animator.finishAnimation(at: .end)
        }
        
        if !animated {
            oldView?.alpha = 0
            newView?.alpha = 1
            return
        }
        
        animator.addAnimations {
            oldView?.alpha = 0
            newView?.alpha = 1
        }
        
        animator.startAnimation()
    }
}

