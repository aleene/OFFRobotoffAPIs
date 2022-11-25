//
//  RBTFQuestionsPopularURLTests.swift
//  OFFRobotoffAPIsTests
//
//  Created by Arnaud Leene on 25/11/2022.
//

import XCTest
@testable import OFFRobotoffAPIs

final class RBTFQuestionsPopularURLTest: XCTestCase {

    func testQuestionsPopular() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/questions/popular"
        let url = HTTPRequest(api: .popular).url!
        XCTAssertEqual(url.description, result)
    }

}
