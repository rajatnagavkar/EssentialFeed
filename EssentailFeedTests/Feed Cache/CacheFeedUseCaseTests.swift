//
//  CacheFeedUseCaseTests.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 9/6/24.
//

import XCTest
import EssentailFeed


class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_,store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut,store) = makeSUT()
        let feed = uniqueImageFeed()
        
        sut.save(feed.models){_ in}
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut,store) = makeSUT()
        let feed = uniqueImageFeed()
        let deletionError = anyError()
        
        sut.save(feed.models){_ in}
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    
    func test_save_requestNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        let timeStamp = Date()
        let feed = uniqueImageFeed()
        
        let (sut,store) = makeSUT(currentDate: {timeStamp})
        sut.save(feed.models){_ in}
        store.completeDeletionSuccessful()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(feed.local, timeStamp)])
        
    }
    
    func test_save_failsONDeletionError() {
        let (sut,store) = makeSUT()
        
        let deletionError = anyError()
        
        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
       
    }
    
    func test_save_failsOnInsertionError() {
        let (sut,store) = makeSUT()
        
        let insertionError = anyError()
        
        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessful()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion(){
        let (sut,store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessful()
            store.completeInsertionSuccessfully()
        })
        
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models){
            receivedResults.append($0)
        }
        
        sut = nil
        
        store.completeDeletion(with: anyError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.SaveResult]()
        sut?.save(uniqueImageFeed().models){
            receivedResults.append($0)
        }
        
        
        store.completeDeletionSuccessful()
        sut = nil
        store.completeInsertion(with: anyError())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }

    // MARK: - Helpers
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
    
    private func anyError() -> NSError {
        return NSError(domain: "any Error", code: 0)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,file: StaticString = #file,
                         line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store,currentDate: currentDate)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for save copletion")
        
        
        var receivedError: Error?
        sut.save(uniqueImageFeed().models){ error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError)
    }
    
    
}
