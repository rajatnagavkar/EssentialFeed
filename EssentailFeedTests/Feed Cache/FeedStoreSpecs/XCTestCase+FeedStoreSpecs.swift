//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 9/24/24.
//

import XCTest
import EssentailFeed


extension FeedStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore,file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .empty,file: file,line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line){
        
        expect(sut, toRetrieveTwice: .empty,file: file,line: line)
        
    }
    
    func assertThatRetrievalDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line){
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feed,timeStamp), to: sut)
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timeStamp),file: file,line: line)
    }
    
    func assertThatRetrievalHasNoSideEffectsONNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line){
        let feed = uniqueImageFeed().local
                let timestamp = Date()

        insert((feed, timestamp), to: sut)

        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp), file: file, line: line)
    }
    
    func assertThatInsertionDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((uniqueImageFeed().local,Date()), to: sut)
        XCTAssertNil(insertionError,"Expected to insert Cache successfully",file: file,line: line)
    }
    
    func assertThatInsertionDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        
         insert((uniqueImageFeed().local,Date()), to: sut)
        
        let insertionError = insert((uniqueImageFeed().local,Date()), to: sut)
        XCTAssertNil(insertionError,"Expected to override Cache successfully",file: file,line: line)
    }
    
    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #file, line: UInt = #line){
        insert((uniqueImageFeed().local,Date()), to: sut)
        
        let latestFeed = uniqueImageFeed().local
        let latestTimeStamp = Date()
        insert((latestFeed,latestTimeStamp), to: sut)
        
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimeStamp))
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }
    
    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line){
        
         let deletionError = deleteCache(from: sut)
         
         XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
         expect(sut, toRetrieve: .empty)
    }
    
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line){
        
        insert((uniqueImageFeed().local,Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError,"Expected non empty cache deletion to succeed")
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line){
        
        insert((uniqueImageFeed().local,Date()), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #file, line: UInt = #line){
        var completedExpectationInOrder = [XCTestExpectation]()
        
        
        let opt1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedExpectationInOrder.append(opt1)
            opt1.fulfill()
        }
        
        
        let opt2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedExpectationInOrder.append(opt2)
            opt2.fulfill()
        }
        
        let opt3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedExpectationInOrder.append(opt3)
            opt3.fulfill()
        }
        
        waitForExpectations(timeout: 5)
        XCTAssertEqual(completedExpectationInOrder, [opt1,opt2,opt3],"Expected side effects to run serially but run in wrong order")
    }
    
    
    
    @discardableResult
     func insert(_ cache: (feed: [LocalFeedImage],timestamp: Date), to sut: FeedStore) -> Error?{
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp){ receivedInsertionError in
            insertionError = receivedInsertionError
                    exp.fulfill()
       }
       wait(for: [exp],timeout: 1.0)
       return insertionError
    }
    
    func deleteCache(from sut: FeedStore) -> Error? {
        
        let exp = expectation(description: "Wait for cache deletion")
        
        var deletionError: Error?
        sut.deleteCachedFeed{ receivedDeletionError in
            deletionError = receivedDeletionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        expect(sut, toRetrieve: .empty)
        return deletionError
    }
    
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult,file: StaticString = #file,line: UInt = #line) {
        
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult,file: StaticString = #file,line: UInt = #line){
        
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve{ retrievedResult in
            switch (expectedResult,retrievedResult) {
            case (.empty, .empty), (.failure,.failure):
                break
                
            case let (.found(expected),.found(retrieved)):
                XCTAssertEqual(retrieved.feed, expected.feed,file: file,line: line)
                XCTAssertEqual(retrieved.timestamp, expected.timestamp,file: file,line:line)
                
            default:
               XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead",file: file,line: line)
                
            }
            exp.fulfill()
        }
        
        wait(for: [exp],timeout: 1.0)
        
    }
}
