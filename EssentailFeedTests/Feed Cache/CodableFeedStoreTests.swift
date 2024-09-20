//
//  CodableFeedStoreTests.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 9/20/24.
//

import XCTest
import EssentailFeed

class CodableFeedStore {
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion){
        completion(.empty)
    }
}


class CodableFeedStoreTests: XCTestCase {
    
    func test_retrive_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        
        let exp = expectation(description: "Wait for cache retrival")
        
        sut.retrieve{ result in
            
            switch result {
            case .empty:
                break
                
            default:
                XCTFail("Expected Empty result got \(result) instead")
                
            }
            exp.fulfill()
        }
        
        wait(for: [exp],timeout: 1.0)
        
    }
    
}
