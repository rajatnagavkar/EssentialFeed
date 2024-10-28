//
//  FeedLoader.swift
//  EssentailFeed
//
//  Created by Rajat Nagavkar on 8/1/24.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage],Error>
    
    func load(completion: @escaping (Result) -> Void)
}
