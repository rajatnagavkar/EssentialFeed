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
        
        expect(sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        
        let (sut,store) = makeSUT()
        let retrievalError = anyNSError()
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let lessThanSevendDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut,store) = makeSUT(currentDate: {
            fixedCurrentDate
        })
        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrieval(with: feed.local,timestamp: lessThanSevendDaysOldTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let sevendDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let (sut,store) = makeSUT(currentDate: {
            fixedCurrentDate
        })
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local,timestamp: sevendDaysOldTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let moreThanSevendDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let (sut,store) = makeSUT(currentDate: {
            fixedCurrentDate
        })
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local,timestamp: moreThanSevendDaysOldTimestamp)
        }
    }
    
    
    func test_load_deletesCacheOnRetrievalError(){
        let (sut,store) = makeSUT()
        
        sut.load{_ in}
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCachedFeed])
    }
    
    func test_load_doesNotDeletesCacheOnEmptyCache(){
        let (sut,store) = makeSUT()
        
        sut.load{_ in}
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,file: StaticString = #file,
                         line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store,currentDate: currentDate)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void,
                        file: StaticString = #file,
                                             line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        
        sut.load{ receivedResult in
            switch (receivedResult,expectedResult) {
            case let (.success(receivedImages),.success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages,file: file,line: line)
                
            case let (.failure(receivedError as NSError),.failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError,file: file,line: line)
            default:
                XCTFail("Expected result \(expectedResult),got \(receivedResult) instead")
            }
           
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
       
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    func uniqueImage() -> FeedImage{
        FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]){
        let models = [uniqueImage(),uniqueImage()]
        let localItems = models.map{ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
        return (models,localItems)
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    
    
}

private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
