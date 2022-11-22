//
//  RBTFQuestionsRandomURLTest.swift
//  OFFRobotoffAPIsTests
//
//  Created by Arnaud Leene on 21/11/2022.
//

import XCTest
@testable import OFFRobotoffAPIs

final class RBTFQuestionsRandomURLTest: XCTestCase {

    func testQuestionsRandom() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/questions/random"
        let url = HTTPRequest(api: .random).url!
        XCTAssertEqual(url.description, result)
    }

}
