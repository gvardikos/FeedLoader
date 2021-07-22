//
//  FeedItem.swift
//  FeedLoader
//
//  Created by George Vardikos on 10/6/21.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageUrl: URL
}
