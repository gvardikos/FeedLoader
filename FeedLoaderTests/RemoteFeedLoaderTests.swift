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

        sut.load { _ in }

        XCTAssertEqual(client.baseUrls, [url])
    }

    func test_load_requestDataFromUrlTwice() {
        let url = URL(string: "https://a-given-url")!
        let (client, sut) = makeSUT(url)

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.baseUrls, [url, url])
    }

    func test_load_deliversErrorOnClient() {
        let (client, sut) = makeSUT(URL(string:"http://something.com")!)

        var capturedErrors = [RemoteFeedLoader.Error]()

        sut.load() {
            capturedErrors.append($0)
        }

        let clientError = NSError(domain: "test", code: 0)
        client.complete(with: clientError)

        XCTAssertEqual(capturedErrors, [.connectivity])
    }

    func test_load_deliversErrorOnNon200HttpResponse() {
        let (client, sut) = makeSUT(URL(string:"http://something.com")!)

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            var capturedErrors = [RemoteFeedLoader.Error]()
            sut.load() { capturedErrors.append($0) }

            client.complete(withStatusCode: code, at: index)

            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }

    /// When we have received a 200 response from the GET request but the JSON is not
    /// valid according to the contract.
    func test_load_deliversErrorOn200HttpResponseWithInvalidJSON() {
        let (client, sut) = makeSUT()

        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load() { capturedErrors.append($0) }

        let invalidJSON = Data.init(bytes: "invalid json".utf8)
        client.complete(withStatusCode: 200, data: invalidJSON)

        XCTAssertEqual(capturedErrors, [.invalidData])
    }

    // MARK: Helpers

    private func makeSUT(_ url: URL = URL(string:"http://something.com")!) -> (HttpClientSpy, RemoteFeedLoader){
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(httpClient: client, url: url)

        return (client, sut)
    }

    private class HttpClientSpy: HttpClient {
        private var messages = [(url: URL, completion: (HTTPClientResponse) -> Void)]()
        var baseUrls: [URL] {
            messages.map { return $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
            self.messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.fail(error))
        }

        func complete(withStatusCode code: Int,
                      at index: Int = 0,
                      data: Data = Data()) {

            let response = HTTPURLResponse(url: messages[index].url,
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!

            messages[index].completion(.success(data, response))
        }
    }
}
