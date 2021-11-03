//
//  RemoteFeedLoader.swift
//  FeedLoader
//
//  Created by George Vardikos on 11/6/21.
//

import Foundation

public final class RemoteFeedLoader {
    private let httpClient: HttpClient
    private let url: URL

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }

    public init(httpClient: HttpClient, url: URL) {
        self.httpClient = httpClient
        self.url = url
    }

    public func load(completion: @escaping (Result) -> Void) {
        httpClient.get(from: url) { [weak self] clientResponse in
            guard self != nil else { return }

            switch clientResponse {
            case let .successResult(data, response):
                completion(FeedItemMapper.map(data, from: response))
            case .failResult:
                completion(.failure(.connectivity))
            }
        }
    }
}
