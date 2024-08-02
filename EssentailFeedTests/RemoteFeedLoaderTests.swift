//
//  RemoteFeedLoaderTests.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 8/2/24.
//

import XCTest


class RemoteFeedLoader {
    let client: HttpClient
    let url: URL
    
    init(url: URL,client: HttpClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
       client.get(from: url)
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
        let url = URL(string: "https://q-url.com")!
        let client = HTTPClientSpy()
        
        _ = RemoteFeedLoader(url:url,client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromUrl() {
        let url = URL(string: "https://q-url.com")!
        let client = HTTPClientSpy()
       
        let sut = RemoteFeedLoader(url: url,client: client)
        
        sut.load()
        
        XCTAssertEqual(url, client.requestedURL)
    }
}

