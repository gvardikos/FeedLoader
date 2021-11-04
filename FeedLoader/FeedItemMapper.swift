//
//  FeedItemMapper.swift
//  FeedLoader
//
//  Created by George Vardikos on 3/11/21.
//

import Foundation

private let OK_200: Int = 200

internal final class FeedItemMapper {
    private struct Root: Decodable {
        let items: [RSFeedItem]
        
        var feed: [FeedItem] {
            self.items.map { $0.item }
        }
    }

    private struct RSFeedItem: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(id: self.id,
                            description: self.description,
                            location: self.location,
                            imageUrl: self.image)
        }
    }
     
    internal static func map(_ data: Data, from  response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        
        guard response.statusCode == OK_200, let items = try? JSONDecoder().decode(Root.self, from: data)
        else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(items.feed)
    }
}
