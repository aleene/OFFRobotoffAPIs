//
//  RBTFQuestionsExtensions.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 20/12/2022.
//

// Convenience extensions that use the class OFFBarcode and enum Language. This uses the taxonomy defined by OFF.

import Foundation

class RBTFQuestionsExtensionsRequest: RBTFQuestionsRequest {
    
    convenience init(barcode: OFFBarcode,
                     count: UInt?, lang:
                     ISO693_1?) {
        self.init(barcode: barcode.barcode, count: count, lang: lang?.rawValue)
    }
    
    convenience init(api: RBTF.APIs, language: ISO693_1?, count:  UInt?, insightTypes: [RBTF.InsightType], country: Country?, brands: [String], valueTag: String?, page: UInt?) {
        self.init(api: api,
                  languageCode: language?.rawValue ?? nil,
                  count: count,
                  insightTypes: insightTypes,
                  country: country?.key ?? nil,
                  brands: brands,
                  valueTag: valueTag,
                  page: page)
    }

}

extension URLSession {
    
    /**
     Function which retrieves the possible questions for a specific product.
     
     - Parameters:
     - offbarcode: the OFFBarcode for the product;
     - count: the  maximum numer of questions to be retrived for this product. If not specified the value is **1**;
     - lang: the Language  for the question and possible answer. If not specified .english is assumed;
     
     - returns:
     A completion block with a Result enum (success or failure). The associated value for success is a RBTF.QuestionsResponse struct and for the failure an Error.
     */
    func RBTFQuestionsProduct(with barcode: OFFBarcode,
                              count: UInt?,
                              lang: ISO693_1?,
                              completion: @escaping (_ result: Result<RBTF.QuestionsResponse, RBTFError>) -> Void) {
        guard barcode.isCorrect else {
            completion(.failure(.barcodeEmpty))
            return
        }
        let request = RBTFQuestionsExtensionsRequest(barcode: barcode, count: count, lang: lang)
        fetch(request: request, responses: [200:RBTF.QuestionsResponse.self]) { (result) in
            completion(result)
            return
        }
    }
    
    /**
    Function to retrieve a random product wth a question with a list of query parameters to filter the questions

     - Parameters:
        - language: the Language of the question/value
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
        func RBTFQuestionsRandom(language: ISO693_1?, count: UInt?, insightTypes: [RBTF.InsightType], country: Country?, brands: [String], valueTag: String?, page: UInt?, completion: @escaping (_ result: Result<RBTF.QuestionsResponse, RBTFError>) -> Void) {
            let request = RBTFQuestionsExtensionsRequest(api: .questionsRandom, language: language, count: count, insightTypes: insightTypes, country: country, brands: brands, valueTag: valueTag, page: page)
            fetch(request: request, responses: [200:RBTF.QuestionsResponse.self]) { (result) in
                completion(result)
                return
            }
        }

}
