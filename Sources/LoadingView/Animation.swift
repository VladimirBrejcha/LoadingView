//
//  Animation.swift
//  
//
//  Created by Владимир Королев on 21.03.2020.
//

import UIKit

public protocol Animation {
    func add(on view: UIView)
    func removeFromSuperlayer() 
    func animate(_ animate: Bool)
}
