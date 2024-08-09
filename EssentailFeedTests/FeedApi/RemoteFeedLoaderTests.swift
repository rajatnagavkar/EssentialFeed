//
//  RemoteFeedLoaderTests.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 8/2/24.
//

import XCTest
@testable import EssentailFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    
    func test_init_doesNotRequestDataFromURL() {
        let (_,client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromUrl() {
        let url = URL(string: "https://q-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        sut.load{ _ in}
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    
    func test_loadTwice_requestsDataFromUrlTwice() {
        let url = URL(string: "https://q-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        sut.load{ _ in}
        sut.load{ _ in}
        
        XCTAssertEqual(client.requestedURLs, [url,url])
    }
    
    func test_loadDeliversErrorOnClientError() {
        let (sut,client) = makeSUT()
        
        expect(sut, toCompleteWithResult: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
        
    
    }
    
    func test_loadDeliversErrorNon200HttpResponse() {
        let (sut,client) = makeSUT()
        
        let samples =  [199,201,300,400,500]
        
        samples.enumerated().forEach { index,code in
            
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let json = makeItemsJson([])
                client.complete(withStatusCode: code, data: json,at: index)
            }
        }
    }
    
    func test_load_DeliversErrorOn200HttpResponseWithInvalidJson() {
        let (sut,client) = makeSUT()
        
        expect(sut, toCompleteWithResult: failure(.invalidData)) {
            let invalidJson = Data(Data(bytes: "invalid Json".utf8))
            client.complete(withStatusCode: 200,data: invalidJson)
        }
    }
    
    func test_load_DeliversNoItemsOn200HTTPResponseOnEmptyList() {
        let (sut,client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJson = makeItemsJson([])
            
            client.complete(withStatusCode: 200,data: emptyListJson)
        }
        
    }
    
    func test_load_DeliversItemsOn200HttpResponseWithJsonItems() {
        let (sut,client) = makeSUT()
        
        let item1 = makeItem(
                    id: UUID(),
                    imageUrl: URL(string: "http://a-url.com")!)

        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageUrl: URL(string: "http://another-url.com")!)
        
        let items = [item1.model,item2.model]
        expect(sut, toCompleteWithResult: .success(items)) {
            let json = makeItemsJson([item1.json,item2.json])
            client.complete(withStatusCode: 200, data: json)
        }
        
    }
    
    func test_load_doesNotDeliverResultAsterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://another-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load {capturedResults.append($0)}
        
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJson([]))
        XCTAssertTrue(capturedResults.isEmpty)
    }
        
    private func makeSUT(url: URL = URL(string: "https://q-url.com")!,file: StaticString = #file,
                         line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut,file: file,line: line)
        trackForMemoryLeaks(client,file: file,line: line)
        return (sut,client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject,file: StaticString = #file,
                                     line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance,"Instance should have been deallocated. Potential memory leak.",file: file,line: line)
        }
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    
    private func makeItem(id: UUID,description: String? = nil  ,location: String? = nil,imageUrl: URL) -> (model: FeedItem, json: [String: Any]) {
        let feedItem = FeedItem(id: id, description: description, location: location, imageUrl: imageUrl)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageUrl.absoluteString
        ].reduce(into: [String: Any]()) { (acc, e) in
            if let value = e.value { acc[e.key] = value }
        }
        
        return (feedItem,json)
    }
    
    private func makeItemsJson(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    func expect(_ sut: RemoteFeedLoader,
                toCompleteWithResult expectedResult: RemoteFeedLoader.Result,
                when action: () -> Void,file: StaticString = #file,
                line: UInt = #line){
        
        let exp = expectation(description: "Waiting for load completion")
        
        sut.load { receivedResult in
            switch(receivedResult,expectedResult) {
            case let (.success(receivedResult),.success(expectedResult)):
                
                XCTAssertEqual(receivedResult, expectedResult,file: file,line: line)
                
            case let (.failure(receivedError as RemoteFeedLoader.Error),.failure(expectedError as RemoteFeedLoader.Error)):
                
                XCTAssertEqual(receivedError , expectedError ,file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead",file: file,line: line)
            }
            
            exp.fulfill()
            
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
   private class HTTPClientSpy: HttpClient {
       
       var messages =  [(url: URL, completion: (HTTPClientResult) -> Void)]()
       
       var requestedURLs: [URL] {
           return messages.map{$0.url}
       }
       
       func get(from url: URL,completion: @escaping (HTTPClientResult) -> Void){
           messages.append((url,completion))
        }

       func complete(with error : Error, at index: Int = 0){
           messages[index].completion(.failure(error))
       }
       
       func complete(withStatusCode code: Int,data: Data,at index: Int = 0){
           let response = HTTPURLResponse(url: requestedURLs[index],
                                          statusCode: code,
                                          httpVersion: nil,
                                          headerFields: nil)!
           
           messages[index].completion(.success(data,response))
       }
         
    }

}

