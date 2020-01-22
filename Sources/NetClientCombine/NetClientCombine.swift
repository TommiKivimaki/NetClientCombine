// Copyright © 18.1.2020 Tommi Kivimäki.

import Combine
import Foundation




struct NetClientCombine: Clienting {

  static var publisher: ClientPublishable = ClientPublisher()
  
  
  
  /// publisher powering the requests
//  var publisher = ClientPublisher()
  
  static func send(_ request: URLRequest) -> AnyPublisher<Data, Error> {
    return publisher.dataTaskPublisher(for: request)
      .tryMap { data, response -> Data in
        guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
            throw NetClientError.invalidServerResponse
        }
        return data
    }
    .eraseToAnyPublisher()
  }
  
  
  static func adaptiveSend(regularURL: URL, lowDataURL: URL) -> AnyPublisher<Data, Error> {
    // Let's try regular access first
    var request = URLRequest(url: regularURL)
    request.allowsConstrainedNetworkAccess = false
    
    return publisher.dataTaskPublisher(for: request)
      .tryCatch { error -> URLSession.DataTaskPublisher in
        guard error.networkUnavailableReason == .constrained else {
          throw NetClientError.invalidServerResponse
        }
        // No network for regular access. Let's try low data request
        let lowRequest = URLRequest(url: lowDataURL)
        return publisher.dataTaskPublisher(for: lowRequest)
    }
    .tryMap { data, response -> Data in
      guard let httpResponse = response as? HTTPURLResponse,
        httpResponse.statusCode == 200 else {
          throw NetClientError.invalidServerResponse
      }
      return data
    }
    .eraseToAnyPublisher()
  }
  
  

  /// Send without body data
  /// - Parameter method: HTTP method
  /// - Parameter url: Endpoint
  /// - Parameter headers: HTTP headers
  /// - Returns: Raw response data
  static func send(_ method: HTTPMethod = .get,
                   to url: URL,
                   headers: HTTPHeaders = [:]) -> AnyPublisher<Data, Error> {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.allHTTPHeaderFields = headers
  
    return publisher.dataTaskPublisher(for: request)
      .tryMap { data, response -> Data in
        guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
            throw NetClientError.invalidServerResponse
        }
        return data
    }
    .eraseToAnyPublisher()
  }
  
  
  /// Send without body data and decode the response
   /// - Parameter method: HTTP method
   /// - Parameter url: Endpoint
   /// - Parameter headers: HTTP headers
   /// - Parameter decodeTo: Response will be decoded to this Model type
   /// - Returns: Decoded response
   static func send<Response>(_ method: HTTPMethod = .get,
                              to url: URL,
                              headers: HTTPHeaders = [:],
                              response decodeTo: Response.Type) -> AnyPublisher<Response, Error> where Response: Decodable {
     
     return Future<URLRequest, Error> { promise in
       var request = URLRequest(url: url)
       request.httpMethod = method.rawValue
       request.allHTTPHeaderFields = headers
       return promise(.success(request))
     }
     .flatMap { request in
      return self.publisher.dataTaskPublisher(for: request)
         .tryMap { data, response -> Data in
           guard let httpResponse = response as? HTTPURLResponse,
             httpResponse.statusCode == 200 else {
               throw NetClientError.invalidServerResponse
           }
           
           return data
       }
     }
     .decode(type: Response.self, decoder: JSONDecoder())
     .mapError { error -> NetClientError in
       if error is NetClientError {
         return .failedToDecodeResponse
       } else {
         return .unknown
       }
     }
     .eraseToAnyPublisher()
   }
  
  
  
  /// Send with body data and decode response
   /// - Parameter method: HTTP method
   /// - Parameter url: Endpoint
   /// - Parameter headers: HTTP headers
   /// - Parameter requestBody: HTTP request body
   /// - Parameter decodeTo: Response will be decoded to this Model type
   static func send<RequestBody, Response>(_ method: HTTPMethod = .post,
                          to url: URL, headers: HTTPHeaders = [:],
                          requestBody: RequestBody,
                          response decodeTo: Response.Type) -> AnyPublisher<Response, Error> where RequestBody: Encodable, Response: Decodable {
     return Just(requestBody)
       .encode(encoder: JSONEncoder())
       .mapError { error -> NetClientError in
         if error is NetClientError {
           return .failedToEncodeBody
         } else {
           return .unknown
         }
     }
     .map { data -> URLRequest in
       var request = URLRequest(url: url)
       request.httpMethod = method.rawValue
       request.allHTTPHeaderFields = headers
       request.httpBody = data
       return request
     }
     .flatMap { request -> Publishers.TryMap<URLSession.DataTaskPublisher, Data> in
      return self.publisher.dataTaskPublisher(for: request)
         .tryMap { data, response -> Data in
           guard let httpResponse = response as? HTTPURLResponse,
             httpResponse.statusCode == 200 else {
               throw NetClientError.invalidServerResponse
           }
           
           return data
       }
     }
     .decode(type: Response.self, decoder: JSONDecoder())
     .mapError { error -> NetClientError in
       if error is NetClientError {
         return .failedToDecodeResponse
       } else {
         return .unknown
       }
     }
     .eraseToAnyPublisher()
   }
  
}
