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
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == 200 else { throw RemoteFeedLoader.Error.invalidData }
        
        return try JSONDecoder().decode(Root.self, from: data).items.map { $0.item }
    }
}
