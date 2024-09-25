//
//  CodableFeedStoreTests.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 9/20/24.
//

import XCTest
import EssentailFeed




class CodableFeedStoreTests: XCTestCase, FailableFeedStore {
    
    override func setUp() {
        super.setUp()
        
        setupStoreArtifacts()
    }
    
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreArtifacts()
    }
    

    func test_retrive_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
        
    }
    
    
    func test_retrive_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieveTwice: .empty)
        
        
    }
    
    func test_retrieval_deliversFoundValuesOnEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feed,timeStamp), to: sut)
    
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timeStamp))
        
    }
    
    func test_retrieval_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        
        insert((feed,timeStamp), to: sut)
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timeStamp))
    }
    
    func test_retrieve_deliversErrorOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed().local,Date()), to: sut)
        XCTAssertNil(firstInsertionError,"Expected to insert cache successfully")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimeStamp = Date()
        let latestInsertionError = insert((latestFeed,latestTimeStamp), to: sut)
        
        XCTAssertNil(latestInsertionError,"Expected to override cache successfully")
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimeStamp))
        
    }
    
    //MARK: Helper
    func makeSUT(storeURL: URL? = nil,file: StaticString = #file,line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file,line: line)
        return sut
    }
    
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed,timestamp), to: sut)
        
        XCTAssertNotNil(insertionError,"Expected cache insertion to fail with an error")
     
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed,timestamp), to: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_deletion_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
       
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_deletion_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed().local,Date()), to: sut)
        
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError,"Expected non empty cache deletion to succeed")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = noDeletePermissionURL()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError,"Expected non empty cache deletion to succeed")
    }
    
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = noDeletePermissionURL()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_storeSideEffects_RunSerially() {
        let sut = makeSUT()
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
    
    
    
    private func setupStoreArtifacts() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreArtifacts() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
            return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func noDeletePermissionURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }
}
