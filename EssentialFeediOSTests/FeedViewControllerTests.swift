//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Rajat Nagavkar on 11/6/24.
//

import XCTest
import UIKit
import EssentailFeed

final class FeedViewController: UIViewController{
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load(completion: { _ in})
    }
}

final class FeedViewControllerTests: XCTestCase {

   
    func test_init_DoesNotLoadFeed(){
        let (_,loader) = makeSUT()
       
        XCTAssertEqual(loader.loaderCallCount, 0)
    }
    
    func test_viewDidLoad_loadFeed(){
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loaderCallCount, 1)
        
    }
    
    func makeSUT(file: StaticString = #file,
                 line: UInt = #line) ->(sut: FeedViewController,loader: LoaderSpy){
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut,loader)
    }
    
    class LoaderSpy: FeedLoader{
        private(set) var loaderCallCount = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loaderCallCount += 1
        }
        
       
        
       
    }

}
