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
        
        expect(sut, toLoad: [])
        
    }
    
    func test_loadDeliversItemsSavedOnSeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models
        
        save(feed, with: sutToPerformSave)
        
        
        expect(sutToPerformLoad, toLoad: feed)
    }
    
    func test_save_overridesItemsSavedOnASeparateInstance(){
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let firstfeed = uniqueImageFeed().models
        let latestfeed = uniqueImageFeed().models
        
        save(firstfeed, with: sutToPerformFirstSave)
        
        save(latestfeed, with: sutToPerformLastSave)
        
        expect(sutToPerformLoad, toLoad: latestfeed)
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
    
    private func save(_ feed: [FeedImage],with loader: LocalFeedLoader,file: StaticString = #file,line: UInt = #line) {
        let savExp = expectation(description: "Wait for save completion")
        
        loader.save(feed) { saveError in
            XCTAssertNil(saveError,"Expected to save feed successfully")
            savExp.fulfill()
        }
        wait(for: [savExp], timeout: 1.0)
        
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage],file: StaticString = #file,line: UInt = #line) {
        let exp = expectation(description: "Wait for load Completion")
        
        sut.load { result in
            switch result {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed,expectedFeed,file: file,line: line)
                
            case let .failure(error):
                XCTFail("Expected successfull feed result, got \(error) instead",file: file,line: line)
            }
            
            exp.fulfill()
        }
        wait(for: [exp],timeout: 1.0)
        
        
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
