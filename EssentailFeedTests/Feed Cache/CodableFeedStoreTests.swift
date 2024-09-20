//
//  CodableFeedStoreTests.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 9/20/24.
//

import XCTest
import EssentailFeed

class CodableFeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timeStamp: Date
        
        var localFeed: [LocalFeedImage]{
            return feed.map{$0.local}
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image: LocalFeedImage){
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let storeURL: URL

    
    init(storeURL: URL)
    {
        self.storeURL = storeURL
    }

    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion){
        guard let data = try? Data(contentsOf: storeURL) else  {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        
        completion(.found(feed: cache.localFeed, timestamp: cache.timeStamp))
    }
    
    func insert(_ feed: [LocalFeedImage],timestamp: Date,completion: @escaping FeedStore.InsertionCompletion){
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(feed: feed.map(CodableFeedImage.init), timeStamp: timestamp))
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}


class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    override func tearDown() {
        super.tearDown()
        
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    func test_retrive_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve{ result in
            
            switch result {
            case .empty:
                break
                
            default:
                XCTFail("Expected Empty result got \(result) instead")
                
            }
            exp.fulfill()
        }
        
        wait(for: [exp],timeout: 1.0)
        
    }
    
    
    func test_retrive_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve{ firstResult in
            sut.retrieve{ secondResult in
                switch (firstResult,secondResult) {
                case (.empty,.empty):
                    break
                    
                default:
                   XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                    
                }
                exp.fulfill()
            }
            
        }
        
        wait(for: [exp],timeout: 1.0)
        
    }
    
    func test_retrievalAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timeStamp = Date()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.insert(feed, timestamp: timeStamp){ insertionError in
            
            XCTAssertNil(insertionError,"Expected feed to be inserted successfully")
            
            sut.retrieve{ retrievedResult in
                switch retrievedResult {
                case let .found(retrievedFeed,retrievedTimestamp):
                    XCTAssertEqual(retrievedFeed, feed)
                    XCTAssertEqual(retrievedTimestamp, timeStamp)
                    break
                    
                default:
                   XCTFail("Expected found result with \(feed) and \(timeStamp) but found \(retrievedResult) instead")
                    
                }
                exp.fulfill()
            }
            
        }
        
        wait(for: [exp],timeout: 1.0)
        
    }
    
    //MARK: Helper
    func makeSUT(file: StaticString = #file,line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file,line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
