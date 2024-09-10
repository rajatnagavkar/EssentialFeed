//
//  LocalFeedItem.swift
//  EssentailFeed
//
//  Created by Rajat Nagavkar on 9/10/24.
//

import Foundation

public struct LocalFeedItem:Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageUrl: URL
    
    public init(id: UUID, description: String?, location: String?, imageUrl: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageUrl = imageUrl
    }
}
