//
//  RBTFPredict.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 14/12/2022.
//

import Foundation

extension RBTF {
    
    /**
     The datastructure retrieved for a reponse 200 for the Questions Product API and Questions Random API
     
     **Variables:**
     - responseStatus: the *QuestionsResponseStatus* of the response:
     - questions: an array of *Question*
     - count: the number of questions
     */
    public struct PredictResponse: Codable {
        var neural: [NeuralResponse]?
        var matcher: [MatcherResponse]?
    }
    
    public struct NeuralResponse: Codable {
        var value_tag: String?
        var confidence: Float?
    }
    
    public struct MatcherResponse: Codable {
        var value_tag: String?
        var debug: MatcherDebug?
    }

    public struct MatcherDebug: Codable {
        var pattern: String?
        var lang: String?
        var product_name: String?
        var processed_product_name: String?
        var category_name: String?
        var start_idx: Int?
        var end_idx: Int?
        var is_full_match: Bool?
    }
    
    enum Predictors: String, CaseIterable {
        case neural = "neural"
        case matcher = "matcher"
    }
    
    public struct PredictRequestBody: Codable {
        var barcode: String = ""
        var deepest_only: Bool = true
        var threshold: Double = 0.5
        var predictors: [String] = ["neural", "matcher"]
    }
}

class RBTFPredictRequest : RBTFRequest {
    
    /// for predit  fetch
    convenience init(barcode: OFFBarcode, deepestOnly: Bool?, threshold: Double?, predictors: [RBTF.Predictors]?) {
        self.init(api: .predict)
        method = .post
        
        var requestBody = RBTF.PredictRequestBody()

        requestBody.barcode = barcode.barcode

            
        if let validThreshold = threshold {
            requestBody.threshold = validThreshold
        }
            
        if let validDeepestOnly = deepestOnly {
            requestBody.deepest_only = validDeepestOnly
        }
        
        if let validPredictors = predictors {
            requestBody.predictors = validPredictors.compactMap({ $0.rawValue })
        }

        self.body = JSONBody(requestBody)
    }

}

extension URLSession {
    
/**
Function to predict categories for a product

 - Parameters:
    - barcode: The barcode of the product to categorize
    - deepestOnly:  If true, only return the deepest elements in the category taxonomy (don't return categories that are parents of other predicted categories)
    - threshold: Default: 0.5; The score above which we consider the category to be detected
    - predictors: Array of strings;  Items Enum: "neural" "matcher"; List of predictors to use, possible values are matcher (simple matching algorithm) and neural (neural network categorizer)

 - returns:
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.PredictResponse struct and for the failure an Error.
*/
    func RBTFPredictCategoriesProduct(barcode: OFFBarcode, deepestOnly: Bool?, threshold: Double?, predictors: [RBTF.Predictors]?, completion: @escaping (_ result: Result<RBTF.PredictResponse, RBTFError>) -> Void) {
        let request = RBTFPredictRequest(barcode: barcode, deepestOnly: deepestOnly, threshold: threshold, predictors: predictors)
        fetch(request: request, responses: [200:RBTF.PredictResponse.self]) { (result) in
            completion(result)
            return
        }
    }

}
