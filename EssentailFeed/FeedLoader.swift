//
//  FeedLoader.swift
//  EssentailFeed
//
//  Created by Rajat Nagavkar on 8/1/24.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}


protocol FeedLoader {
    func loadItems(completion: @escaping (LoadFeedResult) -> Void)
}
