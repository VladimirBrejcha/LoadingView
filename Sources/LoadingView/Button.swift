//
//  Button.swift
//  
//
//  Created by Владимир Королев on 21.03.2020.
//

import UIKit

final class Button: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.07)
        layer.cornerRadius = 12
        setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5), for: .disabled)
        addTarget(self, action: #selector(backToNormalSize(_:)),
                  for: [.touchDragOutside, .touchCancel, .touchUpInside, .touchUpOutside])
        addTarget(self, action: #selector(decreaseButtonSize(_:)),
                  for: [.touchDown, .touchDragInside])
    }
    
    @objc private func decreaseButtonSize(_ sender: Button) {
        UIViewPropertyAnimator(duration: 0.1, curve: .easeInOut) {
             sender.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
        }.startAnimation()
    }
    
    @objc private func backToNormalSize(_ sender: UIButton) {
        UIViewPropertyAnimator(duration: 0.1, curve: .easeInOut) {
            sender.transform = CGAffineTransform.identity
        }.startAnimation()
    }
}
