//
//  RemoteFeedLoader.swift
//  FeedLoader
//
//  Created by George Vardikos on 11/6/21.
//

import Foundation

public final class RemoteFeedLoader {
    private let client: HttpClient
    private let url: URL

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public init(httpClient: HttpClient, url: URL) {
        self.client = httpClient
        self.url = url
    }

    public func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { response, error in
            if error != nil {
                completion(.connectivity)
            } else {
                completion(.invalidData)
            }
        }
    }
}
