# StoryFeed


## Installation

Currently, this package can be installed through the *[Swift Package Manager](https://swift.org/package-manager/)*

If you're running Xcode 11 or later, you can simply go to `File -> Swift Package Manager -> Add Package Dependency...` and search for `SWGOFloat` or just paste this Github page URL on the text field

If you're running an earlier version, you'll have to set up SPM on your project and add the following dependency to your `Package.swift` file:

```
dependencies: [
.package(url: "https://github.com/tfmart/StoryFeedView.git", from: "0.1.0")
]
```


## Setting up the view

To setup a new `StoryFeed`, instantiate a `StoryFeedView`:
```
let storyFeed = StoryFeedView()
```

After that, setup the array of  `Story` to be displayed by the view.
```
let stories = [
    Story(image: UIImage(named: "headline1"), headline: "Headline 1"),
    Story(image: UIImage(named: "headline2", headline: "Headline 1"),
    Story(image: UIImage(named: "headline3", headline: "Headline 1"),
]

storyFeed.stories(stories)
```

Then you can customize the `StoryFeedView` with the following parameters:
```
// Font to be displayed by the headline label
storyFeed.font = UIFont()

// The tint color of the progress bars
storyFeed.progressTintColor = .systemRed

// Set the time limit for the view to progress between stories (default is 5.0 seconds)
storyFeed.setTimeLimit(7.0)
```

To naviagate between the stories, tap the right side of the view to progress and the left side of the view to go backward. You can also tap and hold to pause the progress and release to continue it. It's possible to setup additional events for each of these gestures:

```
storyFeed.timerDidEnd = {
    //executed when the timer runs out
}
storyFeed.rightTapAction = {
    //executed when the right area is tapped
}

storyFeed.leftTapAction = {
    //executed when the left area is tapped
}
storyFeed.longPressAction = {
    //executed when a long press is detected
}
storyFeed.releaseLongPressAction = {
    //executed when the long press is released
}
```
You can also navigate manually to a certain index when setting up the view stories:

```
storyFeed.stories(stories, moveTo: 2)
```

...or after the inital setup:
```
storyFeed.moveTo(2)
```

Keep in mind that if you insert an invalid index (out of bounds of stories array), the feed will return to the first page

## Demo
This repository contains a demo iOS project. Feel free to check the `StoryFeedView` in action and tweak it!
