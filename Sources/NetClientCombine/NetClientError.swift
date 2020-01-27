// Copyright © 18.1.2020 Tommi Kivimäki.

enum NetClientError: Error {
  case invalidServerResponse
  case failedToEncodeBody
  case failedToDecodeResponse
  case networkUnavailableReasonIsConstrained
  case unknown
}
