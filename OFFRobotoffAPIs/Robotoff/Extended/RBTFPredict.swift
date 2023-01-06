//
//  RBTFPredictExtended.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 21/12/2022.
//

// This file is needed if the Robotoff Predict Endpoint with enumerated types and OFFBarcode type will be used. The file RBTFPredictBasic.swift is also required

import Foundation

extension RBTF {
    
// Enumeration of the possible predictors
    enum Predictors: String, CaseIterable {
        case neural = "neural"
        case matcher = "matcher"
    }

}
class RBTFPredictRequest : RBTFPredictRequestBasic {
    
    /**
     Initialiser for the Robotoff categories predict endpoint, which uses the OFFBarcode and enumerated type
     */
    convenience init(barcode: OFFBarcode,
                     deepestOnly: Bool?,
                     threshold: Double?,
                     predictors: [RBTF.Predictors]?) {
        self.init(barcode: barcode.barcode,
                  deepestOnly: deepestOnly,
                  threshold: threshold,
                  predictors: predictors?.compactMap({ $0.rawValue }) )
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

- Returns:
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.PredictResponse struct and for the failure an Error.
*/
    func RBTFPredictCategoriesProductExtended(barcode: OFFBarcode,
                                              deepestOnly: Bool?,
                                              threshold: Double?,
                                              predictors: [RBTF.Predictors]?,
                                              completion: @escaping (_ result: Result<RBTF.PredictResponse, RBTFError>) -> Void) {
        guard barcode.isCorrect else {
            completion(.failure(.barcodeInvalid))
            return
        }
        let request = RBTFPredictRequest(barcode: barcode, deepestOnly: deepestOnly, threshold: threshold, predictors: predictors)
        fetch(request: request, responses: [200:RBTF.PredictResponse.self]) { (result) in
            completion(result)
            return
        }
    }

}
