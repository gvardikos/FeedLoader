//
//  HttpClient.swift
//  FeedLoader
//
//  Created by George Vardikos on 11/6/21.
//

import Foundation

public protocol HttpClient {
    func get(from url: URL, completion: @escaping (Error) -> Void)
}
