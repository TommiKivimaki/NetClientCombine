// Copyright © 22.1.2020 Tommi Kivimäki.

import Foundation

@available(OSX 10.15, iOS 13.0, *)
class ClientPublisher: ClientPublishable {
  
    var session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
  
  func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher {
      return session.dataTaskPublisher(for: request)
  }
}
