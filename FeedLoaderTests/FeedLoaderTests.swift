//
//  FeedLoaderTests.swift
//  FeedLoaderTests
//
//  Created by George Vardikos on 10/6/21.
//

import XCTest
@testable import FeedLoader

class RemoteFeedLoader {
    var client: HttpClient

    init(httpClient: HttpClient) {
        self.client = httpClient
    }

    func load() {
        client.baseUrl = URL(string: "https//:a-url")!
    }
}

class HttpClient {
    var baseUrl: URL?
}

class FeedLoaderTests: XCTestCase {

    func test_client_urlInNil() {
        let client = HttpClient()
        _ = RemoteFeedLoader(httpClient: client)
        XCTAssertNil(client.baseUrl)
    }

    func test_load_requestDataFromUrl() {
        let client = HttpClient()
        let sut = RemoteFeedLoader(httpClient: client)

        sut.load()

        XCTAssertNotNil(client.baseUrl)
    }
}
