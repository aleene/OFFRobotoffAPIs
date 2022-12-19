//
//  RBTFURLLogosTests.swift
//  OFFRobotoffAPIsTests
//
//  Created by Arnaud Leene on 09/12/2022.
//

import XCTest
@testable import OFFRobotoffAPIs

final class RBTFURLLogosTests: XCTestCase {

    var expectation: XCTestExpectation!

    override func setUpWithError() throws {
        expectation = expectation(description: "Expectation")
    }

    func testURLLogos() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/images/logos"
        let url = RBTFLogosRequest(count: nil, type: nil, barcode: nil, value: nil, taxonomy_value: nil, min_confidence: nil, random: nil, annotated: nil).url!
        if url.description == result {
            self.expectation?.fulfill()
        } else {
            XCTFail("testURLLogos: url's not the same")
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testURLLogosFetch() throws {
        let value = "122299"
        let name = "logo_ids"
        let request = RBTFLogosRequest(logoIds: value)
        let queries = request.queryItems
        if !queries.isEmpty {
            if let query = queries.first {
                if query.name == name,
                   query.value == value {
                    self.expectation?.fulfill()
                } else {
                    XCTFail("testURLLogosFetch:unexpected name or value")
                }
            } else {
                XCTFail("testURLLogosFetch:no first item")
            }
        } else {
            XCTFail("testURLLogosFetch:no query items")
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // Check the query parts of this call
    func testURLLogosSearch() throws {
        let count: UInt = 5
        let type = "atype"
        let barcode = OFFBarcode(barcode: "abarcode")
        let value = "122299"
        let taxonomy_value = "avalue"
        let min_confidence = 6
        let random = true
        let annotated = false
        let request = RBTFLogosRequest(count: count, type: type, barcode: barcode, value: value, taxonomy_value: taxonomy_value, min_confidence: min_confidence, random: random, annotated: annotated)
        let queries = request.queryItems
        if !queries.isEmpty {
            for query in queries {
                if query.name == "count",
                   query.value == "\(count)" {
                    continue
                } else if query.name == "type",
                          query.value == type {
                    continue
                } else if query.name == "barcode",
                          query.value == barcode.barcode {
                    continue
                } else if query.name == "value",
                          query.value == value {
                    continue
                } else if query.name == "taxonomy_value",
                          query.value == taxonomy_value {
                    continue
                } else if query.name == "min_confidence",
                          query.value == "\(min_confidence)" {
                    continue
                } else if query.name == "random",
                          query.value == random.description {
                    continue
                } else if query.name == "annotated",
                          query.value == annotated.description {
                    continue
                } else {
                    XCTFail("testURLLogosFetch: query item missing")
                }
            }
            self.expectation?.fulfill()
        } else {
            XCTFail("testURLLogosFetch:no query items")
        }
        wait(for: [expectation], timeout: 1.0)
    }

}
