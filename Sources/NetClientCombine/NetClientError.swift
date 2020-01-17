//
//  NetClientError.swift
//  
//
//  Created by Tommi Kivimäki on 22.10.2019.
//

enum NetClientError: Error {
  case invalidServerResponse
  case failedToEncodeBody
  case failedToDecodeResponse
  case unknown
}
