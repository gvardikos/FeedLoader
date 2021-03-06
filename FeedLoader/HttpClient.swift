//
//  HttpClient.swift
//  FeedLoader
//
//  Created by George Vardikos on 11/6/21.
//

import Foundation

public enum HTTPClientResult {
    case successResult(Data, HTTPURLResponse)
    case failResult(Error)
}

public protocol HttpClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
