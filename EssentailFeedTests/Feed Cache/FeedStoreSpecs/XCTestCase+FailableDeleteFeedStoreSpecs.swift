//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 9/26/24.
//

import XCTest
import EssentailFeed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line){
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError,"Expected non empty cache deletion to succeed")
       
    }
    
    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line){
       deleteCache(from: sut)
        
       expect(sut, toRetrieve: .empty)
       
    }
}
