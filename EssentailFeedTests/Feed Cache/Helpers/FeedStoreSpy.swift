//
//  FeedStoreSpy.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 9/11/24.
//

import Foundation
import EssentailFeed

class FeedStoreSpy: FeedStore{
    
    typealias DeletionCompletion = (Error?) ->  Void
    typealias InsertionCompletion = (Error?)-> Void
    
    enum ReceivedMessages: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }
    
    private(set) var receivedMessages = [ReceivedMessages]()
    
    private var deletionCompletion = [DeletionCompletion]()
    private var insertionCompletion = [InsertionCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletion.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0 ){
        deletionCompletion[index](error)
    }
    
    func completeDeletionSuccessful(at index: Int = 0){
        deletionCompletion[index](nil)
    }
    
    func insert(_ feed: [LocalFeedImage],timestamp: Date,completion: @escaping InsertionCompletion) {
        insertionCompletion.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }
    
    func completeInsertion(with error: Error,  at index: Int = 0 ) {
        insertionCompletion[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0){
        insertionCompletion[index](nil)
    }
    
    func retrieve() {
        receivedMessages.append(.retrieve)
    }
    
    
}
