//
//  RBTFQuestionsRandomURLTest.swift
//  OFFRobotoffAPIsTests
//
//  Created by Arnaud Leene on 21/11/2022.
//

import XCTest
@testable import OFFRobotoffAPIs

final class RBTFInsightsURLTest: XCTestCase {

    var expectation: XCTestExpectation!

    override func setUpWithError() throws {
        expectation = expectation(description: "Expectation")
    }

    func testInsightsRandom() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/insights/random"
        let url = RBTFRequest(api: .insightsRandom).url!
        if url.description == result {
            self.expectation?.fulfill()
        } else {
            XCTFail("testInsightsRandom: url's not the same")
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testInsightsBarcode() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/insights/1234"
        let offBarcode = OFFBarcode(barcode: "1234")
        let url = RBTFRequest(api: .insightsBarcode, barcode: offBarcode).url!
        if url.description == result {
            self.expectation?.fulfill()
        } else {
            XCTFail("testInsightsBarcode: url's not the same")
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testInsightsDetail() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/insights/detail/an_insight_string"
        let url = RBTFInsightsRequest(insightId: "an_insight_string").url!
        if url.description == result {
            self.expectation?.fulfill()
        } else {
            XCTFail("testInsightsDetail: url's not the same")
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // Check the query parts of this call
    func testURLInsightsRandom() throws {
        let barcode = OFFBarcode(barcode: "abarcode")
        let insightType = RBTF.InsightType.brand
        let country = "acountry"
        let valueTag = "aValueTag"
        let count: UInt = 5
        let request = RBTFInsightsRequest(barcode: barcode, insightType: insightType, country: country, valueTag: valueTag, count: count)
        let queries = request.queryItems
        if !queries.isEmpty {
            for query in queries {
                if query.name == "count",
                   query.value == "\(count)" {
                    continue
                } else if query.name == "country",
                          query.value == country {
                    continue
                } else if query.name == "barcode",
                          query.value == barcode.barcode {
                    continue
                } else if query.name == "valueTag",
                          query.value == valueTag {
                    continue
                } else if query.name == "insight_type",
                          query.value == insightType.rawValue {
                    continue
                } else {
                    XCTFail("testURLInsightsRandom: query item missing")
                }
            }
            self.expectation?.fulfill()
        } else {
            XCTFail("testURLInsightsRandom :no query items")
        }
        wait(for: [expectation], timeout: 1.0)
    }

}
