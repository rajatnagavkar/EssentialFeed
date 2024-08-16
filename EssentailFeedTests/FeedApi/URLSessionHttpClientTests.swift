//
//  URLSessionHttpClientTests.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 8/12/24.
//

import XCTest
import EssentailFeed


class URLSessionHttpClient {
    private let session: URLSession
    
    init(session: URLSession = . shared) {
        self.session = session
    }
    
    func get(from url: URL,completion: @escaping (HTTPClientResult) -> Void){
        session.dataTask(with: url) { _, _, error  in
        
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHttpClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_performGetRequestWithUrl(){
        
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequest{ request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(from: url){_ in}
        wait(for: [exp], timeout: 1.0)
       
    }
    
    func test_getFromURL_failsOnRequestError() {
        
        let error = NSError(domain: "Some error", code: 1)
        URLProtocolStub.stub(data:nil,response:nil,error: error)
        
        
        let sut = URLSessionHttpClient()
        let exp = expectation(description: "Wait for completion")
        makeSUT().get(from: anyURL()){ result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertNotNil(receivedError)
            default:
                XCTFail("Expected to receive failure error \(error) but received \(result)")
                
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
       
       
    }
    
    // MARK: Helpers
    func makeSUT(file: StaticString = #file,
                         line: UInt = #line) -> URLSessionHttpClient {
        let sut = URLSessionHttpClient()
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
    }
    
    private func anyURL() -> URL{
        return URL(string: "http://a-url.com")!
    }
  
    
    private class URLProtocolStub: URLProtocol {
      
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?,response: URLResponse?, error: Error?){
            stub = Stub(data: data,response:response,error: error)
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequest() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self,didReceive: response,cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}

