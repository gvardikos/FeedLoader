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

        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "test", code: 0)
            client.complete(with: clientError)

        })
    }

    func test_load_deliversErrorOnNon200HttpResponse() {
        let (client, sut) = makeSUT(URL(string:"http://something.com")!)

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let data = makeItemsJSON([])
                client.complete(withStatusCode: code, at: index, data: data)
            })
        }
    }

    /// When we have received a 200 response from the GET request but the JSON is not
    /// valid according to the contract.
    func test_load_deliversErrorOn200HttpResponseWithInvalidJSON() {
        let (client, sut) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }

    /// Ensure when receiving a json from server with an empty items list that an empty array will be returned.
    func test_deliversNoItemsWithHttp200ResponseAndEmptyJSONList() {
        let (httpClientSpy, sut) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = Data("{\"items\": []}".utf8)
            httpClientSpy.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }

    func test_deliversArrayOfItemsOn200HttpAndValidJSON() {
        let (item1, item1JSON) = makeItem(id: UUID(),
                                          imageUrl: URL(string: "https://image-url")!)

        let (item2, item2JSON) = makeItem(id: UUID(),
                                          description: "a description",
                                          location: "a location",
                                          imageUrl: URL(string: "https://image-url")!)

        let (httpClientSpy, sut) = makeSUT()

        expect(sut, toCompleteWith: .success([item1, item2]), when: {
            let json = makeItemsJSON([item1JSON, item2JSON])
            httpClientSpy.complete(withStatusCode: 200, data: json)
        })
    }
    
    func test_load_doesNotCompleteAfterSUTDeallocation() {
        let client = HttpClientSpy()
        let url = URL(string: "http://a-url")!
        var sut: RemoteFeedLoader? = RemoteFeedLoader(httpClient: client, url: url)
        
        var capturedCompletions = [RemoteFeedLoader.Result]()
        sut?.load { capturedCompletions.append($0) }
        sut = nil
        
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        XCTAssertTrue(capturedCompletions.isEmpty)
    }

    // MARK: Helpers
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }

    private func makeSUT(_ url: URL = URL(string:"http://something.com")!, file: StaticString = #file, line: UInt = #line) -> (HttpClientSpy, RemoteFeedLoader){
        let client = HttpClientSpy()
        let sut = RemoteFeedLoader(httpClient: client, url: url)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (client, sut)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }

    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageUrl: URL) -> (model: FeedItem, json: [String: Any]) {

        let item = FeedItem(
            id: id,
            description: description,
            location: location,
            imageUrl: imageUrl)

        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageUrl.absoluteString,
        ].reduce(into: [String : Any]()) { (acc, e) in
            if let value = e.value { acc[e.key] = value }
        }

        return (item, json)
    }

    private func makeItemsJSON(_ dict: [[String: Any]]) -> Data {
        let json = ["items": dict]
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func expect(_ sut: RemoteFeedLoader,
                        toCompleteWith extectedResult: RemoteFeedLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #file, line: UInt = #line) {
        
        let expectation = expectation(description: "load method completion")
        sut.load() { receivedResult in
            switch(receivedResult, extectedResult) {
            case let (.success(receivedItems), .success(extectedItems)):
                XCTAssertEqual(receivedItems, extectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected: \(extectedResult) but, got \(receivedResult)", file: file, line: line)
            }
        
            expectation.fulfill()
        }

        action()

        wait(for: [expectation], timeout: 1.0)
    }

    private class HttpClientSpy: HttpClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var baseUrls: [URL] {
            messages.map { return $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            self.messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failResult(error))
        }

        func complete(withStatusCode code: Int,
                      at index: Int = 0,
                      data: Data) {

            let response = HTTPURLResponse(url: messages[index].url,
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!

            messages[index].completion(.successResult(data, response))
        }
    }
}
