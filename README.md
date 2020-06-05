# VKAlertController
[![Language](https://img.shields.io/badge/Swift-5.0-orange)](https://developer.apple.com/swift/)
[![Language](https://img.shields.io/badge/iOS-10%2B-brightgreen)](https://www.apple.com/ios/ios-13/)
[![Pod version](https://img.shields.io/badge/pod-v1.0.0-blue)](https://cocoapods.org/pods/VKAlertController)
[![License](https://img.shields.io/github/license/sanctovali/VKAlertController)](/LICENSE)

VKAlertController is a simple but nice alternative to the Apple's UIAlertController. The alert has fully customazible appearance and similar to UIAlertController usage.

![Screenshot](https://github.com/sanctovali/VKAlertController/blob/assets/actionSheet.png)![Screenshot](https://github.com/sanctovali/VKAlertController/blob/assets/cancel.png)![Screenshot](https://github.com/sanctovali/VKAlertController/blob/assets/systemTeal.png)

## Features
----------------
- [x] Header View
- [x] Header Image (Optional)
- [x] Title
- [x] Description message
- [x] Customizations: fonts, colors, dimensions & more
- [x] 1, 2 buttons (horizontally) or 3+ buttons (vertically)
- [x] Closure when a button is pressed
- [x] Similar implementation to UIAlertController
- [x] Cocoapods
- [x] Animation 
- [x] Swift 5 support
- [x] Swift Package Manager

# Requirements
----------------
- iOS 10.0+
- Xcode 11+

## Example
----------------
To try an example, clone or download [Example](https://github.com/sanctovali/VKAlertController/tree/example).

## How to install
----------------
### CocoaPods
If there is now [CocoaPods](http://cocoapods.org), first of all install it with the following command:
```bash
$ gem install cocoapods
```
To integrate VKAlertController into your Xcode project using CocoaPods, specify it in your `Podfile`:
```ruby
target 'MyApp' do
  pod 'VKAlertController', '~> 1.0'
end
```
Then run inside your terminal:

```bash
$ pod install
```

Inside your project import module with `import VKAlertController`.

### Swift package manager

To add the package to your project go to the `File` menu and choose `Swift Packages` > `Add Package Dependency`. For the URL enter https://github.com/sanctovali/VKAlertController.git
Then check `Version – Up to Next Major` is selected and click `Next` -> `Finish`.

Inside your project import module with `import VKAlertController`.
