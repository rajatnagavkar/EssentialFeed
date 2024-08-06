//
//  RemoteFeedLoader.swift
//  EssentailFeed
//
//  Created by Rajat Nagavkar on 8/2/24.
//

import Foundation

public enum HTTPClientResult {
    case success(Data,HTTPURLResponse)
    case failure(Error)
}

public protocol HttpClient {
    func get(from url: URL, completion:  @escaping (HTTPClientResult) -> Void)
}



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
            case let .success(data,_):
                
                if let root = try? JSONDecoder().decode(Root.self, from: data){
                    completion(.success(root.items))
                } else {
                    completion(.failure(.invalidData))
                }
                
            case .failure:
                completion(.failure(.connectivity))
            }
           
            
        }
    }
}

private struct Root: Decodable {
    let items: [FeedItem]
}
