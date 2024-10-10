//
//  EssentailFeedCacheIntegrationTests.swift
//  EssentailFeedCacheIntegrationTests
//
//  Created by Rajat Nagavkar on 10/10/24.
//

import XCTest
import EssentailFeed

final class EssentailFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setUpEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }

    func testLoadDeliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for load Completion")
        
        sut.load { result in
            switch result {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, [],"Expected Empty Feeed")
                
            case let .failure(error):
                XCTFail("Expected successfull feed result, got \(error) instead")
            }
            
            exp.fulfill()
        }
        wait(for: [exp],timeout: 1.0)
    }
    
    //MARK: Helper
    private func makeSUT(file: StaticString = #file,line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file,line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func setUpEmptyStoreState(){
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
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
    
}
