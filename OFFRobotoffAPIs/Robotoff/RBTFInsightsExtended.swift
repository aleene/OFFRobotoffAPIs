//
//  RBTFInsightsExtensions.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 20/12/2022.
//

import Foundation

class RBTInsightsExtensionRequest: RBTFInsightsRequest {
    
    convenience init (barcode: OFFBarcode, insightType: RBTF.InsightType?, country: Country?, valueTag: String?, count: UInt?) {
        self.init(barcode: barcode.barcode, insightType: insightType, country: country?.key, valueTag: valueTag, count: count)
    }
    
    convenience init(insightType: RBTF.InsightType?, country: Country?, valueTag: String?, count: UInt?) {
        self.init(insightType: insightType, country: country?.key, valueTag: valueTag, count: count)
        }
    
}

extension URLSession {
    /**
     Function to retrieve a random insights with a list of query parameters to filter the questions
     
     - Parameters:
     - barcode: barcode for which this insights are sought (required)
     - insightType:  filter by insight type
     - country: filter by country tag
     - valueTag: filter by value tag
     count: the number of questions to return (default=1
     
     - returns:
     A completion block with a Result enum (success or failure). The associated value for success is a RBTF.InsightsResponse struct and for the failure an Error.
     
     Not all possible query parameters have been implemented, as they are not useful to everyone (server\_domain, campaign, predictor).
     */
    func RBTFInsights(barcode: OFFBarcode, insightType: RBTF.InsightType?, country: Country?, valueTag: String?, count: UInt?, completion: @escaping (_ result: Result<RBTF.InsightsResponse, RBTFError>) -> Void) {
        let request = RBTInsightsExtensionRequest(barcode: barcode, insightType: insightType, country: country, valueTag: valueTag, count: count)
        fetch(request: request, responses: [200:RBTF.InsightsResponse.self]) { (result) in
            completion(result)
            return
        }
    }
    
    func RBTFInsights(insightType: RBTF.InsightType?, country: Country?, valueTag: String?, count: UInt?, completion: @escaping (_ result: Result<RBTF.InsightsResponse, RBTFError>) -> Void) {
        let request = RBTInsightsExtensionRequest(insightType: insightType, country: country, valueTag: valueTag, count: count)
        fetch(request: request, responses: [200:RBTF.InsightsResponse.self]) { (result) in
            completion(result)
            return
        }
    }
    

}
