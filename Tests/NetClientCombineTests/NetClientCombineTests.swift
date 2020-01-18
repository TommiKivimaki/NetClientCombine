import XCTest
import Combine
@testable import NetClientCombine

final class NetClientCombineTests: XCTestCase {
  
  var client: NetClientCombine!
  var clientLowData: NetClientCombine!
  
  // Store references to request so they stay alive until they complete
  private var disposables = Set<AnyCancellable>()
  
  override func setUp() {
    client = NetClientCombine()
    let lowDataConfiguration = URLSessionConfiguration.default
    lowDataConfiguration.allowsConstrainedNetworkAccess = true
    lowDataConfiguration.allowsExpensiveNetworkAccess = false
    lowDataConfiguration.allowsCellularAccess = false
    let testSession = URLSession(configuration: lowDataConfiguration)
    clientLowData = NetClientCombine(testSession)
  }
  
  override func tearDown() {
    client = nil
    clientLowData = nil
  }
  
  //TODO: Low data config is not tested yet (clientLowData)

  func testAdaptiveSendGetRequest() {
    let expectation = XCTestExpectation(description: "Response received")
    
    let url = URL(string: "https://tommikivimaki.com")!
    
    client.adaptiveSend(regularURL: url, lowDataURL: url)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] value in
        guard let self = self else { return }
        switch value {
        case .failure:
          print("FAILED")
        case .finished:
          break
        }
        }, receiveValue: { [weak self] data in
          guard let self = self else { return }
          expectation.fulfill()
      })
      .store(in: &disposables)

    wait(for: [expectation], timeout: 10)
  }
  
  
  func testSendGetRequestWithoutBody() {
    let expectation = XCTestExpectation(description: "Response received")
    let url = URL(string: "https://campingfinland.net")!
    
//    client.send(.get, to: url, headers: HTTPHeaders.defaults())
    client.get(url)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] completion in
        guard let self = self else { return }
        switch completion {
        case .failure(let error):
          print(error)
          XCTFail()
        case .finished:
          break
        }
        },
            receiveValue: { [weak self] data in
              guard let self = self else { return }
              let string = String(data: data, encoding: .utf8)
              print(string!)
              expectation.fulfill()
      })
      .store(in: &disposables)
    
    wait(for: [expectation], timeout: 10)
  }
  
  
  func testGetRequestAndDecodeResponse() {
    let expectation = XCTestExpectation(description: "Response received")
    
    struct People: Decodable {
      var name: String
    }
    
    let url = URL(string: "https://swapi.co/api/people/1/")!
    
      // TODO: Use the get method when you get the Clienting helpers in place
//    client.get(url, response: People.self)
    client.send(to: url, response: People.self)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] completion in
        guard let self = self else { return }
        switch completion {
        case .finished:
          break
        case .failure(let error):
          print(error)
          XCTFail()
        }
        }, receiveValue: { [weak self] people in
        guard let self = self else { return }
        print(people)
        expectation.fulfill()
      })
      .store(in: &disposables)
      
    
    wait(for: [expectation], timeout: 10)
  }
  
  
  func testSendRequestWithBodyAndDecodeResponse() {
    let expectation = XCTestExpectation(description: "Response received")
    
    let url = URL(string: "https://httpbin.org/anything")!
    let headers: [String: String] = [
      "Content-Type": "application/json",
      "Accept": "application/json",
    ]
    
    struct RequestBody: Codable, Equatable {
      let firstname: String
      let lastname: String
    }
    
    struct ResponseBody: Decodable {
      let json: RequestBody
      let method: String
      let origin: String
      let url: String
    }
    
    let reqBody = RequestBody(firstname: "James", lastname: "Bond")
    
    /// TODO: Use the convenience method when available
    client.post(url, headers: headers, requestBody: reqBody, response: ResponseBody.self)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] completion in
        guard let self = self else { return }
        switch completion {
        case .finished:
          break
        case .failure(let error):
          print(error)
          XCTFail()
        }
      }, receiveValue: { [weak self] value in
        guard let self = self else { return }
        print(value)
        XCTAssertEqual(value.json, reqBody)
        expectation.fulfill()
      })
      .store(in: &disposables)
    
    wait(for: [expectation], timeout: 10)
  }
  
  
  func testDefaultHeaders() {
    let expectation = XCTestExpectation(description: "Response received")
    
    let url = URL(string: "https://httpbin.org/headers")!
    
    struct HeaderDictionary: Decodable, Equatable {
      let accept: String
      let contentType: String
      let userAgent: String // Decoding also User-Agent to see the response. It's not part of the HTTPHeaders.defaults()
      
      enum CodingKeys: String, CodingKey {
        case accept = "Accept"
        case contentType = "Content-Type"
        case userAgent = "User-Agent"
      }
    }
    
    struct ResponseBody: Decodable {
      let headers: HeaderDictionary
    }
    
    client.get(url, headers: HTTPHeaders.defaults(), response: ResponseBody.self)
      .receive(on: RunLoop.main)
      .sink(receiveCompletion: { [weak self] completion in
        guard let self = self else { return }
        switch completion {
        case .finished:
          break
        case .failure(let error):
          print(error)
          XCTFail()
        }
      }, receiveValue: { [weak self] value in
        guard let self = self else { return }
        print(value)
        XCTAssertEqual(value.headers.accept, "application/json")
        XCTAssertEqual(value.headers.contentType, "application/json")
        expectation.fulfill()
      })
      .store(in: &disposables)
    
    wait(for: [expectation], timeout: 10)
  }

  
  static var allTests = [
    ("testAdaptiveSendGetRequest", testAdaptiveSendGetRequest),
    ("testSendGetRequestWithoutBody", testGetRequestAndDecodeResponse),
    ("testGetRequestAndDecodeResponse", testGetRequestAndDecodeResponse),
    ("testSendRequestWithBodyAndDecodeResponse", testSendRequestWithBodyAndDecodeResponse),
    ("testDefaultHeaders", testDefaultHeaders)
  ]
}
