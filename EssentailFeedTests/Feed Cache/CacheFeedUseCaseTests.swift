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
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) ->  Void
    
    var deleteCacheFeedCount = 0
    
    var insertions = [(items: [FeedItem], timestamp: Date)]()
    
    private var deletionCompletion = [DeletionCompletion]()
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deleteCacheFeedCount += 1
        deletionCompletion.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0 ){
        deletionCompletion[index](error)
    }
    
    func completeDeletionSuccessful(at index: Int = 0){
        deletionCompletion[index](nil)
    }
    
    func insert(_ items: [FeedItem],timestamp: Date) {
        insertions.append((items, timestamp))
    }
    
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_,store) = makeSUT()
        XCTAssertEqual(store.deleteCacheFeedCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut,store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCacheFeedCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut,store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        let deletionError = anyError()
        
        sut.save(items)
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertions.count, 0)
    }
    
    
    func test_save_requestNewCacheInsertionWithTimeStampOnSuccessfulDeletion() {
        let timeStamp = Date()
        let (sut,store) = makeSUT(currentDate: {timeStamp})
        let items = [uniqueItem(),uniqueItem()]
        
        sut.save(items)
        store.completeDeletionSuccessful()
        
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timestamp, timeStamp)
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
