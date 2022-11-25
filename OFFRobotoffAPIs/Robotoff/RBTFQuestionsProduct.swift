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
    public struct QuestionsResponse: Codable {
        private var status: String?
        var questions: [Question]?
        var count: Int?
        
        var responseStatus: QuestionsResponseStatus {
            QuestionsResponseStatus.value(for: status)
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
        private var type: String?
        var value: String?
        var question: String?
        var insight_id: String?
        private var insight_type: String?
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
/**
The insight type, i.e. the subject the question is about.
  - case **brand**: extracts the product's brand from the image OCR.
  - case **category**: predicts the category of a product.
  - case **expirationDate**: extracts the expiration date from the image OCR.
  - case **imageOrientation**: predicts the image orientation of the given image.
  - case **ingredientSpellcheck**: corrects the spelling in the given ingredients list.
  - case **imageFlag**: flags inappropriate images based on OCR text.
  - case **imageLang**: detects which languages are mentioned on the product from the image OCR.
  - case **label**: predicts a label that appears on the product packaging photo.
  - case **location**: the location of where the product comes from from the image OCR.
  - case **nutrient**: the list of nutrients mentioned in a product, alongside their numeric value from the image OCR.
  - case **nutrientMention**: mentions of nutrients from the image OCR (without actual values).
  - case **nutritionImage**: tags images that have nutrition information based on the 'nutrient_mention' insight and the 'image_orientation' insight.
  - case **nutritionTableStructure**: detects the nutritional table structure from the image.
  - case **packaging**: detects the type of packaging based on the image OCR.
  - case **productWeight**: extracts the product weight from the image OCR.
  - case **store**: the store where the given product is sold from the image OCR.
  - case **trace**: detects traces that are present in the product from the image OCR.
- case **unknown** if something unforeseen happened;
*/
    enum InsightType: String, CaseIterable {
        case brand = "brand"
        case category = "category"
        case expirationDate = "expiration_date"
        case imageFlag = "image_flag"
        case imageLang = "image_lang"
        case imageOrientation = "image_orientation"
        case ingredientSpellcheck = "ingredient_spellcheck"
        case label = "label"
        case location = "location"
        case nutrient = "nutrient"
        case nutrientMention = "nutrient_mention"
        case nutritionImage = "nutrition_image"
        case nutritionTableStructure = "nutrition_table_structure"
        case packaging = "packaging"
        case productWeight = "product_weight"
        case store = "store"
        case trace = "trace"
        case unknown = "unknown"
        
        /// Function that converts a string to a InsightType case. These strings are used in the json responses.
        static func value(for string: String?) -> InsightType {
            guard let validString = string else { return .unknown }
            for item in InsightType.allCases {
                if item.rawValue == validString {
                    return item
                }
            }
            return .unknown
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
    func RBTFQuestionsProduct(with barcode: OFFBarcode, count: Int?, lang: String?, completion: @escaping (_ result: Result<RBTF.QuestionsResponse, RBTFError>) -> Void) {
        let request = HTTPRequest(api: .questions, barcode: barcode, count: count, lang: lang)
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
            let request = HTTPRequest(api: .random)
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
        let request = HTTPRequest(api: .random, languageCode: languageCode, count: count, insightTypes: insightTypes, country: country, brands: brands, valueTag: valueTag, page: page)
        fetch(request: request, responses: [200:RBTF.QuestionsResponse.self]) { (result) in
            completion(result)
            return
        }
    }

}
