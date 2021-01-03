//
//  ViewModel.swift
//  StoryFeedViewDemo
//
//  Created by Tomas Martins on 03/01/21.
//

import Foundation
import SDWebImage
import StoryFeedView

public class ViewModel {
    private var index = 0
    private let news = DemoData.news()
    private var stories = [Story]()
    
    public func currentStory() -> Story? {
        return stories[index]
    }
    
    public func increaseIndex() {
        index = nextIndex()
    }
    
    public func decreaseIndex() {
        index = previousIndex()
    }
    
    public func count() -> Int {
        return news?.items?.count ?? 0
    }
    
    public func fetchStories(completion: @escaping(() -> ())) {
        guard let items = self.news?.items else { return }
        for (index, item) in items.enumerated() {
            self.imageManager(url: item.image!) { (image) in
                self.stories.append(Story(image: image, headline: item.title))
                if index == self.count() - 1 {
                    completion()
                }
            }
        }
    }
    
    private func imageManager(url: String, completion: @escaping ((UIImage?) -> ())) {
        let imageManager = SDWebImageManager()
        imageManager.loadImage(with: URL(string: url), options: .refreshCached, progress: nil) { (image, _, _, _, _, _) in
            completion(image)
        }
    }
    
    private func nextIndex() -> Int {
        if index == count() - 1 {
            return 0
        } else {
            return index + 1
        }
    }
    
    private func previousIndex() -> Int {
        if index == 0 {
            return count() - 1
        } else {
            return index - 1
        }
    }
}