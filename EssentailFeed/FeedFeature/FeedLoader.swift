//
//  FeedLoader.swift
//  EssentailFeed
//
//  Created by Rajat Nagavkar on 8/1/24.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage],Error>

public protocol FeedLoader {
    
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
