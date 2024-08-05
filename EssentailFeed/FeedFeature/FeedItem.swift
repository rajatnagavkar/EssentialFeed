//
//  FeedItem.swift
//  EssentailFeed
//
//  Created by Rajat Nagavkar on 8/1/24.
//

import Foundation

public struct FeedItem:Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageUrl: URL
}
