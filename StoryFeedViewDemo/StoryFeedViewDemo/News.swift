//
//  News.swift
//  StoryFeedViewDemo
//
//  Created by Tomas Martins on 03/01/21.
//

import Foundation

// MARK: - News
public struct News: Codable {
    let items: [Item]?
}

// MARK: - Item
public struct Item: Codable {
    let title: String?
    let origin: String?
    let link, externalLink: String?
    let isPriority: Bool?
    let image: String?
    let published: String?

    enum CodingKeys: String, CodingKey {
        case title, origin, link
        case externalLink = "external-link"
        case isPriority = "is_priority"
        case image, published
    }
}

public class DemoData {
    public static func news() -> News? {
        do {
            if let bundlePath = Bundle.main.path(forResource: "news", ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                do {
                    let decodedData = try JSONDecoder().decode(News.self, from: jsonData)
                    return decodedData
                } catch {
                    print("decode error")
                }
            }
        } catch {
            print(error)
        }
        return nil
    }
}
