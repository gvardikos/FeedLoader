//
//  RemoteFeedLoader.swift
//  FeedLoader
//
//  Created by George Vardikos on 11/6/21.
//

import Foundation

class RemoteFeedLoader {
    let client: HttpClient
    let url: URL?

    init(httpClient: HttpClient, url: URL) {
        self.client = httpClient
        self.url = url
    }

    func load() {
        client.get(from: self.url!)
    }
}
