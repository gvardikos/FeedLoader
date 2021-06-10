//
//  FeedLoader.swift
//  FeedLoader
//
//  Created by George Vardikos on 10/6/21.
//

import Foundation

enum FeedLoaderResult {
    case success([FeedItem])
    case fail(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (FeedLoaderResult) -> Void)
}