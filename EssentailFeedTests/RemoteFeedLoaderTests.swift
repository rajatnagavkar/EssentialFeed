//
//  RemoteFeedLoaderTests.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 8/2/24.
//

import XCTest


class RemoteFeedLoader {
    let client: HttpClient
    
    init(client: HttpClient) {
        self.client = client
    }
    
    func load() {
       client.get(from: URL(string: "https://a-url.com")!)
    }
}

protocol HttpClient {
    func get(from url: URL)
}

class HTTPClientSpy: HttpClient {
    
    func get(from url: URL){
        requestedURL = url
    }
    
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromUrl() {
        let client = HTTPClientSpy()
       
        let sut = RemoteFeedLoader(client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}

