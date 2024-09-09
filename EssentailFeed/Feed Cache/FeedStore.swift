//
//  FeedStore.swift
//  EssentailFeed
//
//  Created by Rajat Nagavkar on 9/9/24.
//

import Foundation


public protocol FeedStore {
    typealias DeletionCompletion = (Error?) ->  Void
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    typealias InsertionCompletion = (Error?)-> Void
    func insert(_ items: [FeedItem],timestamp: Date,completion: @escaping InsertionCompletion)
}
  
