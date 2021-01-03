//
//  StoryFeedViewModel.swift
//  StoriesNewsFeed
//
//  Created by Tomas Martins on 02/01/21.
//

import UIKit

internal class StoryFeedViewModel {
    //MARK: - Properties
    private var index: Int = 0
    var timeLimit: Double = 5.0
    var stories: [Story]?
    var amount: Int? {
        return stories?.count
    }
    
    //MARK: - Story methods
    func currentStory() -> Story? {
        guard let stories = stories, let amount = amount, index < amount else { return nil }
        return stories[index]
    }
    
    func setStories(_ stories: [Story]?) {
        self.stories = stories
    }
    
    //MARK: - Index methods
    func currentIndex() -> Int {
        return index
    }
    
    func setIndex(_ newValue: Int) {
        index = newValue
    }
    
    func previousIndex() -> Int {
        guard let amount = amount else {
            return index
        }
        if index == 0 {
            return amount - 1
        } else {
            return index - 1
        }
    }
    
    func increaseIndex() {
        guard let amount = amount else {
            return
        }
        if index == amount - 1 {
            index = 0
        } else {
            index += 1
        }
    }
    
    func decreaseIndex() {
        guard let amount = amount else {
            return
        }
        if index == 0 {
            index = amount - 1
        } else {
            index -= 1
        }
    }
    
    func isOverlappingIndex(isIncreasing: Bool) -> Bool {
        if isIncreasing {
            guard let amount = amount else { return true }
            return index == amount - 1
        } else {
            return index == 0
        }
    }
    
    func isValid(index: Int) -> Bool {
        if let amount = amount, index >= 0, index < amount {
            return true
        } else {
            return false
        }
    }
}
