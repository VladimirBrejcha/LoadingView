//  Copyright © 2020 VladimirBrejcha. All rights reserved.

import Foundation

/// Declares `state` of a `LoadingView`.
public enum LoadingViewState: Equatable {
    /// View is fully hidden.
    case hidden
    /// View is showing loading animation.
    case loading
    /// View is showing information with the given `message`.
    case info (message: String)
    /// View is showing error with the given `messsage` and repeat button.
    case error (message: String)
}
