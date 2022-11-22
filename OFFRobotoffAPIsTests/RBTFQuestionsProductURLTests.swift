//
//  RBTFQuestionsProductURL.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 21/11/2022.
//

import XCTest
@testable import OFFRobotoffAPIs

class RBTFQuestionsProductURLTests: XCTestCase {

    var barcode = OFFBarcode.init(barcode: "1234")
    // Auth URL test
    
    func testQuestionsProduct() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/questions/1234"
        let url = HTTPRequest(api: .questions, barcode: barcode).url!
        XCTAssertEqual(url.description, result)
    }

}
