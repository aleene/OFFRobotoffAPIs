//
//  RBTFQuestionsProductURL.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 21/11/2022.
//

import XCTest
@testable import OFFRobotoffAPIs

class RBTFQuestionsURLTests: XCTestCase {

    var expectation: XCTestExpectation!

    override func setUpWithError() throws {
        expectation = expectation(description: "Expectation")
    }

    var barcode = OFFBarcode.init(barcode: "1234")
    // Auth URL test
    
    func testQuestionsProduct() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/questions/1234"
        let url = RBTFRequest(api: .questions, barcode: barcode).url!
        if url.description == result {
            self.expectation?.fulfill()
        } else {
            XCTFail("testQuestionsProduct: urls's unequal")
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testQuestionsRandom() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/questions/random"
        let url = RBTFRequest(api: .questionsRandom).url!
        if url.description == result {
            self.expectation?.fulfill()
        } else {
            XCTFail("testQuestionsRandom: urls's unequal")
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testQuestionsPopular() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/questions/popular"
        let url = RBTFRequest(api: .questionsPopular).url!
        if url.description == result {
            self.expectation?.fulfill()
        } else {
            XCTFail("testQuestionsPopular: urls's unequal")
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testUnansweredQuestionsCountURL() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/questions/unanswered"
        let url = RBTFRequest(api: .questionsUnanswered).url!
        if url.description == result {
            self.expectation?.fulfill()
        } else {
            XCTFail("testUnansweredQuestionsCountURL: urls's unequal")
        }
        wait(for: [expectation], timeout: 1.0)
    }

}
