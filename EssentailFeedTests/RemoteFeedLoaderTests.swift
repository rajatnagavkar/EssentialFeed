//
//  RemoteFeedLoaderTests.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 8/2/24.
//

import XCTest


class RemoteFeedLoader {
    func load() {
        HttpClient.shared.urlRequest = URL(string: "https://a-url.com")
    }
}

class HttpClient {
    static let shared =  HttpClient()
    
    private init(){}
    
    var urlRequest: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HttpClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.urlRequest)
    }
    
    func test_load_requestDataFromUrl() {
        let client = HttpClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.urlRequest)
    }
}

