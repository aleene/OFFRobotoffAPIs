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
    
/**
The datastructure retrieved for a reponse 200 for the Questions Product API and Questions Random API

**Variables:**
 - responseStatus: the *QuestionsResponseStatus* of the response:
 - questions: an array of *Question*
 - count: the number of questions
*/
    public struct QuestionsResponse: Codable, Equatable {
        var status: String?
        var questions: [Question]?
        var count: Int?
        
        var responseStatus: QuestionsResponseStatus {
            QuestionsResponseStatus.value(for: status)
        }
        
        // Function to make QuestionsResponse Equatable
        static func ==(lhs: QuestionsResponse, rhs: QuestionsResponse) -> Bool {
            if rhs.status == lhs.status &&
                rhs.count == lhs.count &&
                rhs.questions == lhs.questions {
                return true
            }
            return false
            
        }

    }
    
/**
 The response status for the Questions Product API and Questions Random API
 - case **found** if questions have been found;
 - case **no_questions** if no questions have been found;
 - case **unknown** if something unforeseen happened;
*/
    enum QuestionsResponseStatus: String, CaseIterable {
        case found = "found"
        case no_questions = "no_questions"
        case unknown = "unknown"
        
        /// Function that converts a string to a QuestionsResponseStatus case. These strings are used in the json responses.
        static func value(for string: String?) -> QuestionsResponseStatus {
            guard let validString = string else { return .unknown }
            for item in QuestionsResponseStatus.allCases {
                if item.rawValue == validString {
                    return item
                }
            }
            return .unknown
        }

    }

    public struct Question: Codable, Equatable {
        var barcode: String?
        var type: String?
        var value: String?
        var question: String?
        var insight_id: String?
        var insight_type: String?
        var value_tag: String?
        var source_image_url: String?
        
        
        var insightType: InsightType {
            InsightType.value(for: insight_type)
        }
        
        var questionType : QuestionType {
            QuestionType.value(for: type)
        }
        
        // Function to make q question Equatable
        static func ==(lhs: Question, rhs: Question) -> Bool {
            guard let validLHSid = lhs.insight_id else { return false }
            guard let validRHSid = rhs.insight_id else { return false }
            return validLHSid == validRHSid
        }

    }
/**
The question type. Only one type is supported at 23-nov-2022.
- case **add_binary**a question that can have an answer like conform, deny or abstain;
- case **unknown** if something unforeseen happened;
*/
    enum QuestionType: String, CaseIterable {
        case add_binary = "add-binary"
        case unknown = "unknown"
        
        /// Function that converts a string to a QuestionType case. These strings are used in the json responses.
        static func value(for string: String?) -> QuestionType {
            guard let validString = string else { return .unknown }
            for item in QuestionType.allCases {
                if item.rawValue == validString {
                    return item
                }
            }
            return .unknown
        }
    }

}

class RBTFQuestionsRequest: RBTFRequest {
    
    convenience init(barcode: OFFBarcode,
                     count: UInt?, lang:
                     String?) {
        self.init(api: .questions)
        self.path = self.path + "/" + barcode.barcode.description
        if count != nil || lang != nil {
            if let validCount = count {
                queryItems.append(URLQueryItem(name: "count", value: "\(validCount)" ))
            }
            if let validLang = lang,
               validLang.count == 3,
               validLang.hasSuffix(":") {
                queryItems.append(URLQueryItem(name: "lang", value: validLang ))
            }
        }
    }
    
    convenience init(api: RBTF.APIs,
                     languageCode: String?,
                     count: UInt?,
                     insightTypes: [RBTF.InsightType],
                     country: String?,
                     brands: [String],
                     valueTag: String?,
                     page: UInt?) {
        self.init(api: api)
        // Are any query parameters required?
        if count != nil ||
            languageCode != nil ||
            !insightTypes.isEmpty ||
            country != nil ||
            !brands.isEmpty ||
            valueTag != nil ||
            page != nil {
            
            if let validLang = languageCode,
               validLang.count == 3,
               validLang.hasSuffix(":") {
                queryItems.append(URLQueryItem(name: "lang", value: validLang ))
            }
            
            if let validCount = count,
               validCount >= 1 {
                queryItems.append(URLQueryItem(name: "count", value: "\(validCount)" ))
            }
            
            if !insightTypes.isEmpty {
                let insights = insightTypes.map({ $0.rawValue }).joined(separator: ",")
                queryItems.append(URLQueryItem(name: "insight_types", value: "\(insights)" ))
            }
            
            if let validCountry = country {
                queryItems.append(URLQueryItem(name: "country", value: "\(validCountry)" ))
            }
            
            if !brands.isEmpty {
                let brandsString = brands.joined(separator: ",")
                queryItems.append(URLQueryItem(name: "brands", value: "\(brandsString)" ))
            }
            
            if let validValueTag = valueTag {
                queryItems.append(URLQueryItem(name: "value_tag", value: "\(validValueTag)" ))
            }
            
            if let validPage = page,
               validPage >= 1 {
                queryItems.append(URLQueryItem(name: "page", value: "\(validPage)" ))
            }
        }
    }
    
}

extension URLSession {
    
/**
 Function which retrieves the possible questions for a specific product.
 
- Parameters:
    - offbarcode: the OFFBarcode for the product;
    - count: the  maximum numer of questions to be retrived for this product. If not specified the value is **1**;
    - lang: the language code for the question and possible answer. If not specified **en** is assumed (english);

- returns:
 A completion block with a Result enum (success or failure). The associated value for success is a RBTF.QuestionsResponse struct and for the failure an Error.
*/
    func RBTFQuestionsProduct(with barcode: OFFBarcode,
                              count: UInt?,
                              lang: String?,
                              completion: @escaping (_ result: Result<RBTF.QuestionsResponse, RBTFError>) -> Void) {
        guard !barcode.barcode.isEmpty else {
            completion(.failure(.barcodeEmpty))
            return
        }
        let request = RBTFQuestionsRequest(barcode: barcode, count: count, lang: lang)
        fetch(request: request, responses: [200:RBTF.QuestionsResponse.self]) { (result) in
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
        let request = RBTFRequest(api: .questionsRandom)
        fetch(request: request, responses: [200:RBTF.QuestionsResponse.self]) { (result) in
                completion(result)
            return
        }
    }

/**
Function to retrieve a random product wth a question with a list of query parameters to filter the questions

 - Parameters:
    - languageCode: the language of the question/value
    - count: the number of questions to return (default=1
    - insightTypes: list, filter by insight types
    - country: filter by country tag
    - brands: list, filter by brands
    - valueTag: filter by value tag, i.e the value that is going to be sent to Product Opener, example: value\_tag=en:organic
    - page: page index to return (starting at 1), default=1

 - returns:
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.QuestionsResponse struct and for the failure an Error.
 
Not all possible query parameters have been implemented, as they are not useful to everyone (server\_domain, reserved\_barcode, capaign, predictor).
*/
    func RBTFQuestionsRandom(languageCode: String?, count: UInt?, insightTypes: [RBTF.InsightType], country: String?, brands: [String], valueTag: String?, page: UInt?, completion: @escaping (_ result: Result<RBTF.QuestionsResponse, RBTFError>) -> Void) {
        let request = RBTFQuestionsRequest(api: .questionsRandom, languageCode: languageCode, count: count, insightTypes: insightTypes, country: country, brands: brands, valueTag: valueTag, page: page)
        fetch(request: request, responses: [200:RBTF.QuestionsResponse.self]) { (result) in
            completion(result)
            return
        }
    }
/**
Function to retrieve 25 popular products wth a question.

- returns:
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.QuestionsResponse struct and for the failure an Error.
*/
        func RBTFQuestionsPopular(completion: @escaping (_ result: Result<RBTF.QuestionsResponse, RBTFError>) -> Void) {
            let request = RBTFRequest(api: .questionsPopular)
            fetch(request: request, responses: [200:RBTF.QuestionsResponse.self]) { (result) in
                completion(result)
                return
            }
        }

/**
Function to retrieve 25 popular products wth a question with a list of query parameters to filter the questions

 - Parameters:
    - languageCode: the language of the question/value
    - count: the number of questions to return (default=1
    - insightTypes: list, filter by insight types
    - country: filter by country tag
    - brands: list, filter by brands
    - valueTag: filter by value tag, i.e the value that is going to be sent to Product Opener, example: value\_tag=en:organic
    - page: page index to return (starting at 1), default=1

 - returns:
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.QuestionsResponse struct and for the failure an Error.
 
Not all possible query parameters have been implemented, as they are not useful to everyone (server\_domain, reserved\_barcode, capaign, predictor).
*/
    func RBTFQuestionsPopular(languageCode: String?, count: UInt?, insightTypes: [RBTF.InsightType], country: String?, brands: [String], valueTag: String?, page: UInt?, completion: @escaping (_ result: Result<RBTF.QuestionsResponse, RBTFError>) -> Void) {
        let request = RBTFQuestionsRequest(api: .questionsPopular, languageCode: languageCode, count: count, insightTypes: insightTypes, country: country, brands: brands, valueTag: valueTag, page: page)
        fetch(request: request, responses: [200:RBTF.QuestionsResponse.self]) { (result) in
            completion(result)
            return
        }
    }

}
