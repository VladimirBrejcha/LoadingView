//
//  Animation.swift
//  
//
//  Created by Владимир Королев on 21.03.2020.
//

import UIKit

public protocol Animation {
    func add(on layer: CALayer)
    func removeFromSuperlayer()
}
