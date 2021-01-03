//
//  Story.swift
//  StoriesNewsFeed
//
//  Created by Tomas Martins on 29/12/20.
//

import UIKit

public struct Story {
    public var image: UIImage?
    public var headline: String?
    
    public init(image: UIImage? = nil, headline: String? = nil) {
        self.image = image
        self.headline = headline
    }
}
