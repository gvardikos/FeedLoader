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
        httpClient.get(from: url) { clientResponse in
            switch clientResponse {
            case let .successResult(data, response):
                do {
                    let items = try FeedItemMapper.map(data, response)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failResult:
                completion(.failure(.connectivity))
            }
        }
    }
}
