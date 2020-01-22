// Copyright © 22.1.2020 Tommi Kivimäki.

import Foundation
import Combine
import XCTest

func validateResponse<T:Publisher>(publisher: T?) -> (expectations:[XCTestExpectation], cancellable: AnyCancellable?) {
  XCTAssertNotNil(publisher)

  let expectationFinished = XCTestExpectation(description: "finished")
  let expectationReceived = XCTestExpectation(description: "receiveValue")
  let expectationFailure = XCTestExpectation(description: "failure")
  // Failure is not expected to happen
  expectationFailure.isInverted = true

  let cancellable = publisher?.sink (receiveCompletion: { (completion) in
    switch completion {
    case .failure(let error):
      print("--ERROR IN TEST--")
      print(error.localizedDescription)
      print("------")
      expectationFailure.fulfill()
    case .finished:
      expectationFinished.fulfill()
    }
  }, receiveValue: { value in
    XCTAssertNotNil(value)
    print(value)
    expectationReceived.fulfill()
  })
  return (expectations: [expectationFinished, expectationReceived, expectationFailure],
          cancellable: cancellable)
}


func validateResponse<T:Publisher, E:Equatable>(publisher: T?, expectedResponse: E) -> (expectations:[XCTestExpectation], cancellable: AnyCancellable?) {
  XCTAssertNotNil(publisher)
  
  let expectationFinished = XCTestExpectation(description: "finished")
  let expectationReceived = XCTestExpectation(description: "receiveValue")
  let expectationFailure = XCTestExpectation(description: "failure")
  // Failure is not expected to happen
  expectationFailure.isInverted = true
  
  let cancellable = publisher?.sink (receiveCompletion: { (completion) in
    switch completion {
    case .failure(let error):
      print("--ERROR IN TEST--")
      print(error.localizedDescription)
      print("------")
      expectationFailure.fulfill()
    case .finished:
      expectationFinished.fulfill()
    }
  }, receiveValue: { value in
    XCTAssertEqual(value as! E, expectedResponse, "Response did not match the expected")
    print(value)
    expectationReceived.fulfill()
  })
  return (expectations: [expectationFinished, expectationReceived, expectationFailure],
          cancellable: cancellable)
}

//
//  func evalInvalidResponseTest<T:Publisher>(publisher: T?) -> (expectations:[XCTestExpectation], cancellable: AnyCancellable?) {
//         XCTAssertNotNil(publisher)
//         
//         let expectationFinished = expectation(description: "Invalid.finished")
//         expectationFinished.isInverted = true
//         let expectationReceive = expectation(description: "Invalid.receiveValue")
//         expectationReceive.isInverted = true
//         let expectationFailure = expectation(description: "Invalid.failure")
//         
//         let cancellable = publisher?.sink (receiveCompletion: { (completion) in
//             switch completion {
//             case .failure(let error):
//                 print("--TEST FULFILLED--")
//                 print(error.localizedDescription)
//                 print("------")
//                 expectationFailure.fulfill()
//             case .finished:
//                 expectationFinished.fulfill()
//             }
//         }, receiveValue: { response in
//             XCTAssertNotNil(response)
//             print(response)
//             expectationReceive.fulfill()
//         })
//          return (expectations: [expectationFinished, expectationReceive, expectationFailure],
//                        cancellable: cancellable)
//     }

