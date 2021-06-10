//
//  FeedLoaderTests.swift
//  FeedLoaderTests
//
//  Created by George Vardikos on 10/6/21.
//

import XCTest
import FeedLoader

class RemoteFeedLoaderTests: XCTestCase {

    func test_client_urlInNil() {
        let url = URL(string: "https://a-url")!
        let (client, _) = makeSUT(url)

        XCTAssertNil(client.baseUrl)
    }

    func test_load_requestDataFromUrl() {
        let url = URL(string: "https://a-given-url")!
        let (client, sut) = makeSUT(url)

        sut.load()

        XCTAssertEqual(client.baseUrl, url)
    }

    // MARK: Helpers

    private func makeSUT(_ url: URL) -> (HttpClientSpy, RemoteFeedLoader){
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(httpClient: client, url: url)

        return (client, sut)
    }

    private class HttpClientSpy: HttpClient {
        var baseUrl: URL?

        func get(from url: URL) {
            self.baseUrl = url
        }
    }
}
