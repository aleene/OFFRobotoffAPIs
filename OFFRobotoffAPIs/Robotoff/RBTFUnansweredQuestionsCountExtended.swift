//
//  RBTFUnansweredQuestionsCountExtended.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 21/12/2022.
//

// Use this file if you want to use the enumerated types for Insight Type and Country of the Unanswered Questions Endpoint. Also use the file RBTFUnansweredQuestionsCount.swift.

import Foundation

fileprivate class RBTFUnansweredQuestionsExtendedRequest: RBTFUnansweredQuestionsRequest {
    
/**
Initialiser for a HTTP request to create an URL for  the Unanswered Questions Endpoint.
 
-  Parameters:
 - count: the number of distinct value\_tags to return (default 25)
 - insightType: filter by the insight types (i.e. **InsightType.brand**)
 - country: filter by country (i.e. **Country.france**)
 - page: page index to return (starting at 1)

- Remarks:
Not all available query parameters for this endpoint have been implemented (server\_domain, reserved\_barcode, campaign, predictor)..
 */
    convenience init(count: UInt?,
                     insightType: RBTF.InsightType?,
                     country: Country?,
                     page: UInt?) {
        self.init(count: count,
                  insightType: insightType?.rawValue,
                  country: country?.key,
                  page: page)

    }
    
}

extension URLSession {
    
/**
Function to retrieve a random product wth a question with a list of query parameters to filter the questions

 - Parameters:
    - count: the number of questions to return (default=1)
    - insightType: filter by insight type (i.e. **InsightType.brand**)
    - country: filter by country tag (i.e. **Country.france**)
    - page: page index to return (starting at 1), default=1

 - returns:
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.QuestionsResponse struct and for the failure an Error.
 
Not all possible query parameters have been implemented, as they are not useful to everyone (server\_domain, reserved\_barcode, campaign, predictor).
*/
    func RBTFUnAnsweredQuestionsExtensionCount(count: UInt?,
                                      insightType: RBTF.InsightType?,
                                      country: Country?,
                                      page: UInt?,
                                      completion: @escaping (_ result: Result<RBTF.UnansweredQuestionsResponse, RBTFError>) -> Void) {
        let request = RBTFUnansweredQuestionsExtendedRequest(count: count,
                                                             insightType: insightType,
                                                              country: country,
                                                              page: page)
        fetch(request: request, responses: [200:RBTF.UnansweredQuestionsResponse.self]) { (result) in
            completion(result)
            return
        }
    }

}
