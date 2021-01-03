//
//  ViewController.swift
//  StoryFeedViewDemo
//
//  Created by Tomas Martins on 03/01/21.
//

import UIKit
import StoryFeedView
import SafariServices

class ViewController: UIViewController {
    var viewModel = ViewModel()
    let haptic = UIImpactFeedbackGenerator(style: .light)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = viewModel.backgroundColor
        viewModel.fetchStories {
            self.setupFeed()
        }
    }
    
    private func setupFeed() {
        let feed = StoryFeedView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height/2.1))
        
        feed.font = UIFont(name: "Montserrat-Medium", size: 20)
        feed.stories(stories: viewModel.currentStories())
        feed.timeLimit = 5.0
        feed.tint = viewModel.tintColor
        
        feed.headlineAction = {
            guard let url = self.viewModel.storyURL() else { return }
            let configuration = SFSafariViewController.Configuration()
            configuration.entersReaderIfAvailable = true
            let safariVC = SFSafariViewController(url: url, configuration: configuration)
            safariVC.modalPresentationStyle = .overFullScreen
            safariVC.preferredControlTintColor = self.viewModel.tintColor
            self.present(safariVC, animated: true)
        }
        feed.timerDidEnd = {
            self.haptic.impactOccurred()
            self.viewModel.increaseIndex()
        }
        feed.rightTapAction = {
            self.haptic.impactOccurred()
            self.viewModel.increaseIndex()
        }
        feed.leftTapAction = {
            self.haptic.impactOccurred()
            self.viewModel.decreaseIndex()
        }
        feed.longPressAction = {
            self.haptic.impactOccurred()
        }
        feed.releaseLongPressAction = {
            self.haptic.impactOccurred()
        }
        
        self.view.addSubview(feed)
    }
}

