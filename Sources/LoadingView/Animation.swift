//  Animation.swift
//
//  Created by Владимир Королев on 21.03.2020.
//  Copyright © 2020 VladimirBrejcha. All rights reserved.
//

import UIKit

public protocol Animation {
    func add(on layer: CALayer)
    func removeFromSuperlayer()
}
