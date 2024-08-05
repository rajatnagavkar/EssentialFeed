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
        
        expect(sut, toCompleteWithError: .connectivity) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
        
    
    }
    
    func test_loadDeliversErrorOn200HttpResponse() {
        let (sut,client) = makeSUT()
        
        let samples =  [199,201,300,400,500]
        
        samples.enumerated().forEach { index,code in
            
            expect(sut, toCompleteWithError: .invalidData) {
                client.complete(withStatusCode: code,at: index)
            }
          
        }
    }
    
    func test_load_DeliversErrorOn200HttpResponseWithInvalidJson() {
        let (sut,client) = makeSUT()
        
        expect(sut, toCompleteWithError: .invalidData) {
            let invalidJson = Data(Data(bytes: "invalid Json".utf8))
            client.complete(withStatusCode: 200,data: invalidJson )
        }
    }
    
    private func makeSUT(url: URL = URL(string: "https://q-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut,client)
    }
    
    func expect(_ sut: RemoteFeedLoader,toCompleteWithError error: RemoteFeedLoader.Error, when action: () -> Void,file: StaticString = #file,
                line: UInt = #line){
        
        var capturedErrors = [ RemoteFeedLoader.Error]()
        sut.load { capturedErrors.append($0) }
        
        action()
        
        XCTAssertEqual(capturedErrors,[error],file: file,line: line)
        
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
       
       func complete(withStatusCode code: Int,data: Data = Data()  ,at index: Int = 0){
           let response = HTTPURLResponse(url: requestedURLs[index],
                                          statusCode: code,
                                          httpVersion: nil,
                                          headerFields: nil)!
           
           messages[index].completion(.success(data,response))
       }
         
    }

}

