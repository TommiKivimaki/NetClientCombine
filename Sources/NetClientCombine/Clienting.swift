// Copyright © 18.1.2020 Tommi Kivimäki.

import Combine
import Foundation


protocol Clienting {
  static func send(_ method: HTTPMethod,
            to url: URL,
            headers: HTTPHeaders) -> AnyPublisher<Data, Error>
  
  static func send<Response>(_ method: HTTPMethod,
                      to url: URL,
                      headers: HTTPHeaders,
                      response decodeTo: Response.Type) -> AnyPublisher<Response, Error> where Response: Decodable
  
  static func send<RequestBody, Response>(_ method: HTTPMethod,
                         to url: URL, headers: HTTPHeaders,
                         requestBody: RequestBody,
                         response decodeTo: Response.Type) -> AnyPublisher<Response, Error> where RequestBody: Encodable, Response: Decodable
}


// Convenience methods
extension Clienting {
  static public func get(_ url: URL, headers: HTTPHeaders = [:]) -> AnyPublisher<Data, Error> {
    return Self.send(.get, to: url, headers: headers)
  }
  
  static public func get<Response>(_ url: URL, headers: HTTPHeaders = [:], response: Response.Type) -> AnyPublisher<Response, Error> where Response: Decodable {
    return Self.send(.get, to: url, headers: headers, response: response)
  }
  
  static public func post<RequestBody, Response>(_ url: URL, headers: HTTPHeaders = [:], requestBody: RequestBody, response: Response.Type) -> AnyPublisher<Response, Error> where RequestBody: Encodable, Response: Decodable {
    return Self.send(.post, to: url, headers: headers, requestBody: requestBody, response: response)
  }
  
  static public func delete(_ url: URL, headers: HTTPHeaders = [:]) -> AnyPublisher<Data, Error> {
    return Self.send(.delete, to: url, headers: headers)
  }
}
