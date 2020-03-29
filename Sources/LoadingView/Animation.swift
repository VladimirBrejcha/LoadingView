//  Animation.swift
//
//  Created by Владимир Королев on 21.03.2020.
//  Copyright © 2020 VladimirBrejcha. All rights reserved.
//

import UIKit

public protocol Animation {
    /// Adds `self` on the given `CALayer`
    func add(on layer: CALayer)
    /// Removes `self` from the superlayer
    func removeFromSuperlayer()
}
