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
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

class FeedStore {
    var deleteCacheFeedCount = 0
    
    func deleteCachedFeed() {
        deleteCacheFeedCount += 1
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
    
    // MARK: - Helpers
    func uniqueItem() -> FeedItem{
        FeedItem(id: UUID(), description: "any", location: "any", imageUrl: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    private func makeSUT(file: StaticString = #file,
                         line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store,file: file,line: line)
        trackForMemoryLeaks(sut,file: file,line: line)
        return (sut,store)
    }
}
