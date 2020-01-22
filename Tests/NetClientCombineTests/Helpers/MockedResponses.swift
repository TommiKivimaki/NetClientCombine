// Copyright © 22.1.2020 Tommi Kivimäki.

import Foundation

// Responses
class MockedResponses {
  let validResponse = HTTPURLResponse(url: URL(string: "http://localhost:8080")!,
                                      statusCode: 200,
                                      httpVersion: nil,
                                      headerFields: nil)
  
  let invalidResponse = URLResponse(url: URL(string: "http://localhost:8080")!,
                                    mimeType: nil,
                                    expectedContentLength: 0,
                                    textEncodingName: nil)
  
  let invalidResponse300 = HTTPURLResponse(url: URL(string: "http://localhost:8080")!,
                                           statusCode: 300,
                                           httpVersion: nil,
                                           headerFields: nil)
  let invalidResponse401 = HTTPURLResponse(url: URL(string: "http://localhost:8080")!,
                                           statusCode: 401,
                                           httpVersion: nil,
                                           headerFields: nil)
  
  let networkError = NSError(domain: "NSURLErrorDomain",
                             code: -1004, //kCFURLErrorCannotConnectToHost
    userInfo: nil)
  
  let networkConstrainedError = URLError.NetworkUnavailableReason.constrained
}


// Reponse data
struct MockedResponseData {
  static let getResponse = """
            { "message": "GET response" }
    """
  
  static let postResponse = """
          { "message": "POST response" }
  """
  
  static let deleteResponse = """
          { "message": "DELETE response" }
  """
  
  static let regularDataResponse = """
          { "message": "REGULAR DATA response takes more bytes." }
  """
  
  static let lowDataResponse = """
          { "message": "LOW DATA response" }
  """
}
