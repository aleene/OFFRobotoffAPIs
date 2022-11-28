//
//  RBTFQuestionsProductURL.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 21/11/2022.
//

import XCTest
@testable import OFFRobotoffAPIs

class RBTFQuestionsURLTests: XCTestCase {

    var barcode = OFFBarcode.init(barcode: "1234")
    // Auth URL test
    
    func testQuestionsProduct() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/questions/1234"
        let url = HTTPRequest(api: .questions, barcode: barcode).url!
        XCTAssertEqual(url.description, result)
    }
    
    func testQuestionsRandom() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/questions/random"
        let url = HTTPRequest(api: .questionsRandom).url!
        XCTAssertEqual(url.description, result)
    }

    func testQuestionsPopular() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/questions/popular"
        let url = HTTPRequest(api: .questionsPopular).url!
        XCTAssertEqual(url.description, result)
    }

    func testUnansweredQuestionsCountURL() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/questions/unanswered"
        let url = HTTPRequest(api: .questionsUnanswered).url!
        XCTAssertEqual(url.description, result)
    }

}
