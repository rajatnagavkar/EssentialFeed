//
//  CacheFeedUseCaseTests.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 9/6/24.
//

import XCTest
import EssentailFeed

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    init(store: FeedStore,currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem],completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [unowned self] error in
            completion(error)
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        
        }
    }
}

class FeedStore{
    typealias DeletionCompletion = (Error?) ->  Void
    
    
    enum ReceivedMessages: Equatable {
        case deleteCachedFeed
        case insert([FeedItem], Date)
    }
    
    private(set) var receivedMessages = [ReceivedMessages]()
    
    private var deletionCompletion = [DeletionCompletion]()
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletion.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0 ){
        deletionCompletion[index](error)
    }
    
    func completeDeletionSuccessful(at index: Int = 0){
        deletionCompletion[index](nil)
    }
    
    func insert(_ items: [FeedItem],timestamp: Date) {
        receivedMessages.append(.insert(items, timestamp))
    }
    
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_,store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut,store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        
        sut.save(items){_ in}
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut,store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        let deletionError = anyError()
        
        sut.save(items){_ in}
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    
    func test_save_requestNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        let timeStamp = Date()
        let (sut,store) = makeSUT(currentDate: {timeStamp})
        let items = [uniqueItem(),uniqueItem()]
        
        sut.save(items){_ in}
        store.completeDeletionSuccessful()
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timeStamp)])
        
    }
    
    func test_save_failsONDeletionError() {
        let items = [uniqueItem(),uniqueItem()]
        let (sut,store) = makeSUT()
        
        let deletionError = anyError()
        
        let exp = expectation(description: "Wait for save copletion")
        
        
        var receivedError: Error?
        sut.save(items){ error in
            receivedError = error
            exp.fulfill()
        }
        store.completeDeletion(with: deletionError)
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, deletionError)
    }

    // MARK: - Helpers
    func uniqueItem() -> FeedItem{
        FeedItem(id: UUID(), description: "any", location: "any", imageUrl: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func anyError() -> NSError {
        return NSError(domain: "any Error", code: 0)
    }
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init,file: StaticString = #file,
                         line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store,currentDate: currentDate)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,store)
    }
}
