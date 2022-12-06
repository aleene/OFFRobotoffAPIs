//
//  RBTFQuestionsDecodeTests.swift
//  OFFRobotoffAPIsTests
//
//  Created by Arnaud Leene on 30/11/2022.
//

import XCTest
@testable import OFFRobotoffAPIs

final class RBTFDecodingTests: XCTestCase {

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
                        XCTFail("RBTFDecodingTests:testDecodeNoQuestions:Not equal.")
                    }
                case .failure(let error):
                    XCTFail("RBTFDecodingTests:testDecodeNoQuestions:Error: \(error)")
                }
            }

        } catch {
            XCTFail("RBTFDecodingTests:testDecodeNoQuestions:No valid data.")
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
                        XCTFail("RBTFDecodingTests:testDecodeOneQuestions:Not equal.")
                    }
                case .failure(let error):
                    XCTFail("RBTFDecodingTests:testDecodeOneQuestions:Error: \(error)")
                }
            }
        } catch {
            XCTFail("RBTFDecodingTests:testDecodeOneQuestions:No valid data.")
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
                        XCTFail("RBTFDecodingTests:testDecodeNotEqual: equal.")
                    } else {
                        self.expectation?.fulfill()
                    }
                case .failure(let error):
                    XCTFail("RBTFDecodingTests:testDecodeNotEqual:Error: \(error)")
                }
            }

        } else {
            XCTFail("RBTFDecodingTests:testDecodeNotEqual:No valid data.")
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
                        XCTFail("RBTFDecodingTests:testDecodeTypeMismatch: equal.")
                    } else {
                        XCTFail("RBTFDecodingTests:testDecodeTypeMismatch: not equal:")
                    }
                case .failure(let error):
                    switch error {
                    case .valueNotFound(_, _):
                        XCTFail("RBTFDecodingTests:testDecodeTypeMismatch:valueNotFound:")
                    case .typeMismatch(_, _):
                        self.expectation?.fulfill()
                    case .keyNotFound(_, _):
                        XCTFail("RBTFDecodingTests:testDecodeTypeMismatch:keyNotFound:")
                    case .dataCorrupted(_):
                        XCTFail("RBTFDecodingTests:testDecodeTypeMismatch:dataCorrupted:")
                    @unknown default:
                        XCTFail("RBTFDecodingTests:testDecodeTypeMismatch:Error:")

                    }
                }
            }

        } else {
            XCTFail("RBTFDecodingTests:testDecodeTypeMismatch:No valid data.")
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
                        XCTFail("RBTFDecodingTests:testDecodeKeyMismatch: equal.")
                    } else {
                        self.expectation?.fulfill()

                    }
                case .failure(let error):
                    switch error {
                    case .valueNotFound(_, _):
                        XCTFail("RBTFDecodingTests:testDecodeKeyMismatch:valueNotFound:")
                    case .typeMismatch(_, _):
                        XCTFail("RBTFDecodingTests:testDecodeKeyMismatch:typeMismatch:")
                    case .keyNotFound(_, _):
                        XCTFail("RBTFDecodingTests:testDecodeKeyMismatch:keyNotFound:")
                    case .dataCorrupted(_):
                        XCTFail("RBTFDecodingTests:testDecodeKeyMismatch:dataCorrupted:")
                    @unknown default:
                        XCTFail("RBTFDecodingTests:testDecodeKeyMismatch:Error:")

                    }
                }
            }

        } else {
            XCTFail("RBTFDecodingTests:testDecodeKeyMismatch:No valid data.")
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
                        XCTFail("RBTFDecodingTests:testDecodeDataCorrupted: equal.")
                    } else {
                        XCTFail("RBTFDecodingTests:testDecodeDataCorrupted: not equal.")

                    }
                case .failure(let error):
                    switch error {
                    case .valueNotFound(_, _):
                        XCTFail("RBTFDecodingTests:testDecodeDataCorrupted:valueNotFound:")
                    case .typeMismatch(_, _):
                        XCTFail("RBTFDecodingTests:testDecodeDataCorrupted:typeMismatch:")
                    case .keyNotFound(_, _):
                        XCTFail("RBTFDecodingTests:testDecodeDataCorrupted:keyNotFound:")
                    case .dataCorrupted(_):
                        self.expectation?.fulfill()
                    @unknown default:
                        XCTFail("RBTFDecodingTests:testDecodeDataCorrupted:error:")
                    }
                }
            }

        } else {
            XCTFail("RBTFDecodingTests:testDecodeDataCorrupted:No valid data.")
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
                        XCTFail("RBTFDecodingTests:testDecodeExtraKey: equal.")
                    } else {
                        self.expectation?.fulfill()

                    }
                case .failure(let error):
                    switch error {
                    case .valueNotFound(_, _):
                        XCTFail("RBTFDecodingTests:testDecodeExtraKey:valueNotFound:")
                    case .typeMismatch(_, _):
                        XCTFail("RBTFDecodingTests:testDecodeExtraKey:typeMismatch:")
                    case .keyNotFound(_, _):
                        XCTFail("RBTFDecodingTests:testDecodeExtraKey:keyNotFound:")
                    case .dataCorrupted(_):
                        XCTFail("RBTFDecodingTests:testDecodeExtraKey:dataCorrupted:")
                    @unknown default:
                        XCTFail("RBTFDecodingTests:testDecodeExtraKey:error:")
                    }
                }
            }

        } else {
            XCTFail("RBTFDecodingTests:testDecodeExtraKey:No valid data.")
        }
                
        wait(for: [expectation], timeout: 1.0)
    }

}
