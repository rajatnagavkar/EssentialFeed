//
//  XCTestCase+FailableRetriveFeedStoreSpecs.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 9/26/24.
//

import XCTest
import EssentailFeed

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line){
        expect(sut, toRetrieve: .failure(anyNSError()),file: file,line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line){
        expect(sut, toRetrieveTwice: .failure(anyNSError()),file: file,line: line)
    }
}
