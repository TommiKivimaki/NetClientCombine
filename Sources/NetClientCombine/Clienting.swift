// Copyright © 18.1.2020 Tommi Kivimäki.

import Combine
import Foundation


protocol Clienting {
  func send(_ method: HTTPMethod,
            to url: URL,
            headers: HTTPHeaders) -> AnyPublisher<Data, Error>
  
  func send<Response>(_ method: HTTPMethod,
                      to url: URL,
                      headers: HTTPHeaders,
                      response decodeTo: Response.Type) -> AnyPublisher<Response, Error> where Response: Decodable
  
  func send<RequestBody, Response>(_ method: HTTPMethod,
                         to url: URL, headers: HTTPHeaders,
                         requestBody: RequestBody,
                         response decodeTo: Response.Type) -> AnyPublisher<Response, Error> where RequestBody: Encodable, Response: Decodable
}


// Convenience methods
extension Clienting {
  public func get(_ url: URL, headers: HTTPHeaders = [:]) -> AnyPublisher<Data, Error> {
    return self.send(.get, to: url, headers: headers)
  }
  
  public func get<Response>(_ url: URL, headers: HTTPHeaders = [:], response: Response.Type) -> AnyPublisher<Response, Error> where Response: Decodable {
    return self.send(.get, to: url, headers: headers, response: response)
  }
  
  public func post<RequestBody, Response>(_ url: URL, headers: HTTPHeaders = [:], requestBody: RequestBody, response: Response.Type) -> AnyPublisher<Response, Error> where RequestBody: Encodable, Response: Decodable {
    return self.send(.post, to: url, headers: headers, requestBody: requestBody, response: response)
  }
  
}
