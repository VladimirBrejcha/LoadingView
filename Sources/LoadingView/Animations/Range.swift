//  Range.swift
//
//  Created by Владимир Королев on 21.03.2020.
//  Copyright © 2020 VladimirBrejcha. All rights reserved.
//

import Foundation

struct Range<T> {
    let from: T
    let to: T
}

extension Range {
    var inverted: Self { Range(from: to, to: from) }
}
