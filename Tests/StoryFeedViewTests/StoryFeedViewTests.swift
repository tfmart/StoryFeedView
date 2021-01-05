import XCTest
@testable import StoryFeedView

final class StoryFeedViewTests: XCTestCase {
    func testFont() {
        let storyFeed = StoryFeedView()
        let font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        storyFeed.font = font
        print(storyFeed.headlineLabel.font.pointSize)
        XCTAssertEqual(storyFeed.headlineLabel.font, font)
    }
    
    func testTintColor() {
        let storyFeed = StoryFeedView()
        let color = UIColor.yellow
        storyFeed.stories([Story(image: nil, headline: "Test")])
        storyFeed.progressTintColor = color
        XCTAssertEqual(storyFeed.progressViews[0].progressTintColor, UIColor.yellow)
    }
    
    func testImageSetup() {
        let storyFeed = StoryFeedView()
        let image = UIImage(named: "test", in: Bundle.module, compatibleWith: UITraitCollection(userInterfaceStyle: .light))
        storyFeed.stories([Story(image: image, headline: "Star")])
        XCTAssertEqual(storyFeed.imageView.image, image)
    }
    
    func testStories() {
        let storyFeed = StoryFeedView()
        let stories = [
            Story(image: nil, headline: "Test1"),
            Story(image: nil, headline: "Test2"),
            Story(image: nil, headline: "Test3")
        ]
        storyFeed.stories(stories)
        XCTAssertEqual(storyFeed.viewModel.amount, 3)
        XCTAssertEqual(storyFeed.viewModel.currentStory(), Story(image: nil, headline: "Test1"))
        XCTAssertEqual(storyFeed.viewModel.currentIndex(), 0)
    }
    
    func testTimeLimit() {
        let storyFeed = StoryFeedView()
        storyFeed.setTimeLimit(10.0)
        XCTAssertEqual(storyFeed.viewModel.timeLimit, 10.0)
    }
    
    func testStoriesWithIndex() {
        let storyFeed = StoryFeedView()
        let stories = [
            Story(image: nil, headline: "Test1"),
            Story(image: nil, headline: "Test2"),
            Story(image: nil, headline: "Test3")
        ]
        storyFeed.stories(stories, moveTo: 1)
        XCTAssertEqual(storyFeed.viewModel.amount, 3)
        XCTAssertEqual(storyFeed.viewModel.currentStory(), Story(image: nil, headline: "Test2"))
        XCTAssertEqual(storyFeed.viewModel.currentIndex(), 1)
    }
    
    func testStoriesWithInvalidIndex() {
        let storyFeed = StoryFeedView()
        let stories = [
            Story(image: nil, headline: "Test1"),
            Story(image: nil, headline: "Test2"),
            Story(image: nil, headline: "Test3")
        ]
        storyFeed.stories(stories, moveTo: -2)
        XCTAssertEqual(storyFeed.viewModel.amount, 3)
        XCTAssertEqual(storyFeed.viewModel.currentStory(), Story(image: nil, headline: "Test1"))
        XCTAssertEqual(storyFeed.viewModel.currentIndex(), 0)
    }
    
    func testStoptAnimation() {
        let storyFeed = StoryFeedView()
        storyFeed.stories([
            Story(image: nil, headline: "Test1"),
            Story(image: nil, headline: "Test2"),
            Story(image: nil, headline: "Test3")
        ])
        storyFeed.stopAnimations()
        XCTAssertFalse(storyFeed.headlineAnimator.isRunning)
        XCTAssertFalse(storyFeed.imageViewAnimator.isRunning)
        XCTAssertFalse(storyFeed.progressBarAnimator.isRunning)
    }
    
    func testResetAnimation() {
        let storyFeed = StoryFeedView()
        storyFeed.stories([
            Story(image: nil, headline: "Test1"),
            Story(image: nil, headline: "Test2"),
            Story(image: nil, headline: "Test3")
        ])
        storyFeed.resetAnimations()
        XCTAssertTrue(storyFeed.imageViewAnimator.isRunning)
        XCTAssertFalse(storyFeed.headlineAnimator.isRunning)
        XCTAssertFalse(storyFeed.progressBarAnimator.isRunning)
    }

    static var allTests = [
        ("testFont", testFont),
        ("testTintColor", testTintColor),
        ("testImageSetup", testImageSetup),
        ("testStories", testStories),
        ("testTimeLimit", testTimeLimit),
        ("testStoriesWithIndex", testStoriesWithIndex),
        ("testStoriesWithInvalidIndex", testStoriesWithInvalidIndex),
        ("testStoptAnimation", testStoptAnimation),
        ("testResetAnimation", testResetAnimation)
    ]
}
