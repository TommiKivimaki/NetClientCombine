// Copyright © 18.1.2020 Tommi Kivimäki.

import Foundation

public typealias HTTPHeaders = [String: String]

extension HTTPHeaders {
  public static func defaults() -> [String: String] {
    return [
      "Accept": "application/json",
      "Content-Type": "application/json"
    ]
  }
}
