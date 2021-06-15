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

        XCTAssertTrue(client.baseUrls.isEmpty)
    }

    func test_load_requestDataFromUrl() {
        let url = URL(string: "https://a-given-url")!
        let (client, sut) = makeSUT(url)

        sut.load()

        XCTAssertEqual(client.baseUrls, [url])
    }

    func test_load_requestDataFromUrlTwice() {
        let url = URL(string: "https://a-given-url")!
        let (client, sut) = makeSUT(url)

        sut.load()
        sut.load()

        XCTAssertEqual(client.baseUrls, [url, url])
    }

    func test_load_deliversErrorOnClient() {
        let (client, sut) = makeSUT(URL(string:"http://something.com")!)

        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load() { capturedErrors.append($0) }

        let clientError = NSError(domain: "test", code: 0)
        client.complete(with: clientError)

        XCTAssertEqual(capturedErrors, [.connectivity])
    }

    // MARK: Helpers

    private func makeSUT(_ url: URL) -> (HttpClientSpy, RemoteFeedLoader){
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(httpClient: client, url: url)

        return (client, sut)
    }

    private class HttpClientSpy: HttpClient {
        var baseUrls = [URL]()
        var completions = [(Error) -> Void]()

        func get(from url: URL, completion: @escaping (Error) -> Void) {
            self.completions.append(completion)
            self.baseUrls.append(url)
        }

        func complete(with error: Error, at index: Int = 0) {
            completions[index](error)
        }

    }
}
