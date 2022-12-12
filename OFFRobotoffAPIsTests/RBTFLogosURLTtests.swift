//
//  RBTFLogosURLTtests.swift
//  OFFRobotoffAPIsTests
//
//  Created by Arnaud Leene on 09/12/2022.
//

import XCTest
@testable import OFFRobotoffAPIs

final class RBTFLogosURLTtests: XCTestCase {

    func testURLLogos() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/images/logos"
        let url = HTTPRequest(count: nil, type: nil, barcode: nil, value: nil, taxonomy_value: nil, min_confidence: nil, random: nil, annotated: nil).url!
        XCTAssertEqual(url.description, result)
    }

    func testURLLogosFetch() throws {
        let value = "122299"
        let name = "logo_ids"
        let request = HTTPRequest(logoIds: value)
        let queries = request.queryItems
        if !queries.isEmpty {
            if let query = queries.first {
                XCTAssertEqual(query.name, name)
                XCTAssertEqual(query.value, value)
            } else {
                XCTFail("testURLLogosFetch:no first item")
            }
        } else {
            XCTFail("testURLLogosFetch:no query items")
        }
    }

}
