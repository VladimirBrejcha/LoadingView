//  Copyright © 2020 VladimirBrejcha. All rights reserved.

import UIKit

public protocol Animation {
    /// Adds `self` on the given `CALayer`.
    func add(on layer: CALayer)
    /// Removes `self` from the superlayer.
    func removeFromSuperlayer()
}
