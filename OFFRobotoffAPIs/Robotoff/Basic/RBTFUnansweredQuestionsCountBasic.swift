//
//  RBTFUnansweredQuestionsCount.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 25/11/2022.
//

// Use this file if you want to use the Unanswered Questions Endpoint

import Foundation

extension RBTF {
    
/**
The datastructure retrieved for a 200-reponse 200 for the UnansweredQuestions endpoint.
     
- Variables:**
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

class RBTFUnansweredQuestionsRequestBasic: RBTFRequest {
            
    convenience init(count: UInt?,
                     insightType: String?,
                     country: String?, page: UInt?) {
        self.init(api: .questionsUnanswered)
        // Are any query parameters required?
        if count != nil ||
            count != nil ||
            insightType != nil ||
            country != nil ||
            page != nil {
            
            if let validCount = count,
               validCount >= 1 {
                queryItems.append(URLQueryItem(name: "count", value: "\(validCount)" ))
            }
            
            if let validInsightType = insightType {
                queryItems.append(URLQueryItem(name: "type", value: validInsightType ))
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
    func RBTFUnAnsweredQuestionsCount(count: UInt?,
                                      insightType: String?,
                                      country: String?,
                                      page: UInt?,
                                      completion: @escaping (_ result: Result<RBTF.UnansweredQuestionsResponse, RBTFError>) -> Void) {
        let request = RBTFUnansweredQuestionsRequestBasic(count: count,
                                                          insightType: insightType,
                                                          country: country,
                                                          page: page)
        fetch(request: request, responses: [200:RBTF.UnansweredQuestionsResponse.self]) { (result) in
            completion(result)
            return
        }
    }

}
