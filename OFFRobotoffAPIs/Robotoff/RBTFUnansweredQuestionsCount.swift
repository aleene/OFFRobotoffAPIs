//
//  RBTFUnansweredQuestionsCount.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 25/11/2022.
//

import Foundation

extension RBTF {
    
    /**
     The datastructure retrieved for a reponse 200 for the Questions Product API and Questions Random API
     
     **Variables:**
     - responseStatus: the *QuestionsResponseStatus* of the response:
     - questions: a dictionary with as key the value_tag (String) and as value the number of questions (int)
     - count: the number of questions
     */
    public struct UnansweredQuestionsResponse: Codable {
        private var status: String?
        var questions: [[String?:Int]]
        var count: Int?
        
        var responseStatus: QuestionsResponseStatus {
            QuestionsResponseStatus.value(for: status)
        }
        
    }
}

class RBTFQuestionsRequest: RBTFRequest {
    
    convenience init(api: RBTF.APIs, barcode: OFFBarcode, count: Int?, lang: String?) {
        self.init(api: api)
        self.path = self.path + "/" + barcode.barcode.description
        if count != nil || lang != nil {
            var queryItems: [URLQueryItem] = []
            
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
    
    convenience init(api: RBTF.APIs, languageCode: String?, count: UInt?, insightTypes: [RBTF.InsightType], country: String?, brands: [String], valueTag: String?, page: UInt?) {
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
Function to retrieve a random product wth a question with a list of query parameters to filter the questions

 - Parameters:
    - count: the number of questions to return (default=1
    - insightType:  filter by insight type
    - country: filter by country tag
    - page: page index to return (starting at 1), default=1

 - returns:
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.QuestionsResponse struct and for the failure an Error.
 
Not all possible query parameters have been implemented, as they are not useful to everyone (server\_domain, reserved\_barcode, capaign, predictor).
*/
    func RBTFUnAnsweredQuestionsCount(count: UInt?, insightType: RBTF.InsightType?, country: String?, page: UInt?, completion: @escaping (_ result: Result<RBTF.UnansweredQuestionsResponse, RBTFError>) -> Void) {
        let request = RBTFInsightsRequest(count: count, insightType: insightType, country: country, page: page)
        fetch(request: request, responses: [200:RBTF.UnansweredQuestionsResponse.self]) { (result) in
            completion(result)
            return
        }
    }

}
