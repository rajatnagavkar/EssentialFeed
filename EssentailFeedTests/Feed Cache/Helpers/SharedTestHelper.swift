//
//  SharedTestHelper.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 9/16/24.
//

import Foundation


func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}


func anyURL() -> URL {
    return URL(string: "https://any-url.com")!
}

