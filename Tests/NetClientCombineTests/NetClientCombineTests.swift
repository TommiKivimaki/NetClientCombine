import XCTest
import Combine
@testable import NetClientCombine

final class NetClientCombineTests: XCTestCase {

  var testPublisher: ClientPublisher!
  var mockedResponses: MockedResponses!
  let testTimeout: TimeInterval = 1
  
  
  // Store references to request so they stay alive until they complete
  private var disposables = Set<AnyCancellable>()
  
  override func setUp() {
    // Configure testPublisher to use URLSession with a stubbed
    // URLProtocol, which return mocked responses for testURLs
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [URLProtocolStub.self]
    let mockSession = URLSession(configuration: config)
    testPublisher = ClientPublisher(session: mockSession)
    
    self.mockedResponses = MockedResponses()
    
//    let lowDataConfiguration = URLSessionConfiguration.default
//    lowDataConfiguration.allowsConstrainedNetworkAccess = true
//    lowDataConfiguration.allowsExpensiveNetworkAccess = false
//    lowDataConfiguration.allowsCellularAccess = false
  }
  
  override func tearDown() {
    testPublisher = nil
    mockedResponses = nil
  }
  
  
  
  // TODO: Implement the test
  func testAdaptiveSendGetRequest() {
//    let expectation = XCTestExpectation(description: "Response received")
//
//    let url = URL(string: "http://localhost/get")!
//
//    client.adaptiveSend(regularURL: url, lowDataURL: url)
//      .receive(on: DispatchQueue.main)
//      .sink(receiveCompletion: { [weak self] value in
//        guard let self = self else { return }
//        switch value {
//        case .failure:
//          print("FAILED")
//        case .finished:
//          break
//        }
//        },
//            receiveValue: { [weak self] value in
//              guard let self = self else { return }
//              let string = String(data: value, encoding: .utf8)
//              XCTAssertNotNil(string!)
//              print(string!)
//              expectation.fulfill()
//      })
//      .store(in: &disposables)
//
//    wait(for: [expectation], timeout: 10)
  }
  
  
  func testSendGetRequestUsingURLRequest() {
    let getURL = URL(string: "http://localhost:8080/get")
    URLProtocolStub.testURLs = [getURL: Data(MockedResponseData.getResponse.utf8)]
    let getRequest = URLRequest(url: getURL!)
    
    NetClientCombine.publisher = testPublisher
    URLProtocolStub.response = mockedResponses.validResponse
    let publisher = NetClientCombine.send(getRequest)
    
    let validation = validateResponse(publisher: publisher)
    wait(for: validation.expectations, timeout: testTimeout)
    validation.cancellable?.cancel()
  }
  
  func testSendGetRequestUsingURL() {
    let getURL = URL(string: "http://localhost:8080/get")
    URLProtocolStub.testURLs = [getURL: Data(MockedResponseData.getResponse.utf8)]
    
    NetClientCombine.publisher = testPublisher
    URLProtocolStub.response = mockedResponses.validResponse
//    let publisher = NetClientCombine.send(to: getURL!)
    let publisher = NetClientCombine.get(getURL!)
    
    let validation = validateResponse(publisher: publisher)
    wait(for: validation.expectations, timeout: testTimeout)
    validation.cancellable?.cancel()
  }
  
  func testGetRequestAndDecodeResponse() {
    struct Resp: Decodable, Equatable {
      var message: String
    }
    
    let expectedResponseData = Resp(message: "GET response")
    
    let getURL = URL(string: "http://localhost:8080/get")
    URLProtocolStub.testURLs = [getURL: Data(MockedResponseData.getResponse.utf8)]
    
    NetClientCombine.publisher = testPublisher
    URLProtocolStub.response = mockedResponses.validResponse
//    let publisher = NetClientCombine.send(.get, to: getURL!, response: Resp.self)
    let publisher = NetClientCombine.get(getURL!, response: Resp.self)

    let validation =  validateResponse(publisher: publisher, expectedResponse: expectedResponseData)
    wait(for: validation.expectations, timeout: testTimeout)
    validation.cancellable?.cancel()
  }
  
  func testSendPostRequestWithBodyAndDecodeResponse() {
    let postURL = URL(string: "http://localhost:8080/post")
    let headers: [String: String] = [
      "Content-Type": "application/json",
      "Accept": "application/json",
    ]
    
    URLProtocolStub.testURLs = [postURL: Data(MockedResponseData.postResponse.utf8)]
    URLProtocolStub.response = mockedResponses.validResponse
    NetClientCombine.publisher = testPublisher

    struct RequestBody: Codable, Equatable {
      let firstname: String
    }

    struct Resp: Decodable, Equatable {
      let message: String
    }

    let reqBody = RequestBody(firstname: "James")
    let expectedResponseData = Resp(message: "POST response")
    
//    let publisher = NetClientCombine.send(.post, to: postURL!, headers: headers, requestBody: reqBody, response: Resp.self)
    let publisher = NetClientCombine.post(postURL!, headers: headers, requestBody: reqBody, response: Resp.self)
    let validation = validateResponse(publisher: publisher, expectedResponse: expectedResponseData)
    wait(for: validation.expectations, timeout: testTimeout)
    validation.cancellable?.cancel()
  }
  
  func testSendDeleteRequest() {
    let deleteURL = URL(string: "http://localhost:8080/delete")
    
    URLProtocolStub.testURLs = [deleteURL: Data(MockedResponseData.deleteResponse.utf8)]
    URLProtocolStub.response = mockedResponses.validResponse
    NetClientCombine.publisher = testPublisher
    
//    let publisher = NetClientCombine.send(.delete, to: deleteURL!)
    let publisher = NetClientCombine.delete(deleteURL!)
    let validation = validateResponse(publisher: publisher)
    wait(for: validation.expectations, timeout: testTimeout)
    validation.cancellable?.cancel()
  }
  
  func testDefaultHeaders() {
//    let expectation = XCTestExpectation(description: "Response received")
//
//    let url = URL(string: "http://localhost/headers")!
//
//    struct HeaderDictionary: Decodable, Equatable {
//      let accept: String
//      let contentType: String
//      let userAgent: String // Decoding also User-Agent to see the response. It's not part of the HTTPHeaders.defaults()
//
//      enum CodingKeys: String, CodingKey {
//        case accept = "Accept"
//        case contentType = "Content-Type"
//        case userAgent = "User-Agent"
//      }
//    }
//
//    struct ResponseBody: Decodable {
//      let headers: HeaderDictionary
//    }
//
//
//    client.get(url, headers: HTTPHeaders.defaults(), response: ResponseBody.self)
//      .receive(on: RunLoop.main)
//      .sink(receiveCompletion: { [weak self] completion in
//        guard let self = self else { return }
//        switch completion {
//        case .finished:
//          break
//        case .failure(let error):
//          print(error)
//          XCTFail()
//        }
//        }, receiveValue: { [weak self] value in
//          guard let self = self else { return }
//          print(value)
//          XCTAssertEqual(value.headers.accept, "application/json")
//          XCTAssertEqual(value.headers.contentType, "application/json")
//          expectation.fulfill()
//      })
//      .store(in: &disposables)
//
//    wait(for: [expectation], timeout: 10)
  }
  
  
  static var allTests = [
    ("testAdaptiveSendGetRequest", testAdaptiveSendGetRequest),
    ("testSendGetRequestUsingURLRequest", testSendGetRequestUsingURLRequest),
    ("testSendGetRequestUsingURL", testSendGetRequestUsingURL),
    ("testGetRequestAndDecodeResponse", testGetRequestAndDecodeResponse),
    ("testSendPostRequestWithBodyAndDecodeResponse", testSendPostRequestWithBodyAndDecodeResponse),
    ("testSendDeleteRequest", testSendDeleteRequest),
    ("testDefaultHeaders", testDefaultHeaders)
  ]
}
