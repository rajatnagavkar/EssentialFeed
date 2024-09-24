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
    ///The completion handler can be invoked in any thread
    ///Clients are responsible to dispatch to appropriate threads, if needed.
    func get(from url: URL, completion:  @escaping (HTTPClientResult) -> Void)
}

