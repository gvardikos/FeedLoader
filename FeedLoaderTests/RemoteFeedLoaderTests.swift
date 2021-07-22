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

        expect(sut, toCompleteWithError: .connectivity, when: {
            let clientError = NSError(domain: "test", code: 0)
            client.complete(with: clientError)

        })
    }

    func test_load_deliversErrorOnNon200HttpResponse() {
        let (client, sut) = makeSUT(URL(string:"http://something.com")!)

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithError: .invalidData, when: {
                client.complete(withStatusCode: code, at: index)
            })
        }
    }

    /// When we have received a 200 response from the GET request but the JSON is not
    /// valid according to the contract.
    func test_load_deliversErrorOn200HttpResponseWithInvalidJSON() {
        let (client, sut) = makeSUT()

        expect(sut, toCompleteWithError: .invalidData, when: {
            let invalidJSON = Data.init("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }

    // MARK: Helpers

    private func makeSUT(_ url: URL = URL(string:"http://something.com")!) -> (HttpClientSpy, RemoteFeedLoader){
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(httpClient: client, url: url)

        return (client, sut)
    }

    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWithError error: RemoteFeedLoader.Error,
                        when action: () -> Void,
                        file: StaticString = #file, line: UInt = #line) {
        var capturedResults = [RemoteFeedLoader.Result]()
        sut.load() { capturedResults.append($0) }

        action()

        XCTAssertEqual(capturedResults, [.failure(error)], file: file, line: line)
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
