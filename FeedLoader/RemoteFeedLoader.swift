//
//  RemoteFeedLoader.swift
//  FeedLoader
//
//  Created by George Vardikos on 11/6/21.
//

import Foundation

public final class RemoteFeedLoader {
    private let client: HttpClient
    private let url: URL?

    public init(httpClient: HttpClient, url: URL) {
        self.client = httpClient
        self.url = url
    }

    public func load() {
        client.get(from: self.url!)
    }
}
