//
//  Story.swift
//  StoriesNewsFeed
//
//  Created by Tomas Martins on 29/12/20.
//

import UIKit

public struct Story: Equatable {
    public var image: UIImage?
    public var headline: String?
    
    public init(image: UIImage? = nil, headline: String? = nil) {
        self.image = image
        self.headline = headline
    }
}
