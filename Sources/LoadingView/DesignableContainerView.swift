//
//  File.swift
//  
//
//  Created by Владимир Королев on 21.03.2020.
//

import UIKit

@IBDesignable
class DesignableContainerView: UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    @IBInspectable var background: UIColor? {
        get { backgroundColor }
        set { backgroundColor = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit() {
        background = Color.defaultContainerBackground
        cornerRadius = 12
        clipsToBounds = true
    }
}
