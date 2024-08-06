//
//  FeedItem.swift
//  EssentailFeed
//
//  Created by Rajat Nagavkar on 8/1/24.
//

import Foundation

public struct FeedItem:Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageUrl: URL
    
    init(id: UUID, description: String?, location: String?, imageUrl: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageUrl = imageUrl
    }
}

extension FeedItem: Codable {
    
    private enum Codingkeys: String, CodingKey {
        case id
        case description
        case location
        case imageUrl = "image"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Codingkeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.location = try container.decodeIfPresent(String.self, forKey: .location)
        let string = try container.decode(String.self, forKey: .imageUrl)
        let url = URL(string: string)
        if let url {
            self.imageUrl = url
        } else {
            self.imageUrl = URL(fileURLWithPath: "")    // need to handle this properly
        }
        
    }
}
