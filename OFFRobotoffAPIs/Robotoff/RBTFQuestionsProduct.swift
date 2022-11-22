//
//  FSNMHello.swift
//  OFFFolksonomy
//
//  Created by Arnaud Leene on 05/11/2022.
//

import Foundation
//
//  Extensions for the Questions Product API:
//  Get questions for a given product
//
extension RBTF {
/// the datastructure retrieved for reponse 200 for the Questions Product API
    public struct QuestionsResponse: Codable {
        var status: String?
        var count: Int?
        var questions: [Question]?
        
        var statusResponse: QuestionsResponseStatus? {
            guard let validStatus = status else { return nil }
            for item in QuestionsResponseStatus.allCases {
                if item.rawValue == validStatus {
                    return item
                }
            }
            return nil
        }
        
    }
    
    enum QuestionsResponseStatus: String, CaseIterable {
        case found = "found"
        case no_questions = "no_questions"
    }

    public struct Question: Codable {
        var barcode: String?
        var type: String?
        var value: String?
        var question: String?
        var insight_id: String? // needed to report back?
        var value_tag: String?
        var source_image_url: String?
        
        
        var questionType: RBTFQuestionType {
            switch type {
            case "brand": return .brand
            case "category": return .category
            case "expiration_date": return .expirationDate
            case "ingredient_spellcheck": return .ingredientSpellcheck
            case "label": return .label
            case "nutrient": return .nutrient
            case "packager_code": return .packagerCode
            case "product_weight": return .quantity
            case "store": return .store
            default: return .unknown
            }
        }
        
        static func ==(lhs: Question, rhs: Question) -> Bool {
            guard let validLHSid = lhs.insight_id else { return false }
            guard let validRHSid = rhs.insight_id else { return false }
            return validLHSid == validRHSid
        }

    }
    
    enum RBTFQuestionType {
        case brand
        case category
        case expirationDate
        case ingredientSpellcheck
        case label
        case nutrient
        case packagerCode
        case quantity
        case store
        case unknown
    }

}

extension URLSession {
    
/**
 Function which provides the question for a specific product.

- returns:
 A completion block with a Result enum (success or failure). The associated value for success is a RBTF.QuestionsResponse struct and for the failure an Error.
*/
    func RBTFQuestionsProduct(with barcode: OFFBarcode, completion: @escaping (_ result: Result<RBTF.QuestionsResponse, RBTFError>) -> Void) {
        fetch(request: HTTPRequest(api: .questions, barcode: barcode), responses: [200:RBTF.QuestionsResponse.self]) { (result) in
            completion(result)
            return
        }
    }
    
/**
Function to retrieve a random product wth a question.

- returns:
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.QuestionsResponse struct and for the failure an Error.
*/
        func RBTFQuestionsRandom(completion: @escaping (_ result: Result<RBTF.QuestionsResponse, RBTFError>) -> Void) {
            fetch(request: HTTPRequest(api: .random), responses: [200:RBTF.QuestionsResponse.self]) { (result) in
                completion(result)
                return
            }
        }

}
