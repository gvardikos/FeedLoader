//
//  FeedLoader.swift
//  FeedLoader
//
//  Created by George Vardikos on 10/6/21.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case fail(Error)
}

protocol FeedLoader {
    func fetchFeed(completion: @escaping (LoadFeedResult) -> Void)
}
