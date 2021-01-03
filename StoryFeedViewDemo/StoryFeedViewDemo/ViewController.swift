//
//  ViewController.swift
//  StoryFeedViewDemo
//
//  Created by Tomas Martins on 03/01/21.
//

import UIKit
import StoryFeedView

class ViewController: UIViewController {
    var viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        } else {
            self.view.backgroundColor = .white
        }
        viewModel.fetchStories {
            self.setupFeed()
        }
    }
    
    private func setupFeed() {
        let feed = StoryFeedView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height/2.1))
        
        feed.font = UIFont(name: "Montserrat-Medium", size: 20)
        feed.amount = viewModel.count()
        feed.story = viewModel.currentStory()
        feed.timeLimit = 5.0
        feed.tint = .green
        
        feed.timerDidEnd = {
            self.viewModel.increaseIndex()
            feed.story = self.viewModel.currentStory()
        }
        feed.rightTapAction = {
            self.viewModel.increaseIndex()
            feed.story = self.viewModel.currentStory()
        }
        feed.leftTapAction = {
            self.viewModel.decreaseIndex()
            feed.story = self.viewModel.currentStory()
        }
        
        self.view.addSubview(feed)
    }
}

