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

class RBTFUnansweredQuestionsRequest: RBTFRequest {
            
    convenience init(count: UInt?, insightType: RBTF.InsightType?, country: String?, page: UInt?) {
        self.init(api: .questionsUnanswered)
        // Are any query parameters required?
        if count != nil ||
            count != nil ||
            insightType != nil ||
            country != nil ||
            page != nil {
            var queryItems: [URLQueryItem] = []
            
            if let validCount = count,
               validCount >= 1 {
                queryItems.append(URLQueryItem(name: "count", value: "\(validCount)" ))
            }
            
            if let validInsightType = insightType {
                queryItems.append(URLQueryItem(name: "type", value: validInsightType.rawValue ))
            }

            if let validCountry = country {
                queryItems.append(URLQueryItem(name: "country", value: "\(validCountry)" ))
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
        let request = RBTFUnansweredQuestionsRequest(count: count, insightType: insightType, country: country, page: page)
        fetch(request: request, responses: [200:RBTF.UnansweredQuestionsResponse.self]) { (result) in
            completion(result)
            return
        }
    }

}
