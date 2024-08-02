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
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestsDataFromUrl() {
        let url = URL(string: "https://q-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(url, client.requestedURL)
    }
    
    
    func test_loadTwice_requestsDataFromUrlTwice() {
        let url = URL(string: "https://q-url.com")!
        let (sut,client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url,url])
    }
    
    private func makeSUT(url: URL = URL(string: "https://q-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut,client)
    }
    
   private class HTTPClientSpy: HttpClient {
       var requestedURL: URL?
       var requestedURLs = [URL]()
       
        func get(from url: URL){
            requestedURL = url
            requestedURLs.append(url)
        }
         
    }

}

