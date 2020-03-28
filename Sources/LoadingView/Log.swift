//  Log.swift
//
//  Created by Владимир Королев on 21.03.2020.
//  Copyright © 2020 VladimirBrejcha. All rights reserved.
//

import Foundation

fileprivate let logDomain: String = "LoadingView"

func log(_ message: String) {
    print("[\(logDomain): \(message)]")
}
