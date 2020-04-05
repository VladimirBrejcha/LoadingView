# LoadingView

LoadingView is an highly customizable and easy to use UI element for showing loading status written in Swift.

![Preview](https://github.com/VladimirBrejcha/LoadingViewExample/blob/master/LoadingViewExample/preview.gif)

## Features

- [x] Show animated loading
- [x] Show an information message
- [x] Show an error message with repeat button
- [x] Customize colors, fonts, animations
- [x] Import your own loading animation
- [x] Use in code or from interface builder

## Requirements

- iOS 11.0+
- Xcode 11+
- Swift 5.1+

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Use Xcode’s new Swift Packages option, which is located within the File menu.

## Usage example

[ExampleApp](https://github.com/VladimirBrejcha/LoadingViewExample)

```Swift
import LoadingView

class ViewController: UIViewController {
    @IBOutlet weak var loadingView: LoadingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.repeatTouchUpHandler = { button in
            // handle repeatButton touches
        }
        loadingView.state = .loading // set loadingView state
    }
}
```

## States

#### hidden
View is fully hidden
#### loading
View is showing loading animation
#### info
View is showing information with the given message
#### error
View is showing error with the given messsage and repeat button

## Advanced

### Use your own animations instead of default PulsingCircleAnimation

Create an animation and conform it to the [Animation](Sources/LoadingView/Animation.swift) protocol.
Set the loadingAnimation property.
```Swift
loadingView.loadingAnimation = MyAnimation() // must conform to Animation protocol
```

### Turn on state change logging

```Swift
loadingView.logStateChanges = true // enable logging if needed
```

## Credits

Example photo by Jason Leung on Unsplash

## License

LoadingView is released under the MIT license. [See LICENSE](LICENSE) for details.
