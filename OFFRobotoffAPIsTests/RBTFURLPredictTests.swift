//
//  RBTFURLPredictTests.swift
//  OFFRobotoffAPIsTests
//
//  Created by Arnaud Leene on 15/12/2022.
//

import XCTest
@testable import OFFRobotoffAPIs

final class RBTFURLPredictTests: XCTestCase {

    var expectation: XCTestExpectation!

    override func setUpWithError() throws {
        expectation = expectation(description: "Expectation")
    }
    
    func testURLPredict() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/predict/category"
        let url = RBTFRequest(api: .predict).url!
        if url.description == result {
            self.expectation?.fulfill()
        } else {
            XCTFail("testURLPredict: urls's unequal")
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // Check the body
    func testURLPredictBody() throws {
        let barcode = OFFBarcode(barcode: "abarcode")
        let deepestOnly = false
        let threshold = 0.5
        let predictors: [RBTF.Predictors] = [.matcher]
        
        let request = RBTFPredictRequest(barcode: barcode.barcode,
                                         deepestOnly: deepestOnly,
                                         threshold: threshold,
                                         predictors: predictors.map({ $0.rawValue }))
        do {
            let data = try JSONDecoder().decode(RBTF.PredictRequestBody.self, from: request.body.encode())
            if data.barcode == barcode.barcode &&
                data.deepest_only == deepestOnly &&
                data.threshold == threshold {
                if !data.predictors.isEmpty {
                    for element in data.predictors {
                        if predictors.first?.rawValue == element {
                            self.expectation?.fulfill()
                        } else {
                            XCTFail("testURLPredict: wrong predictors")
                        }
                    }
                } else {
                    XCTFail("testURLPredict: no predictors")
                }

            } else {
                XCTFail("testURLPredict: no values")
            }
        } catch {
            XCTFail("testURLPredict: no data")
        }
        
        wait(for: [expectation], timeout: 1.0)
    }

}
