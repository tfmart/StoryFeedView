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
    var timeLimit: TimeInterval = 5.0
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
    
    func headline() -> String? {
        return currentStory()?.headline
    }
    
    func image() -> UIImage? {
        return currentStory()?.image
    }
    
    //MARK: - Index methods
    func currentIndex() -> Int {
        return index
    }
    
    func setIndex(_ newValue: Int) {
        index = newValue
    }
    
    func previousIndex() -> Int {
        if let amount = amount, isOverlappingIndex(isIncreasing: false) {
            return amount - 1
        } else {
            return index - 1
        }
    }
    
    func increaseIndex() {
        if isOverlappingIndex(isIncreasing: true) {
            index = 0
        } else {
            index += 1
        }
    }
    
    func decreaseIndex() {
        index = previousIndex()
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
    
    //MARK: Colors and Animators {
    func gradientColors() -> [CGColor] {
        if #available(iOS 13, *) {
            return [
                UIColor.clear.cgColor,
                UIColor.systemBackground.resolvedColor(with: .current).withAlphaComponent(0.2).cgColor,
                UIColor.systemBackground.resolvedColor(with: .current).withAlphaComponent(0.8).cgColor,
                UIColor.systemBackground.resolvedColor(with: .current).cgColor
            ]
        } else {
            return [
                UIColor.clear.cgColor,
                UIColor.white.withAlphaComponent(0.2).cgColor,
                UIColor.white.withAlphaComponent(0.8).cgColor,
                UIColor.white.cgColor
            ]
        }
    }
    
    func animator(duration: TimeInterval? = nil, curve: UIView.AnimationCurve = .linear, animations: (() -> Void)?, completion: @escaping (UIViewAnimatingPosition) -> Void) -> UIViewPropertyAnimator {
        let animator: UIViewPropertyAnimator
        if let duration = duration {
            animator = UIViewPropertyAnimator(duration: duration, curve: curve, animations: animations)
        } else {
            animator = UIViewPropertyAnimator(duration: timeLimit, curve: curve, animations: animations)
        }
        animator.addCompletion(completion)
        return animator
    }
}
