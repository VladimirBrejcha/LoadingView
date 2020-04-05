//  Copyright © 2020 VladimirBrejcha. All rights reserved.

import Foundation

struct Range<T> {
    let from: T
    let to: T
}

extension Range {
    var inverted: Self { Range(from: to, to: from) }
}
