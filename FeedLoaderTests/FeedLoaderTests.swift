//
//  FeedLoaderTests.swift
//  FeedLoaderTests
//
//  Created by George Vardikos on 10/6/21.
//

import XCTest
@testable import FeedLoader

class RemoteFeedLoader {


}

class HttpClient {
    var baseUrl: URL?
}

class FeedLoaderTests: XCTestCase {

    func test_client_urlInNil() {
        let client = HttpClient()
        _ = RemoteFeedLoader()
        XCTAssertNil(client.baseUrl)
    }

}
