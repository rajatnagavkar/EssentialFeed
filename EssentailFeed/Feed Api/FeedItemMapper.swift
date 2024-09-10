//
//  FeedItemMapper.swift
//  EssentailFeed
//
//  Created by Rajat Nagavkar on 8/8/24.
//

import Foundation


internal final class FeedItemMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    private static var OK_200: Int {return 200}
    
    
    internal static func map(_ data: Data,_ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
       
    }
    
}

