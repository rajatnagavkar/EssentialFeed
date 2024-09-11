//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 9/11/24.
//

import XCTest
import EssentailFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_,store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestCacheRetrival() {
        let (sut,store) = makeSUT()
    
        sut.load{_ in}
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        
        let (sut,store) = makeSUT()
        let retrievalError = anyNSError()
        let exp = expectation(description: "Wait for load completion")
        
        var receivedError: Error?
        sut.load{ error in
            receivedError = error
            exp.fulfill()
        }
        
        store.completeRetrieval(with:retrievalError )
        wait(for: [exp], timeout: 1.0)
        
        
        XCTAssertEqual(receivedError as NSError?, retrievalError)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,file: StaticString = #file,
                         line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store,currentDate: currentDate)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,store)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
   
    
    
}


