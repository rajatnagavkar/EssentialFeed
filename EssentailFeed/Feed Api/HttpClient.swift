//
//  HttpClient.swift
//  EssentailFeed
//
//  Created by Rajat Nagavkar on 8/8/24.
//

import Foundation

public enum HTTPClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HttpClient {
    func get(from url: URL, completion:  @escaping (HTTPClientResult) -> Void)
}

