//
//  HttpClient.swift
//  EssentailFeed
//
//  Created by Rajat Nagavkar on 8/8/24.
//

import Foundation


public protocol HttpClient {
    
    typealias Result  = Swift.Result<(Data,HTTPURLResponse),Error>
    
    ///The completion handler can be invoked in any thread
    ///Clients are responsible to dispatch to appropriate threads, if needed.
    func get(from url: URL, completion:  @escaping (Result) -> Void)
}

