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
    case content (contentView: UIView)
    case info (message: String)
    case error (message: String)
}

@IBDesignable
open class LoadingView: UIView, NibLoadable {
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var errorContainerView: UIView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var animationView: UIView!
    
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
    @IBOutlet private weak var repeatButton: Button!
    
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
    private let defaultLoadingAnimation: Animation = PulsingCircleAnimation()
    public var loadingAnimation: Animation? {
        didSet {
            loadingAnimation?.add(on: animationView)
        }
    }
    
    // MARK: - State
    public var animateStateChanges: Bool = true
    public var state: LoadingViewState = .hidden {
        didSet {
            crossDisolve(from: chooseView(for: oldValue),
                         to: prepareView(for: state),
                         animated: animateStateChanges)
        }
    }
    
    private let animator: UIViewPropertyAnimator = {
        UIViewPropertyAnimator(duration: 0.1, curve: .easeInOut)
    }()
    
    // MARK: - Init -
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupFromNib()
        sharedInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupFromNib()
        sharedInit()
    }
    
    private func sharedInit() {
        layer.cornerRadius = defaultCornerRadius
        backgroundColor = defaultBackgroundColor
        loadingAnimation = defaultLoadingAnimation
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
    }

    @IBAction private func repeatTouchUp(_ sender: Button) {
        repeatTouchUpHandler?(sender)
    }
    
    // MARK: - Private -
    private func chooseView(for state: LoadingViewState) -> UIView {
        switch state {
        case .hidden:
            return self
        case .content (let contentView):
            return contentView
        case .error:
            return errorContainerView
        case .info:
            return infoLabel
        case .loading:
            return animationView
        }
    }
    
    private func prepareView(for state: LoadingViewState) -> UIView {
        switch state {
        case .hidden:
            return self
        case .content (let contentView):
            return contentView
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
    
    private func crossDisolve(from oldView: UIView, to newView: UIView, animated: Bool) {
        if animator.state != .inactive {
            animator.stopAnimation(false)
            animator.finishAnimation(at: .end)
        }
        
        if !animated {
            oldView.alpha = 0
            newView.alpha = 1
            return
        }
        
        animator.addAnimations {
            oldView.alpha = 0
            newView.alpha = 1
        }
        
        animator.startAnimation()
    }
}

