//
//  CoreDataFeedStoreTests.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 9/26/24.
//

import XCTest
import EssentailFeed

class CoreDataFeedStore: FeedStore {
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    func insert(_ feed: [EssentailFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    
    
}


class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrive_deliversEmptyOnEmptyCache() {
        
    }
    
    func test_retrive_hasNoSideEffectsOnEmptyCache() {
        
    }
    
    func test_retrieval_deliversFoundValuesOnEmptyCache() {
        
    }
    
    func test_retrieval_hasNoSideEffectsOnNonEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        
    }
    
    func test_deletion_deliversNoErrorOnEmptyCache() {
        
    }
    
    func test_deletion_hasNoSideEffectOnEmptyCache() {
        
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        
    }
    
    func test_storeSideEffects_RunSerially() {
        
    }
    
    //MARK: Helper
    func makeSUT(storeURL: URL? = nil,file: StaticString = #file,line: UInt = #line) -> CoreDataFeedStore {
        let sut = CoreDataFeedStore()
        trackForMemoryLeaks(sut, file: file,line: line)
        return sut
    }
    
}
