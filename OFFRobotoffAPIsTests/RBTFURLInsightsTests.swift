//
//  RBTFURLInsightsTests.swift
//  OFFRobotoffAPIsTests
//
//  Created by Arnaud Leene on 21/11/2022.
//

import XCTest
@testable import OFFRobotoffAPIs

final class RBTFURLInsightsTests: XCTestCase {

    var expectation: XCTestExpectation!

    override func setUpWithError() throws {
        expectation = expectation(description: "Expectation")
    }

    // test the insights url fro a list of random insights
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

    // test the insights url for the annotate endpoint
    func testInsightsAnnotate() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/insights/annotate"
        let url = RBTFRequest(api: .insightsAnnotate).url!
        if url.description == result {
            self.expectation?.fulfill()
        } else {
            XCTFail("testInsightsAnnotate: url's not the same")
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // test the insights for a specific barcode url
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

    // test the detail insights url
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
    
    // Check the query URL parts of filtered insights for a specific barcode
    func testURLInsightsBarcodeFiltered() throws {
        let barcode = OFFBarcode(barcode: "abarcode")
        let insightType = RBTF.InsightType.brand
        let country = "acountry"
        let valueTag = "aValueTag"
        let count: UInt = 5
        let request = RBTFInsightsRequest(barcode: barcode,
                                          insightType: insightType,
                                          country: country,
                                          valueTag: valueTag,
                                          count: count)
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
                } else if query.name == "value_tag",
                          query.value == valueTag {
                    continue
                } else if query.name == "type",
                          query.value == insightType.rawValue {
                    continue
                } else {
                    XCTFail("testURLInsightsBarcodeFiltered: query item missing")
                }
            }
            self.expectation?.fulfill()
        } else {
            XCTFail("testURLInsightsBarcodeFiltered :no query items")
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // Check the query parts of this call
    func testURLInsightsRandomFiltered() throws {
        let insightType = RBTF.InsightType.brand
        let country = "acountry"
        let valueTag = "aValueTag"
        let count: UInt = 5
        let request = RBTFInsightsRequest(insightType: insightType, country: country, valueTag: valueTag, count: count)
        let queries = request.queryItems
        if !queries.isEmpty {
            for query in queries {
                if query.name == "count",
                   query.value == "\(count)" {
                    continue
                } else if query.name == "country",
                          query.value == country {
                    continue
                } else if query.name == "value_tag",
                          query.value == valueTag {
                    continue
                } else if query.name == "type",
                          query.value == insightType.rawValue {
                    continue
                } else {
                    XCTFail("testURLInsightsRandomFiltered: query item missing")
                }
            }
            self.expectation?.fulfill()
        } else {
            XCTFail("testURLInsightsRandomFiltered :no query items")
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // Check the body
    func testURLAnnotateBody() throws {
        let insightID = "98127398"
        let annotation: RBTF.Annotation = .refuse
        let update = 1
        let request = RBTFInsightsRequest(insightID: insightID,
                                          annotation: annotation,
                                          username: nil,
                                          password: nil)
        do {
            let data = try JSONDecoder().decode(RBTF.InsightAnnotateBody.self, from: request.body.encode())
            if data.insight_id == insightID &&
                data.update == update &&
                data.annotation == "\(annotation.rawValue)" {
                self.expectation?.fulfill()
            } else {
                XCTFail("testURLAnnotateBody: no values")
            }
        } catch {
            XCTFail("testURLAnnotateBody: no data")
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

}
