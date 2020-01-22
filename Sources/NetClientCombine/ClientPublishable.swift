// Copyright © 22.1.2020 Tommi Kivimäki.

import Foundation

@available(OSX 10.15, iOS 13.0, *)
protocol ClientPublishable {
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
}
