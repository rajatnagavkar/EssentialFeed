//
//  RemoteFeedLoader.swift
//  EssentailFeed
//
//  Created by Rajat Nagavkar on 8/2/24.
//

import Foundation



public final class RemoteFeedLoader {
    private let url: URL
    private let client: HttpClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result:Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL,client: HttpClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url){ result in
            switch result {
            case let .success(data,response):
                
                do {
                let items = try FeedItemMapper.map(data, response)
                completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
                
            case .failure:
                completion(.failure(.connectivity))
            }

        }
    }
    
//    private func map(_ data: Data,_ response: HTTPURLResponse) -> Result {
//        do {
//            let items = try FeedItemMapper.map(data, response)
//            return .success(items)
//        } catch {
//            return .failure(.invalidData)
//        }
//    }
    
}
