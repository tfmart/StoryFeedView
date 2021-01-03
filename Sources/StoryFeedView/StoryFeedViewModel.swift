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
    var amount: Int?
    var timeLimit: Double = 5.0
    var story: Story?
    
    //MARK: - Story methods
    func currentStory() -> Story? {
        return nil
    }
    
    func setStory(_ newStory: Story?) {
        story = newStory
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
}
