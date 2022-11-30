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
        
        let data = try? JSONEncoder().encode(questionsResponse)
                
        OFFAPI.decode(data: data, type: RBTF.QuestionsResponse.self) { (result) in
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
        
        let data = try? JSONEncoder().encode(questionsResponse)
                
        OFFAPI.decode(data: data, type: RBTF.QuestionsResponse.self) { (result) in
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
        wait(for: [expectation], timeout: 1.0)
    }

}
