//
//  Range.swift
//  
//
//  Created by Владимир Королев on 21.03.2020.
//

import Foundation

struct Range<T> {
    let from: T
    let to: T
}

extension Range {
    var inverted: Self { Range(from: self.to, to: self.from) }
}
