//
//  RBTFInsights.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 28/11/2022.
//

import Foundation

extension RBTF {
    
/**
The datastructure retrieved for a reponse 200 for the Insights Random API

**Variables:**
 - questions: an array of *Insight*
*/
    public struct InsightsResponse: Codable {
        var insights: [Insight]?
        var count: Int?
        private var status: String?
        
        var responseStatus: InsightsResponseStatus {
            InsightsResponseStatus.value(for: status)
        }

    }

    public struct Insight: Codable {
        
        var id: String?
        var type: String?
        private var barcode: String?
        var data: InsightData?
        var timestamp: String?
        var completed_at: String?
        var annotation: String?
        var annotated_result: String?
        var n_votes: Int?
        var username: String?
        var countries: [String]?
        var brands: [String]?
        var process_after: String?
        var value_tag: String?
        var value: String?
        var source_image: String?
        var automatic_processing: Bool?
        var server_domain: String?
        var server_type: String?
        var unique_scans_n: Int?
        var reserved_barcode: Bool?
        var predictor: String?
        var campaign: [String]?
        
        var offBarcode: OFFBarcode? {
            barcode != nil ? OFFBarcode(barcode: "\(barcode!)") : nil
        }
        
        var insightType: InsightType {
            InsightType.value(for: type)
        }
        
        var brandsCombined: String? {
            guard let validBrands = brands else { return nil }
            return validBrands.joined(separator: ", ")
        }
        
        var countriesCombined: String? {
            guard let validCountries = countries else { return nil }
            return validCountries.joined(separator: ", ")
        }
        
        var campaignCombined: String? {
            guard let validCampaign = campaign else { return nil }
            return validCampaign.joined(separator: ", ")
        }

    }
    
    public struct InsightData: Codable {
        var lang: String?
        var confidence: Float?
    }
/**
 The response status for the Insights Random API
 - case **found** if questions have been found;
 - case **no_insights** if no questions have been found;
 - case **unknown** if something unforeseen happened;
*/
    enum InsightsResponseStatus: String, CaseIterable {
        case found = "found"
        case no_insights = "no_insights"
        case unknown = "unknown"
        
        /// Function that converts a string to a InsightsResponseStatus case. These strings are used in the json responses.
        static func value(for string: String?) -> InsightsResponseStatus {
            guard let validString = string else { return .unknown }
            for item in InsightsResponseStatus.allCases {
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
Function to retrieve a random insights with a list of query parameters to filter the questions

 - Parameters:
    - insightType:  filter by insight type
    - country: filter by country tag
    - valueTag: filter by value tag
    - count: the number of questions to return (default=1

 - returns:
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.InsightsResponse struct and for the failure an Error.
 
Not all possible query parameters have been implemented, as they are not useful to everyone (server\_domain, campaign, predictor).
*/
    func RBTFInsightsRandom(insightType: RBTF.InsightType?, country: String?, valueTag: String?, count: UInt?, completion: @escaping (_ result: Result<RBTF.InsightsResponse, RBTFError>) -> Void) {
        let request = HTTPRequest(insightType: insightType, country: country, valueTag: valueTag, count: count)
        fetch(request: request, responses: [200:RBTF.InsightsResponse.self]) { (result) in
            completion(result)
            return
        }
    }

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
    func RBTFInsightsBarcode(barcode: OFFBarcode, insightType: RBTF.InsightType?, country: String?, valueTag: String?, count: UInt?, completion: @escaping (_ result: Result<RBTF.InsightsResponse, RBTFError>) -> Void) {
        let request = HTTPRequest(barcode: barcode, insightType: insightType, country: country, valueTag: valueTag, count: count)
            fetch(request: request, responses: [200:RBTF.InsightsResponse.self]) { (result) in
                completion(result)
                return
            }
        }

}
