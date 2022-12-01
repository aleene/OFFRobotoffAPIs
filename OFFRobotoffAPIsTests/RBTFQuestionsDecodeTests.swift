//
//  RBTFQuestionsDecodeTests.swift
//  OFFRobotoffAPIsTests
//
//  Created by Arnaud Leene on 30/11/2022.
//

import XCTest
@testable import OFFRobotoffAPIs

final class RBTFQuestionsDecodeTests: XCTestCase {

    var expectation: XCTestExpectation!

    override func setUpWithError() throws {
        expectation = expectation(description: "Expectation")
    }
    
    func testDecodeNoQuestions() throws {
        var questionsResponse = RBTF.QuestionsResponse()
        questionsResponse.status = "no_questions"
        questionsResponse.questions = []
        questionsResponse.count = 0
        
        do {
            let data = try JSONEncoder().encode(questionsResponse)
            
            Decoding.decode(data: data, type: RBTF.QuestionsResponse.self) { (result) in
                switch result {
                case .success(let decodedQuestionsResponse):
                    if questionsResponse == decodedQuestionsResponse {
                        self.expectation?.fulfill()
                    } else {
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeNoQuestions:Not equal.")
                    }
                case .failure(let error):
                    XCTFail("RBTFQuestionsDecodeTests:testDecodeNoQuestions:Error: \(error)")
                }
            }

        } catch {
            XCTFail("RBTFQuestionsDecodeTests:testDecodeNoQuestions:No valid data.")
        }
                
        wait(for: [expectation], timeout: 1.0)
    }

    func testDecodeOneQuestions() throws {
        
        var question = RBTF.Question()
        question.barcode = "1234"
        question.type = "add-binary"
        question.value = "value"
        question.insight_id = "some id"
        question.insight_type = "where are these defined?"
        question.value_tag = "valueTag"
        question.source_image_url = "should check the url"
        
        var questionsResponse = RBTF.QuestionsResponse()
        questionsResponse.status = "no_questions"
        questionsResponse.questions = [question]
        questionsResponse.count = 0
        
        do {
            let data = try JSONEncoder().encode(questionsResponse)

            Decoding.decode(data: data, type: RBTF.QuestionsResponse.self) { (result) in
                switch result {
                case .success(let decodedQuestionsResponse):
                    if questionsResponse == decodedQuestionsResponse {
                        self.expectation?.fulfill()
                    } else {
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeOneQuestions:Not equal.")
                    }
                case .failure(let error):
                    XCTFail("RBTFQuestionsDecodeTests:testDecodeOneQuestions:Error: \(error)")
                }
            }
        } catch {
            XCTFail("RBTFQuestionsDecodeTests:testDecodeOneQuestions:No valid data.")
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // Test with a missing key/value
    func testDecodeNotEqual() throws {
        var questionsResponse = RBTF.QuestionsResponse()
        questionsResponse.status = "no_questions"
        questionsResponse.questions = []
        questionsResponse.count = 0
        
        let jsonString = """
                             {
                                "status": "\(questionsResponse.status!)",
                                "questions": [ { } ]
                             }
                             """
        if let data = jsonString.data(using: .utf8) {
                        
            Decoding.decode(data: data, type: RBTF.QuestionsResponse.self) { (result) in
                switch result {
                case .success(let decodedQuestionsResponse):
                    if questionsResponse == decodedQuestionsResponse {
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeNotEqual: equal.")
                    } else {
                        self.expectation?.fulfill()
                    }
                case .failure(let error):
                    XCTFail("RBTFQuestionsDecodeTests:testDecodeNotEqual:Error: \(error)")
                }
            }

        } else {
            XCTFail("RBTFQuestionsDecodeTests:testDecodeNotEqual:No valid data.")
        }
                
        wait(for: [expectation], timeout: 1.0)
    }

    // Test when one of the jason values is a string instead of an int
    func testDecodeTypeMismatch() throws {
        var questionsResponse = RBTF.QuestionsResponse()
        questionsResponse.status = "no_questions"
        questionsResponse.questions = []
        questionsResponse.count = 0
        
        let jsonString = """
                             {
                                "status": "\(questionsResponse.status!)",
                                "questions": [ { } ],
                                "count": "\(questionsResponse.count!)"
                             }
                             """
        if let data = jsonString.data(using: .utf8) {
                        
            Decoding.decode(data: data, type: RBTF.QuestionsResponse.self) { (result) in
                switch result {
                case .success(let decodedQuestionsResponse):
                    if questionsResponse == decodedQuestionsResponse {
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeTypeMismatch: equal.")
                    } else {
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeTypeMismatch: not equal:")
                    }
                case .failure(let error):
                    switch error {
                    case .valueNotFound(_, _):
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeTypeMismatch:valueNotFound:")
                    case .typeMismatch(_, _):
                        self.expectation?.fulfill()
                    case .keyNotFound(_, _):
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeTypeMismatch:keyNotFound:")
                    case .dataCorrupted(_):
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeTypeMismatch:dataCorrupted:")
                    @unknown default:
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeTypeMismatch:Error:")

                    }
                }
            }

        } else {
            XCTFail("RBTFQuestionsDecodeTests:testDecodeTypeMismatch:No valid data.")
        }
                
        wait(for: [expectation], timeout: 1.0)
    }

    // Test where one of the keys is different
    func testDecodeKeyMismatch() throws {
        var questionsResponse = RBTF.QuestionsResponse()
        questionsResponse.status = "no_questions"
        questionsResponse.questions = []
        questionsResponse.count = 0
        
        let jsonString = """
                             {
                                "status": "\(questionsResponse.status!)",
                                "questions": [ { } ],
                                "something_else": \(questionsResponse.count!)
                             }
                             """
        if let data = jsonString.data(using: .utf8) {
                        
            Decoding.decode(data: data, type: RBTF.QuestionsResponse.self) { (result) in
                switch result {
                case .success(let decodedQuestionsResponse):
                    if questionsResponse == decodedQuestionsResponse {
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeKeyMismatch: equal.")
                    } else {
                        self.expectation?.fulfill()

                    }
                case .failure(let error):
                    switch error {
                    case .valueNotFound(_, _):
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeKeyMismatch:valueNotFound:")
                    case .typeMismatch(_, _):
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeKeyMismatch:typeMismatch:")
                    case .keyNotFound(_, _):
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeKeyMismatch:keyNotFound:")
                    case .dataCorrupted(_):
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeKeyMismatch:dataCorrupted:")
                    @unknown default:
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeKeyMismatch:Error:")

                    }
                }
            }

        } else {
            XCTFail("RBTFQuestionsDecodeTests:testDecodeKeyMismatch:No valid data.")
        }
                
        wait(for: [expectation], timeout: 1.0)
    }

    // Test where one of values in the json is not set
    func testDecodeDataCorrupted() throws {
        var questionsResponse = RBTF.QuestionsResponse()
        questionsResponse.status = "no_questions"
        questionsResponse.questions = []
        questionsResponse.count = 0
        
        let jsonString = """
                             {
                                "status": ,
                                "questions": [ { } ],
                                "something_else": \(questionsResponse.count!)
                             }
                             """
        if let data = jsonString.data(using: .utf8) {
                        
            Decoding.decode(data: data, type: RBTF.QuestionsResponse.self) { (result) in
                switch result {
                case .success(let decodedQuestionsResponse):
                    if questionsResponse == decodedQuestionsResponse {
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeDataCorrupted: equal.")
                    } else {
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeDataCorrupted: not equal.")

                    }
                case .failure(let error):
                    switch error {
                    case .valueNotFound(_, _):
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeDataCorrupted:valueNotFound:")
                    case .typeMismatch(_, _):
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeDataCorrupted:typeMismatch:")
                    case .keyNotFound(_, _):
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeDataCorrupted:keyNotFound:")
                    case .dataCorrupted(_):
                        self.expectation?.fulfill()
                    @unknown default:
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeDataCorrupted:error:")
                    }
                }
            }

        } else {
            XCTFail("RBTFQuestionsDecodeTests:testDecodeDataCorrupted:No valid data.")
        }
                
        wait(for: [expectation], timeout: 1.0)
    }

    // Test with an additional key in the data
    func testDecodeExtraKey() throws {
        var questionsResponse = RBTF.QuestionsResponse()
        questionsResponse.status = "no_questions"
        questionsResponse.questions = []
        questionsResponse.count = 0
        
        let jsonString = """
                             {
                                "status": "\(questionsResponse.status!)",
                                "questions": [ { } ],
                                "count": \(questionsResponse.count!),
                                "an_additional_key": "additional too"
                             }
                             """
        if let data = jsonString.data(using: .utf8) {
                        
            Decoding.decode(data: data, type: RBTF.QuestionsResponse.self) { (result) in
                switch result {
                case .success(let decodedQuestionsResponse):
                    if questionsResponse == decodedQuestionsResponse {
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeExtraKey: equal.")
                    } else {
                        self.expectation?.fulfill()

                    }
                case .failure(let error):
                    switch error {
                    case .valueNotFound(_, _):
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeExtraKey:valueNotFound:")
                    case .typeMismatch(_, _):
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeExtraKey:typeMismatch:")
                    case .keyNotFound(_, _):
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeExtraKey:keyNotFound:")
                    case .dataCorrupted(_):
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeExtraKey:dataCorrupted:")
                    @unknown default:
                        XCTFail("RBTFQuestionsDecodeTests:testDecodeExtraKey:error:")
                    }
                }
            }

        } else {
            XCTFail("RBTFQuestionsDecodeTests:testDecodeExtraKey:No valid data.")
        }
                
        wait(for: [expectation], timeout: 1.0)
    }

}
