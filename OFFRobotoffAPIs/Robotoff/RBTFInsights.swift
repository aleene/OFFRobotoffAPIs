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
        var annotation: Int?
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
        var logo_id: Int?
    }
    
    public struct AnnotateResponse: Codable {
        var status_code: Int?
        var status: String?
        var description: String?
    }
    
    public enum Annotation: Int {
        case accept = 1
        case refuse = 0
        case skip = -1
        
        init(string: String) {
            switch string {
            case "accept":
                self = .accept
            case "refuse":
                self = .refuse
            default:
                self = .skip
            }
        }
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

class RBTFInsightsRequest : RBTFRequest {
    
/// for insights/detail/(in\_insight\_id)
    convenience init(insightId: String) {
        self.init(api: .insightsDetail)
        self.path = self.path + "/" + insightId

    }
    
    /// for filtered insights for a specific barcode
    convenience init(barcode: OFFBarcode, insightType: RBTF.InsightType?, country: String?, valueTag: String?, count: UInt?) {
        self.init(api: .insightsBarcode, barcode: barcode)
        // Are any query parameters required?
        if  insightType != nil ||
            country != nil ||
            valueTag != nil ||
            count != nil {
                        
            if let validInsightType = insightType {
                queryItems.append(URLQueryItem(name: "type", value: validInsightType.rawValue ))
            }

            if let validCountry = country {
                queryItems.append(URLQueryItem(name: "country", value: "\(validCountry)" ))
            }
            
            if let validValueTag = valueTag {
                queryItems.append(URLQueryItem(name: "value_tag", value: "\(validValueTag)" ))
            }
            
            if let validCount = count,
               validCount >= 1 {
                queryItems.append(URLQueryItem(name: "count", value: "\(validCount)" ))
            }
        }
    }
    
/// for random filtered insights
    convenience init(insightType: RBTF.InsightType?, country: String?, valueTag: String?, count: UInt?) {
        self.init(api: .insightsRandom)
        // Are any query parameters required?
        if  insightType != nil ||
            country != nil ||
            valueTag != nil ||
            count != nil {
                        
            if let validInsightType = insightType {
                queryItems.append(URLQueryItem(name: "type", value: validInsightType.rawValue ))
            }

            if let validCountry = country {
                queryItems.append(URLQueryItem(name: "country", value: "\(validCountry)" ))
            }
            
            if let validValueTag = valueTag {
                queryItems.append(URLQueryItem(name: "value_tag", value: "\(validValueTag)" ))
            }
            
            if let validCount = count,
               validCount >= 1 {
                queryItems.append(URLQueryItem(name: "count", value: "\(validCount)" ))
            }
        }
    }
    
    convenience init(insightID: String, annotation: RBTF.Annotation, username: String?, password: String?) {
        self.init(api: .insightsAnnotate)
        method = .post
        
            
        let values: [URLQueryItem] = [
            URLQueryItem(name: "insight_id", value: insightID),
            URLQueryItem(name: "annotation", value: "\(annotation.rawValue)" ),
            URLQueryItem(name: "update", value: "\(1)" ) ]

        self.body = FormBody(values)

        // should an authentication header be sent?
        if let validUsername = username,
            let validPassword = password {
            let loginString = String(format: "%@:%@", validUsername, validPassword)
            let loginData = loginString.data(using: String.Encoding.utf8)!
            let base64LoginString = loginData.base64EncodedString()
            headers["Authorization"] = "Basic " + base64LoginString
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
    func RBTFInsights(insightType: RBTF.InsightType?, country: String?, valueTag: String?, count: UInt?, completion: @escaping (_ result: Result<RBTF.InsightsResponse, RBTFError>) -> Void) {
        let request = RBTFInsightsRequest(insightType: insightType, country: country, valueTag: valueTag, count: count)
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
    func RBTFInsights(barcode: OFFBarcode, insightType: RBTF.InsightType?, country: String?, valueTag: String?, count: UInt?, completion: @escaping (_ result: Result<RBTF.InsightsResponse, RBTFError>) -> Void) {
        let request = RBTFInsightsRequest(barcode: barcode, insightType: insightType, country: country, valueTag: valueTag, count: count)
            fetch(request: request, responses: [200:RBTF.InsightsResponse.self]) { (result) in
                completion(result)
                return
            }
        }

/**
Function to retrieve the details of a specific insight

 - Parameters:
    - insightId:  the id of an insight

- returns:
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.InsightsResponse struct and for the failure an Error.
         
*/
    func RBTFInsights(insightId: String, completion: @escaping (_ result: Result<RBTF.Insight, RBTFError>) -> Void) {
        let request = RBTFInsightsRequest(insightId: insightId)
        fetch(request: request, responses: [200:RBTF.Insight.self]) { (result) in
                    completion(result)
                return
            }
        }

/**
Function to retrieve the details of a specific insight

- Parameters:
 - insightId:  the id of an insight
 - annotation: what should be done with the insight? (accept, refuse or skip)
 - username: the OFF username, if not given the annotation will be handles as an anonymous user
 - password: the OFF password

- returns:
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.AnnotateResponse struct and for the failure an Error.
*/
    func RBTFInsights(insightID: String, annotation: RBTF.Annotation, username: String?, password: String?, completion: @escaping (_ result: Result<RBTF.AnnotateResponse, RBTFError>) -> Void) {
        let request = RBTFInsightsRequest(insightID: insightID, annotation: annotation, username: username, password: password)
            fetch(request: request, responses: [200:RBTF.AnnotateResponse.self]) { (result) in
                        completion(result)
            return
        }
    }

}
