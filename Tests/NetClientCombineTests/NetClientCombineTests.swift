import XCTest
import Combine
@testable import NetClientCombine

final class NetClientCombineTests: XCTestCase {

  var testPublisher: ClientPublisher!
  var lowDataPublisher: ClientPublisher!
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
    
    // Create a low data publisher
    let lowDataConfig = URLSessionConfiguration.ephemeral
    lowDataConfig.allowsConstrainedNetworkAccess = true
    lowDataConfig.allowsExpensiveNetworkAccess = false
    lowDataConfig.allowsCellularAccess = false
    lowDataConfig.protocolClasses = [URLProtocolStub.self]
    let lowDataSession = URLSession(configuration: lowDataConfig)
    lowDataPublisher = ClientPublisher(session: lowDataSession)
    
    self.mockedResponses = MockedResponses()
  }
  
  override func tearDown() {
    testPublisher = nil
    mockedResponses = nil
  }
  
  
  
  // TODO: Implement the test
  func testAdaptiveSendGetRequest() {
    
    // Setup URLPrototolcStub for this test
    let lowDataURL = URL(string: "http://localhost:8080/lowdata")
    let regularDataURL = URL(string: "http://localhost:8080/regulardata")
    URLProtocolStub.testURLs = [lowDataURL: Data(MockedResponseData.lowDataResponse.utf8)]
    URLProtocolStub.testURLs = [regularDataURL: Data(MockedResponseData.regularDataResponse.utf8)]
    URLProtocolStub.response = mockedResponses.validResponse

    // Test with a regular test publisher
    NetClientCombine.publisher = testPublisher
    let publisher = NetClientCombine.adaptiveSend(regularURL: regularDataURL!, lowDataURL: lowDataURL!)
    let validation = validateResponse(publisher: publisher)
    wait(for: validation.expectations, timeout: testTimeout)
    validation.cancellable?.cancel()
    
    // Test with a publisher configured for low data
    NetClientCombine.publisher = lowDataPublisher
    let lowPublisher = NetClientCombine.adaptiveSend(regularURL: regularDataURL!, lowDataURL: lowDataURL!)
    let lowValidation = validateResponse(publisher: lowPublisher)
    wait(for: lowValidation.expectations, timeout: testTimeout)
    lowValidation.cancellable?.cancel()
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
  
  
  static var allTests = [
    ("testAdaptiveSendGetRequest", testAdaptiveSendGetRequest),
    ("testSendGetRequestUsingURLRequest", testSendGetRequestUsingURLRequest),
    ("testSendGetRequestUsingURL", testSendGetRequestUsingURL),
    ("testGetRequestAndDecodeResponse", testGetRequestAndDecodeResponse),
    ("testSendPostRequestWithBodyAndDecodeResponse", testSendPostRequestWithBodyAndDecodeResponse),
    ("testSendDeleteRequest", testSendDeleteRequest)
  ]
}
