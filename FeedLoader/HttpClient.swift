//
//  HttpClient.swift
//  FeedLoader
//
//  Created by George Vardikos on 11/6/21.
//

import Foundation

protocol HttpClient {
    func get(from url: URL)
}
