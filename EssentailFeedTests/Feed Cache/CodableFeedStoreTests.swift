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
    
    //MARK: Helper
    func makeSUT(file: StaticString = #file,line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file,line: line)
        return sut
    }
    
    private func insert(_ cache: (feed: [LocalFeedImage],timestamp: Date), to sut: CodableFeedStore){
        let exp = expectation(description: "Wait for cache insertion")
        
        sut.insert(cache.feed, timestamp: cache.timestamp){ insertionError in
            
            XCTAssertNil(insertionError,"Expected feed to be inserted successfully")
                    exp.fulfill()
       }
       wait(for: [exp],timeout: 1.0)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult,file: StaticString = #file,line: UInt = #line) {
        
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult,file: StaticString = #file,line: UInt = #line){
        
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve{ retrievedResult in
            switch (expectedResult,retrievedResult) {
            case (.empty, .empty):
                break
                
            case let (.found(expected),.found(retrieved)):
                XCTAssertEqual(retrieved.feed, expected.feed,file: file,line: line)
                XCTAssertEqual(retrieved.timestamp, expected.timestamp,file: file,line:line)
                
            default:
               XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead",file: file,line: line)
                
            }
            exp.fulfill()
        }
        
        wait(for: [exp],timeout: 1.0)
        
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
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
}
