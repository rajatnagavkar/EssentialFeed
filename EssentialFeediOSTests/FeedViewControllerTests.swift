//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Rajat Nagavkar on 11/6/24.
//

import XCTest

final class FeedViewController: UIViewController{
    private var loader: FeedViewControllerTests.LoaderSpy?
    
    convenience init(loader: FeedViewControllerTests.LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load()
    }
}

final class FeedViewControllerTests: XCTestCase {

   
    func test_init_DoesNotLoadFeed(){
        let loader = LoaderSpy()
        let _ = FeedViewController(loader: loader)
       
        XCTAssertEqual(loader.loaderCallCount, 0)
    }
    
    func test_viewDidLoad_loadFeed(){
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loaderCallCount, 1)
        
    }
    
    class LoaderSpy{
        private(set) var loaderCallCount = 0
        
        func load() {
            loaderCallCount += 1
        }
    }

}
