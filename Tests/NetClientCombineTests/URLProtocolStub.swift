// Copyright © 20.1.2020 Tommi Kivimäki.

import Foundation

/// Test networking with this URLProtocolStub.
/// Configure what to return: data, response or error.
class URLProtocolStub: URLProtocol {
    // this dictionary maps URLs to test data
    static var testURLs = [URL?: Data]()
    static var response: URLResponse?
    static var error: Error?
    
    // say we want to handle all types of request
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canInit(with task: URLSessionTask) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        // If we have a valid URL
        if let url = request.url {
            // and if we have test data for that URL
            if let data = URLProtocolStub.testURLs[url] {
                // then load it immediately
                self.client?.urlProtocol(self, didLoad: data)
            }
        }
        
        // and if we have a response defined then return it
        if let response = URLProtocolStub.response {
            self.client?.urlProtocol(self,
                                     didReceive: response,
                                     cacheStoragePolicy: .notAllowed)
        }
        
        // and if we have an error defined then return it
        if let error = URLProtocolStub.error {
            self.client?.urlProtocol(self, didFailWithError: error)
        }
        // Mark that we've finished
        self.client?.urlProtocolDidFinishLoading(self)
    }

    // Required but does not need to do anything
    override func stopLoading() {

    }
}
