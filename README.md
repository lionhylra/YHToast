# YHToast
A simple toast for iOS apps written in swift.

![demo](/resources/demo.gif)

# YHStatusBarMessage

The YHStatusBarMessage displays a message right below status bar without crashing into your view.

![YHStatusBarMessage](/resources/screenshot1.png)

### Public methods
```swift
	/// Show the message under the status bar
    ///
    /// - Parameters:
    ///   - message: The text to show
    ///   - duration: if nil, the message view won't hide automatically. if a TimeInterval is given, it will hide automatically after the duration.
    ///   - animated: a flag indicating whether it animates to show/hide
	public func show(message: String, duration: TimeInterval?, animated: Bool = true)
	public func hide(animated: Bool = true)
```

### How to use
YHStatusBarMessage is a singleton. Before you show it, you need to configue the colour and text.

```swift
	YHStatusBarMessage.shared.textLabel.font = UIFont.systemFont(ofSize: 13)
	YHStatusBarMessage.shared.textLabel.textColor = UIClor.white
	YHStatusBarMessage.shared.backgroundColor = UIColor.red
	YHStatusBarMessage.shared.statusBarStyle = UIStatusBarStyle.lightContent
	YHStatusBarMessage.shared.show(message: text, duration: nil)
```

### You can also use a convenient method. In this method, it does the code shown above.
```swift
	public func showErrorMessage(_ text: String)
```

# YHToast
This is a toast compoent similar to what Android provides.
It support different styles and different positions.
You can call  show(...) method whenever you can, regardless the current toast is animating to show/hide, or is shown. 
If you show a toast with duration and the call show() again, the previously schedualed hide animation will be canceled.

```swift
	public enum YHToastStyle {

        case `default`<<error type>>

        case blurred<<error type>>
    }

    public enum YHToastPosition {

        case center

        case top

        case bottom

        case topLeft

        case topRight

        case bottomLeft

        case bottomRight
    }

    public struct YHToastConfiguration {

        public var style: YHToastStyle

        public var cornerRadius: CGFloat

        public var position: YHToastPosition

        public var maximumWidthRatio: CGFloat

        public var margin: CGFloat

        public var animated: Bool

        public var durationForShowAnimation: TimeInterval

        public var durationForHideAnimation: TimeInterval
    }
```

### How to use
```swift
	//Use it with default configration
	YHToast.shared.show(message: "Text to show", duration: 2)// Show the text in the center of screen for 2 seconds
```

```swift
	//Change the default configuration and then show
	YHToast.shared.defaultConfiguration.position = .bottomRight
	YHToast.shared.defaultConfiguration.style = .blurred(.extraLight)//The text color will be changed automatically to black
    YHToast.shared.defaultConfiguration.cornerRadius = 20
    YHToast.shared.show(message: "Text to show", duration: 2)
```

```swift
	//Use ad-hoc configuration to override default configuration
	YHToast.shared.show(message: "Text to show", duration: 2, style: .blurred(.dark), position: .center)

	//Or provide your own configuration
	var myConfig = YHToast.shared.defaultConfiguration
	myConfig.durationForHideAnimation = 1
	myConfig.position = .top
	myConfig.margin = 30//the bigger number, the farther toast is from edge of screen
	YHToast.shared.show(message: "Text to show", duration: nil, configuration: myConfig)//Don't hide automatically

	//Hide it manually
	YHToast.shared.hide(configuration: myConfig)
```

```swift
	//more advanced usage: you can change the font of text label
	YHToast.shared.textLabel.font = ...
```