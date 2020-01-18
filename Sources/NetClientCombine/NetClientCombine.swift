// Copyright © 18.1.2020 Tommi Kivimäki.

import Combine
import Foundation

public final class NetClientCombine: Clienting {
  
  /// URLSession powering the requests
  private let urlSession: URLSession
  
  init(_ urlSession: URLSession? = nil) {
    let defaultConfiguration = URLSessionConfiguration.default
    defaultConfiguration.allowsCellularAccess = true
    defaultConfiguration.allowsConstrainedNetworkAccess = true
    defaultConfiguration.allowsExpensiveNetworkAccess = true
    if #available(OSX 10.13, *) {
      defaultConfiguration.waitsForConnectivity = true
    }
    self.urlSession = urlSession ?? URLSession(configuration: defaultConfiguration)
  }
  
  
  
  
  public func send(_ request: URLRequest) -> AnyPublisher<Data, Error> {
    return urlSession.dataTaskPublisher(for: request)
      .tryMap { data, response -> Data in
        guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
            throw NetClientError.invalidServerResponse
        }
        return data
    }
    .eraseToAnyPublisher()
  }
  
  
  public func adaptiveSend(regularURL: URL, lowDataURL: URL) -> AnyPublisher<Data, Error> {
    // Let's try regular access first
    var request = URLRequest(url: regularURL)
    request.allowsConstrainedNetworkAccess = false
    
    return urlSession.dataTaskPublisher(for: request)
      .tryCatch { error -> URLSession.DataTaskPublisher in
        guard error.networkUnavailableReason == .constrained else {
          throw NetClientError.invalidServerResponse
        }
        return self.urlSession.dataTaskPublisher(for: lowDataURL)
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
  public func send(_ method: HTTPMethod = .get,
                   to url: URL,
                   headers: HTTPHeaders = [:]) -> AnyPublisher<Data, Error> {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.allHTTPHeaderFields = headers

    return urlSession.dataTaskPublisher(for: request)
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
   public func send<Response>(_ method: HTTPMethod = .get,
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
       return self.urlSession.dataTaskPublisher(for: request)
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
   public func send<RequestBody, Response>(_ method: HTTPMethod = .post,
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
       return self.urlSession.dataTaskPublisher(for: request)
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
