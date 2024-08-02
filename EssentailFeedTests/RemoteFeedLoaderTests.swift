//
//  RemoteFeedLoaderTests.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 8/2/24.
//

import XCTest


class RemoteFeedLoader {
    func load() {
        HttpClient.shared.get(from: URL(string: "https://a-url.com")!)
    }
}

class HttpClient {
    static var shared =  HttpClient()
    
    func get(from url: URL){}
    
    
}

class HTTPClientSpy: HttpClient {
    
    override func get(from url: URL){
        requestedURL = url
    }
    
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        HttpClient.shared = client
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromUrl() {
        let client = HTTPClientSpy()
        HttpClient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}

