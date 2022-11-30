//
//  RBTFQuestionsRandomURLTest.swift
//  OFFRobotoffAPIsTests
//
//  Created by Arnaud Leene on 21/11/2022.
//

import XCTest
@testable import OFFRobotoffAPIs

final class RBTFInsightsURLTest: XCTestCase {

    func testQuestionsRandom() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/insights/random"
        let url = HTTPRequest(api: .insightsRandom).url!
        XCTAssertEqual(url.description, result)
    }

    func testQuestionsBarcode() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/insights/1234"
        let offBarcode = OFFBarcode(barcode: "1234")
        let url = HTTPRequest(api: .insightsBarcode, barcode: offBarcode).url!
        XCTAssertEqual(url.description, result)
    }

}
