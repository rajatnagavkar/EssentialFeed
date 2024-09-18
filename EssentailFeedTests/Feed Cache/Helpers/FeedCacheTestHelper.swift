//
//  FeedCacheTestHelper.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 9/16/24.
//

import Foundation
import EssentailFeed

func uniqueImage() -> FeedImage{
    FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]){
    let models = [uniqueImage(),uniqueImage()]
    let localItems = models.map{ LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    return (models,localItems)
}

extension Date {
    
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -minusFeedCacheMaxAgeInDays)
    }
    
    private var minusFeedCacheMaxAgeInDays: Int {
       return 7
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
