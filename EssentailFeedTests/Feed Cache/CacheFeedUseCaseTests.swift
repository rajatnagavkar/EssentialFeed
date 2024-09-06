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
        let store = FeedStore()
        _ =  LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCacheFeedCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        let items = [uniqueItem(),uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCacheFeedCount, 1)
    }
    
    func uniqueItem() -> FeedItem{
        FeedItem(id: UUID(), description: "any", location: "any", imageUrl: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
}
