<p align="center">
  <img width="420" height="240" src="assets/logo.png"/>
</p>

[![Build Status](https://travis-ci.org/andreamazz/UIView-Shake.svg)](https://travis-ci.org/andreamazz/UIView-Shake)
[![Cocoapods](https://cocoapod-badges.herokuapp.com/v/UIView+Shake/badge.svg)](http://cocoapods.org/?q=summary%3Auiview%20name%3Ashake%2A)
[![Coverage Status](https://coveralls.io/repos/andreamazz/UIView-Shake/badge.svg?branch=master&service=github)](https://coveralls.io/github/andreamazz/UIView-Shake?branch=master)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

UIView category that adds a shake animation like the password field of the OSX login screen.

<p align="center">
  <a href='https://appetize.io/app/d4gkmq6mvpb9j2g4wyb077nj2g' alt='Live demo'>
    <img width="50" height="60" src="assets/demo.png"/>
  </a>
</p>

##Screenshot
![UIView+Shake](https://raw.githubusercontent.com/andreamazz/UIView-Shake/master/assets/screenshot.gif)

##Setup with Cocoapods
* Add ```pod 'UIView+Shake'``` to your Podfile
* Run ```pod install```
* Run ```open App.xcworkspace```

###Objective-C
Import ```UIView+Shake.h``` in your controller's header file
###Swift
If you are using `use_frameworks!` in your Podfile, use this import:
```swift
import UIView_Shake
```

##Usage

###In Objective-C

```objc
// Shake
[[self.view] shake];

// Shake with the default speed
[self.view shake:10   // 10 times
       withDelta:5    // 5 points wide
];

// Shake with a custom speed
[self.view shake:10   // 10 times
       withDelta:5    // 5 points wide
           speed:0.03 // 30ms per shake
];

// Shake with a custom speed and direction
[self.view shake:10   // 10 times
       withDelta:5    // 5 points wide
           speed:0.03 // 30ms per shake
  shakeDirection:ShakeDirectionVertical
];
```

###In Swift

```swift
// Shake
self.view.shake()
        
// Shake with the default speed
self.view.shake(10,              // 10 times
                withDelta: 5.0   // 5 points wide
)
        
// Shake with a custom speed
self.view.shake(10,              // 10 times
                withDelta: 5.0,  // 5 points wide
                speed: 0.03      // 30ms per shake
)
        
// Shake with a custom speed and direction
self.view.shake(10,              // 10 times
                withDelta: 5.0,  // 5 points wide
                speed: 0.03,     // 30ms per shake
                shakeDirection: ShakeDirection.Vertical
)
```

##Completion Handler
You can also pass a completion block that will be performed as soon as the shake animation stops
```objc
- (void)shake:(int)times withDelta:(CGFloat)delta completion:(void((^)()))handler;
- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval completion:(void((^)()))handler;
- (void)shake:(int)times withDelta:(CGFloat)delta speed:(NSTimeInterval)interval shakeDirection:(ShakeDirection)shakeDirection completion:(void((^)()))handler;
```
or in Swift using the trailing closure syntax:
```swift
view.shake(10, withDelta: 5) {
    println("done")
}
```

#Author
[Andrea Mazzini](https://twitter.com/theandreamazz). I'm available for freelance work, feel free to contact me. 

Want to support the development of [these free libraries](https://cocoapods.org/owners/734)? Buy me a coffee ☕️ via [Paypal](https://www.paypal.me/andreamazzini).  

#Contributors
Thanks to [everyone](https://github.com/andreamazz/UIView-Shake/graphs/contributors) kind enough to submit a pull request. 


#MIT License
	Copyright (c) 2015 Andrea Mazzini. All rights reserved.

	Permission is hereby granted, free of charge, to any person obtaining a
	copy of this software and associated documentation files (the "Software"),
	to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:

	The above copyright notice and this permission notice shall be included
	in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
