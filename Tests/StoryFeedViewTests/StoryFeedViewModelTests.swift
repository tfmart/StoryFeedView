//
//  StoryFeedViewModelTests.swift
//  
//
//  Created by Tomas Martins on 03/01/21.
//

import XCTest
@testable import StoryFeedView

final class StoryFeedViewModelTests: XCTestCase {
    let stories = [
        Story(image: nil, headline: "Test1"),
        Story(image: nil, headline: "Test2"),
        Story(image: nil, headline: "Test3"),
    ]
    
    let storiesWithImage = [
        Story(image: UIImage(named: "test", in: Bundle.module, compatibleWith: UITraitCollection(userInterfaceStyle: .light)), headline: "Test1"),
        Story(image: nil, headline: "Test2"),
        Story(image: nil, headline: "Test3"),
    ]
    
    func testSetStories() {
        let viewModel = StoryFeedViewModel()
        viewModel.setStories(stories)
        XCTAssertEqual(viewModel.stories, stories)
    }
    
    func testAmount() {
        let viewModel = StoryFeedViewModel()
        viewModel.setStories(stories)
        XCTAssertEqual(viewModel.amount, 3)
    }
    
    func testCurrentStory() {
        let viewModel = StoryFeedViewModel()
        viewModel.setStories(stories)
        XCTAssertEqual(viewModel.currentStory(), stories[0])
    }
    
    func testHeadline() {
        let viewModel = StoryFeedViewModel()
        viewModel.setStories(stories)
        XCTAssertEqual(viewModel.headline(), "Test1")
    }
    
    func testImage() {
        let viewModel = StoryFeedViewModel()
        let image = UIImage(named: "test", in: Bundle.module, compatibleWith: UITraitCollection(userInterfaceStyle: .light))
        viewModel.setStories(storiesWithImage)
        XCTAssertEqual(viewModel.image(), image)
    }
    
    func testSetIndex() {
        let viewModel = StoryFeedViewModel()
        viewModel.setStories(stories)
        viewModel.setIndex(2)
        XCTAssertEqual(viewModel.currentIndex(), 2)
    }
    
    func testInvalidIndex() {
        let viewModel = StoryFeedViewModel()
        viewModel.setStories(stories)
        viewModel.setIndex(8)
        XCTAssertEqual(viewModel.currentIndex(), 0)
    }
    
    func testIncreaseIndex() {
        let viewModel = StoryFeedViewModel()
        viewModel.setStories(stories)
        viewModel.increaseIndex()
        XCTAssertEqual(viewModel.currentIndex(), 1)
    }
    
    func testIncreaseOverlappingIndex() {
        let viewModel = StoryFeedViewModel()
        viewModel.setStories(stories)
        viewModel.setIndex(2)
        viewModel.increaseIndex()
        XCTAssertEqual(viewModel.currentIndex(), 0)
    }
    
    func testDecereaseIndex() {
        let viewModel = StoryFeedViewModel()
        viewModel.setStories(stories)
        viewModel.setIndex(2)
        viewModel.decreaseIndex()
        XCTAssertEqual(viewModel.currentIndex(), 1)
    }
    
    func testDecreaseOverlappingIndex() {
        let viewModel = StoryFeedViewModel()
        viewModel.setStories(stories)
        viewModel.decreaseIndex()
        XCTAssertEqual(viewModel.currentIndex(), 2)
    }
    
    func testIsValid() {
        let viewModel = StoryFeedViewModel()
        XCTAssertFalse(viewModel.isValid(index: 2))
        viewModel.setStories(stories)
        XCTAssertTrue(viewModel.isValid(index: 2))
    }
    
    func testNewProgressBar() {
        let viewModel = StoryFeedViewModel()
        let bar = viewModel.newProgressBar(tintColor: .red)
        XCTAssertEqual(bar.progress, 0.0)
        XCTAssertEqual(bar.progressTintColor, .red)
    }
    
    static var allTests = [
        ("testSetStories", testSetStories),
        ("testAmount", testAmount),
        ("testCurrentStory", testCurrentStory),
        ("testHeadline", testHeadline),
        ("testImage", testImage),
        ("testSetIndex", testSetIndex),
        ("testInvalidIndex", testInvalidIndex),
        ("testIncreaseIndex", testIncreaseIndex),
        ("testIncreaseOverlappingIndex", testIncreaseOverlappingIndex),
        ("testDecereaseIndex", testDecereaseIndex),
        ("testDecreaseOverlappingIndex", testDecreaseOverlappingIndex),
        ("testIsValid", testIsValid)
    ]
}
