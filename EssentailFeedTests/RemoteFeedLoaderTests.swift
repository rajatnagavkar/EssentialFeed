//
//  RemoteFeedLoaderTests.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 8/2/24.
//

import XCTest


class RemoteFeedLoader {
    
}

class HttpClient {
    var urlRequest: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HttpClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.urlRequest)
    }
}

