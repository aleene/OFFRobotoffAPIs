//
//  RBTFQuestionsProductURL.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 21/11/2022.
//

import XCTest
@testable import OFFRobotoffAPIs

class RBTFQuestionsURLTests: XCTestCase {

    var expectation: XCTestExpectation!

    override func setUpWithError() throws {
        expectation = expectation(description: "Expectation")
    }

    var barcode = OFFBarcode.init(barcode: "1234")
    // Auth URL test
    
    func testQuestionsProduct() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/questions/1234"
        let url = RBTFRequest(api: .questions, barcode: barcode).url!
        if url.description == result {
            self.expectation?.fulfill()
        } else {
            XCTFail("testQuestionsProduct: urls's unequal")
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testQuestionsRandom() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/questions/random"
        let url = RBTFRequest(api: .questionsRandom).url!
        if url.description == result {
            self.expectation?.fulfill()
        } else {
            XCTFail("testQuestionsRandom: urls's unequal")
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testQuestionsPopular() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/questions/popular"
        let url = RBTFRequest(api: .questionsPopular).url!
        if url.description == result {
            self.expectation?.fulfill()
        } else {
            XCTFail("testQuestionsPopular: urls's unequal")
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testUnansweredQuestionsCountURL() throws {
        let result = "https://robotoff.openfoodfacts.org/api/v1/questions/unanswered"
        let url = RBTFRequest(api: .questionsUnanswered).url!
        if url.description == result {
            self.expectation?.fulfill()
        } else {
            XCTFail("testUnansweredQuestionsCountURL: urls's unequal")
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // Check the query parts of questions for a given product
    func testQuestionsProductQueryURL() throws {
        let count: UInt = 5
        let barcode = OFFBarcode(barcode: "abarcode")
        let lang = "avalue"
        let request = RBTFQuestionsRequest(barcode: barcode, count: count, lang: lang)
        let queries = request.queryItems
        if !queries.isEmpty {
            for query in queries {
                if query.name == "count",
                   query.value == "\(count)" {
                    continue
                } else if query.name == "lang",
                          query.value == lang {
                    continue
                } else {
                    XCTFail("testQuestionsProductQueryURL: query item missing")
                }
            }
            self.expectation?.fulfill()
        } else {
            XCTFail("testQuestionsProductQueryURL:no query items")
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // Check the query parts of questions
    func testQuestionsRandomQueryURL() throws {
        let lang = "avalue"
        let count: UInt = 5
        let insightTypes: [RBTF.InsightType] = [.brand]
        let country = "en:france"
        let brands = ["lidl"]
        let valueTag = "en:organic"
        let page: UInt = 5
        let request = RBTFQuestionsRequest(api: .questionsRandom,
                                           languageCode: lang,
                                           count: count,
                                           insightTypes: insightTypes,
                                           country: country,
                                           brands: brands,
                                           valueTag: valueTag,
                                           page: page)
        let queries = request.queryItems
        if !queries.isEmpty {
            for query in queries {
                if query.name == "count",
                   query.value == "\(count)" {
                    continue
                } else if query.name == "lang",
                          query.value == lang {
                    continue
                } else if query.name == "insight_types",
                          let queryInsigntTypes = query.value?.components(separatedBy: ","),
                          !queryInsigntTypes.isEmpty,
                          let first = queryInsigntTypes.first,
                          let firstType = insightTypes.first?.rawValue,
                          first == firstType {
                    continue
                } else if query.name == "country",
                          query.value == country {
                    continue
                } else if query.name == "brands",
                          let queryBrands = query.value?.components(separatedBy: ","),
                          !queryBrands.isEmpty,
                          let first = queryBrands.first,
                          let firstBrand = brands.first,
                          first == firstBrand {
                    continue
                } else if query.name == "value_tag",
                          query.value == valueTag {
                    continue
                } else if query.name == "page",
                          query.value == "\(page)" {
                    continue
                } else {
                    XCTFail("testQuestionsProductQueryURL: query item missing")
                }
            }
            self.expectation?.fulfill()
        } else {
            XCTFail("testQuestionsProductQueryURL:no query items")
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // Check the query parts of unanswered questions
    func testUnansweredQuestionsQueryURL() throws {
        let count: UInt = 5
        let insightType: RBTF.InsightType = .brand
        let page: UInt = 5
        let country = "en:france"
        let request = RBTFUnansweredQuestionsRequest(count: count,
                                                     insightType: insightType,
                                                     country: country,
                                                     page: page)
        let queries = request.queryItems
        if !queries.isEmpty {
            for query in queries {
                if query.name == "count",
                   query.value == "\(count)" {
                    continue
                } else if query.name == "type",
                          let queryInsightTypes = query.value?.components(separatedBy: ","),
                          !queryInsightTypes.isEmpty,
                          let first = queryInsightTypes.first,
                          first == insightType.rawValue {
                    continue
                } else if query.name == "page",
                          query.value == "\(page)" {
                    continue
                } else if query.name == "country",
                          query.value == country {
                    continue
                } else {
                    XCTFail("testUnansweredQuestionsQueryURL: query item missing")
                }
            }
            self.expectation?.fulfill()
        } else {
            XCTFail("testUnansweredQuestionsQueryURL: no query items")
        }
        wait(for: [expectation], timeout: 1.0)
    }

}
