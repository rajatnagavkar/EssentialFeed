//
//  URLSessionHttpClientTests.swift
//  EssentailFeedTests
//
//  Created by Rajat Nagavkar on 8/12/24.
//

import XCTest
import EssentailFeed

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
        
        let requestError = anyNSError()
        let resultError = resultForError(data: nil, response: nil, error: requestError)
        
    
        XCTAssertNotEqual(resultError as NSError?, requestError)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
       
       XCTAssertNotNil(resultForError(data: nil, response: nil, error: nil))
       XCTAssertNotNil(resultForError(data: nil, response: nonHttpURLResponse(), error: nil))
       XCTAssertNotNil(resultForError(data: anyData(), response: nil, error: nil))
       XCTAssertNotNil(resultForError(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultForError(data: nil, response: nonHttpURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultForError(data: nil, response: anyHttpURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultForError(data: anyData(), response: nonHttpURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultForError(data: anyData(), response: anyHttpURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultForError(data: anyData(), response: nonHttpURLResponse(), error: nil))
        
    }
    
    func test_getFromUrl_succedsOnHttpUrlResponseWithData() {
        let data = anyData()
        let response = anyHttpURLResponse()
        
        
        let receivedValues = resultforValues(data: data, response: response, error: nil)
       
      
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
        
        
    }
    
    func test_getFromUrl_succedsWithEmptyDataOnHttpUrlResponseWithNilData() {
        let response = anyHttpURLResponse()
        let receivedValues = resultforValues(data: nil, response: response, error: nil)
       
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
        
    }
    
     func resultforValues(data: Data?,response: URLResponse?,error: Error?,file: StaticString = #file,
                                 line: UInt = #line) -> (data:Data,response: HTTPURLResponse)?{
        let result = resultFor(data: data, response: response, error: error)
        
         switch result {
         case let .success(data, response):
             return (data,response)
         default:
             XCTFail("Expected success but received \(result) instead",file: file,line: line)
             return nil
         }
    }
    
    private func resultForError(data: Data?,response: URLResponse?,error: Error?,file: StaticString = #file,
                                line: UInt = #line) -> Error?{
        let result = resultFor(data: data, response: response, error: error)
       
        switch result {
        case let .failure(error):
            return error
            
        default:
            XCTFail("Expected failure got \(result) instead",file: file,line: line)
            return nil
        }
        
    }
    
    private func resultFor(data: Data?,response: URLResponse?,error: Error?,file: StaticString = #file,
                           line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data:data,response:response,error: error)
        let sut = makeSUT(file: file,line: line)
        
        var receivedResults: HTTPClientResult!
        let exp = expectation(description: "Wait for completion")
        sut.get(from: anyURL()){ result in
            receivedResults = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        return receivedResults
    }
    
    // MARK: Helpers
    func makeSUT(file: StaticString = #file,
                         line: UInt = #line) -> HttpClient {
        let sut = URLSessionHttpClient()
        trackForMemoryLeaks(sut,file: file,line: line)
        return sut
    }
    
    private func anyData() -> Data{
        return Data(bytes: "any data".utf8)
    }
    
    
    private func anyHttpURLResponse() -> HTTPURLResponse{
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHttpURLResponse() -> URLResponse{
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
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

