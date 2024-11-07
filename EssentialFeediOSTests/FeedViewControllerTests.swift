//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Rajat Nagavkar on 11/6/24.
//

import XCTest

final class FeedViewController{
    init(loader: FeedViewControllerTests.LoaderSpy) {
        
    }
}

final class FeedViewControllerTests: XCTestCase {

   
    func test_init_DoesNotLoadFeed(){
        let loader = LoaderSpy()
        let _ = FeedViewController(loader: loader)
       
        XCTAssertEqual(loader.loaderCallCount, 0)
    }
    
    class LoaderSpy{
        private(set) var loaderCallCount = 0
    }

}
