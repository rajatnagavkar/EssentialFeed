//
//  FeedStoreSpecs.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 9/24/24.
//

import Foundation

protocol FeedStoreSpecs {

    func test_retrive_deliversEmptyOnEmptyCache()
    func test_retrive_hasNoSideEffectsOnEmptyCache()
    func test_retrieval_deliversFoundValuesOnEmptyCache()
    func test_retrieval_hasNoSideEffectsOnEmptyCache()
    

    func test_insert_overridesPreviouslyInsertedCacheValues()
   

    func test_deletion_hasNoSideEffectOnEmptyCache()
    func test_deletion_emptiesPreviouslyInsertedCache()
    

    func test_storeSideEffects_RunSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversErrorOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}

typealias FailableFeedStore = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs
