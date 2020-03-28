//  AnimationSettings.swift
//
//  Created by Владимир Королев on 21.03.2020.
//  Copyright © 2020 VladimirBrejcha. All rights reserved.
//

import UIKit

struct AnimationSettings {
    let range: Range<CGFloat>
    let duration: CFTimeInterval
    let repeatCount: Float
    let removedOnCompletion: Bool
}

extension AnimationSettings {
    var rangeInverted: Self {
        AnimationSettings(
            range: range.inverted,
            duration: duration,
            repeatCount: repeatCount,
            removedOnCompletion: removedOnCompletion
        )
    }
}
