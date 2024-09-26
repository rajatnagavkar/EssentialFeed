//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 9/26/24.
//

import XCTest
import EssentailFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase{
    
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line){
        
        let insertionError = insert((uniqueImageFeed().local,Date()), to: sut)
        
        XCTAssertNotNil(insertionError,"Expected cache insertion to fail with an error")
    }
    
    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line){
        
        insert((uniqueImageFeed().local,Date()), to: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
}

