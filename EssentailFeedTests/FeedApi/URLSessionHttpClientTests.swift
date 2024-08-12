//
//  URLSessionHttpClientTests.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 8/12/24.
//

import XCTest
import EssentailFeed


protocol HttpSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> HttpSessionTask
}

protocol HttpSessionTask{
    func resume()
}
class URLSessionHttpClient {
    private let session: HttpSession
    
    init(session: HttpSession) {
        self.session = session
    }
    
    func get(from url: URL,completion: @escaping (HTTPClientResult) -> (Void)){
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHttpClientTests: XCTestCase {
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "http://a-url.com")!
        let session = HttpSessionSpy()
        let task = URLSeesionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHttpClient(session: session)
        sut.get(from: url){_ in}
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://a-url.com")!
        let session = HttpSessionSpy()
        let error = NSError(domain: "Some error", code: 1)
        
        session.stub(url: url, error: error)
        let sut = URLSessionHttpClient(session: session)
        
        let exp = expectation(description: "Wait for completion")
        sut.get(from: url){ result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
                
            default:
                XCTFail("Expected to receive failure error \(error) but received \(result)")
                
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private class HttpSessionSpy: HttpSession {
      
        private var stubs = [URL: Stub]()
        
        struct Stub{
            var task: HttpSessionTask
            var error: Error?
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> HttpSessionTask {
                guard let stub = stubs[url] else {
                fatalError("Couldn't find stub with \(url)")
            }
            completionHandler(nil,nil,stub.error)
            return stub.task
        }
        
        func stub(url: URL, task: HttpSessionTask = FakeURLSessionDataTask(),error: NSError? = nil ){
            stubs[url] = Stub(task: task, error: error)
        }
    }
}

private class FakeURLSessionDataTask: HttpSessionTask {
    func resume() { }
}

private class URLSeesionDataTaskSpy: HttpSessionTask {
    var resumeCallCount = 0
    
    func resume() {
        resumeCallCount += 1
    }
}
