//
//  HttpClient.swift
//  FeedLoader
//
//  Created by George Vardikos on 11/6/21.
//

import Foundation

public enum HTTPClientResponse {
    case success(HTTPURLResponse)
    case fail(Error)
}

public protocol HttpClient {
    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void)
}
