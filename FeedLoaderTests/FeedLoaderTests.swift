//
//  FeedLoaderTests.swift
//  FeedLoaderTests
//
//  Created by George Vardikos on 10/6/21.
//

import XCTest
@testable import FeedLoader

class RemoteFeedLoader {
    let client: HttpClient

    init(httpClient: HttpClient) {
        self.client = httpClient
    }

    func load() {
        client.get(from: URL(string: "https//:a-url")!)
    }
}

protocol HttpClient {
    var baseUrl: URL? {get set}
    func get(from url: URL)
}

class HttpClientSpy: HttpClient {
    var baseUrl: URL?

    func get(from url: URL) {
        self.baseUrl = url
    }
}


class FeedLoaderTests: XCTestCase {

    func test_client_urlInNil() {
        let client = HttpClientSpy()
        _ = RemoteFeedLoader(httpClient: client)
        XCTAssertNil(client.baseUrl)
    }

    func test_load_requestDataFromUrl() {
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(httpClient: client)

        sut.load()

        XCTAssertNotNil(client.baseUrl)
    }
}
