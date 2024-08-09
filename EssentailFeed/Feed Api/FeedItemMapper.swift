//
//  FeedItemMapper.swift
//  EssentailFeed
//
//  Created by Rajat Nagavkar on 8/8/24.
//

import Foundation


internal final class FeedItemMapper {
    
    private struct Root: Decodable {
        let items: [Item]
        var feed: [FeedItem] {
            return items.map{$0.item}
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(id: id,
                            description: description,
                            location: location,
                            imageUrl: image)
        }
    }

    private static var OK_200: Int {return 200}
    
    internal static func map(_ data: Data,_ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map{$0.item}
    }
    
    internal static func map(_ data: Data,_ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
           
       
        return .success(root.feed)
       
    }
}

