//
//  FSNMAPI.swift
//  OFFRobotoffSAPIs
//
//  Created by Arnaud Leene on 21/10/2022.
//

// This file contains the code that is required by multiple API's

import Foundation

struct RBTF {

/** all possible Robotoff API's
 */
    enum APIs {
        case predict
        case insightsAnnotate
        case insightsBarcode
        case insightsDetail
        case insightsRandom
        case logos
        case questions
        case questionsPopular
        case questionsRandom
        case questionsUnanswered
        
        var path: String {
            switch self {
            case .questions: return "/questions"
            case .questionsRandom: return "/questions/random"
            case .questionsPopular: return "/questions/popular"
            case .questionsUnanswered: return "/questions/unanswered"
            case .insightsAnnotate: return "/insights/annotate"
            case .insightsDetail: return "/insights/detail" // the insight id must be added
            case .insightsRandom: return "/insights/random"
            case .insightsBarcode: return "/insights" // the barcode must be addded
            case .logos: return "/images/logos"
            case .predict: return "/predict/category"
            }
        }
    }
    
    /**
    The insight type, i.e. the subject the question is about.
      - case **brand**: extracts the product's brand from the image OCR.
      - case **category**: predicts the category of a product.
      - case **expirationDate**: extracts the expiration date from the image OCR.
      - case **imageOrientation**: predicts the image orientation of the given image.
      - case **ingredientSpellcheck**: corrects the spelling in the given ingredients list.
      - case **imageFlag**: flags inappropriate images based on OCR text.
      - case **imageLang**: detects which languages are mentioned on the product from the image OCR.
      - case **label**: predicts a label that appears on the product packaging photo.
      - case **location**: the location of where the product comes from from the image OCR.
      - case **nutrient**: the list of nutrients mentioned in a product, alongside their numeric value from the image OCR.
      - case **nutrientMention**: mentions of nutrients from the image OCR (without actual values).
      - case **nutritionImage**: tags images that have nutrition information based on the 'nutrient_mention' insight and the 'image_orientation' insight.
      - case **nutritionTableStructure**: detects the nutritional table structure from the image.
      - case **packaging**: detects the type of packaging based on the image OCR.
      - case **productWeight**: extracts the product weight from the image OCR.
      - case **store**: the store where the given product is sold from the image OCR.
      - case **trace**: detects traces that are present in the product from the image OCR.
    - case **unknown** if something unforeseen happened;
    */
        enum InsightType: String, CaseIterable {
            case brand = "brand"
            case category = "category"
            case expirationDate = "expiration_date"
            case imageFlag = "image_flag"
            case imageLang = "image_lang"
            case imageOrientation = "image_orientation"
            case ingredientSpellcheck = "ingredient_spellcheck"
            case label = "label"
            case location = "location"
            case nutrient = "nutrient"
            case nutrientMention = "nutrient_mention"
            case nutritionImage = "nutrition_image"
            case nutritionTableStructure = "nutrition_table_structure"
            case packaging = "packaging"
            case productWeight = "product_weight"
            case store = "store"
            case trace = "trace"
            case unknown = "unknown"
            
            /// Function that converts a string to a InsightType case. These strings are used in the json responses.
            static func value(for string: String?) -> InsightType {
                guard let validString = string else { return .unknown }
                for item in InsightType.allCases {
                    if item.rawValue == validString {
                        return item
                    }
                }
                return .unknown
            }

        }

/**
    Some API's (ProductStats) can return a validation error with response code 401.
*/
    public struct Error401: Codable {
        var detail: String?
    }
    
    public struct Detail: Codable {
        var detail: String?
    }

    public struct Error400: Codable {
        var title: String?
        var description: String?
    }
/**
 Some API's (ProductStats) can return a validation error with response code 422.
 */
    public struct ValidationError: Codable {
        var detail: [ValidationErrorDetail] = []
    }
    
    public struct ValidationErrorDetail: Codable {
        var loc: [String] = []
        var msg: String?
        var type: String?
    }
}

extension URLSession {

/// Used for responses
    public func fetch<T>(request: HTTPRequest, responses: [Int : T.Type], completion: @escaping (Result<T, RBTFError>) -> Void) where T : Decodable {
        
        load(request: request) { result in
            switch result {
            case .success(let response):
                print("success :", response.response.statusCode)
                if let responsetype = responses[response.status.rawValue],
                   let data = response.body {
                    Decoding.decode(data: data, type: responsetype) { result in
                        switch result {
                        case .success(let gelukt):
                            completion(.success(gelukt))
                        case .failure(let decodingError):
                            switch decodingError {
                            case .dataCorrupted(let context):
                                completion(.failure(.dataCorrupted(context)))
                            case .keyNotFound(let key, let context):
                                completion(.failure(.keyNotFound(key, context)))
                            case .typeMismatch(let type, let context):
                                completion(.failure(.typeMismatch(type, context)))
                            case .valueNotFound(let type, let context):
                                completion(.failure(.valueNotFound(type, context)))
                            @unknown default:
                                completion(.failure(.unsupportedSuccessResponseType))
                            }
                        }
                        return
                    }
                } else if response.response.statusCode == 400 {
                    if let data = response.body {
                        Decoding.decode(data: data, type: RBTF.Error400.self) { result in
                            switch result {
                            case .success(let gelukt):
                                completion(.failure(.missingParameter(gelukt.description ?? "no description received")))
                            case .failure(let decodingError):
                                switch decodingError {
                                case .dataCorrupted(let context):
                                    completion(.failure(.dataCorrupted(context)))
                                case .keyNotFound(let key, let context):
                                    completion(.failure(.keyNotFound(key, context)))
                                case .typeMismatch(let type, let context):
                                    completion(.failure(.typeMismatch(type, context)))
                                case .valueNotFound(let type, let context):
                                    completion(.failure(.valueNotFound(type, context)))
                                @unknown default:
                                    completion(.failure(.unsupportedSuccessResponseType))
                                }
                            }
                            return
                        }
                    }
                } else {
                    if let data = response.body {
                        print("failure: ", response.status.rawValue)

                        if let str = String(data: data, encoding: .utf8) {
                            completion( .failure(RBTFError.analyse(str)) )
                            return
                        } else {
                            completion(.failure( RBTFError.errorAnalysis) )
                            return
                        }
                    } else {
                        completion(.failure( RBTFError.noBody) )
                        return
                    }
                }
            case .failure(let error):
                print("error code: \(error.code)")
                switch error.code  {
                case .invalidRequest:
                    completion(.failure(.insightUnknown))
                default:
                    completion( .failure( .connectionFailure) )
                }
                    // the original response failed
                    //print (result.response.debugDescription)
                return
            }
        }
    }

}

class RBTFRequest: HTTPRequest {
    
/**
Init for all producttypes supported by OFF. This will setup the correct host and path of the API URL
 
 - Parameters:
    - productType: one of the productTypes (.food, .beauty, .petFood, .product);
    - api: the api required (i.e. .auth, .ping, etc)
*/
    convenience init(for productType: OFFProductType, for api: RBTF.APIs) {
        self.init()
        self.host = "robotoff." + productType.host + ".org"
        self.path = "/api/v1" + api.path
    }
    
/**
 Init for the food robotoff API. This will setup the correct host and path of the API URL
  
- Parameters:
 - api: the api required (i.e. .auth, .ping, etc)
 */
    convenience init(api: RBTF.APIs) {
        self.init(for: .food, for: api)
    }
    
    convenience init(api: RBTF.APIs, barcode: OFFBarcode) {
        guard api == .questions ||
            api == .insightsBarcode ||
            api == .predict
            else { fatalError("HTTPRequest:init(api:barcode:): unallowed RBTF.API specified") }
        self.init(api: api)
        self.path = self.path + "/" + barcode.barcode.description
    }

    convenience init(api: RBTF.APIs, barcode: String) {
        guard api == .questions ||
            api == .insightsBarcode ||
            api == .predict
            else { fatalError("HTTPRequest:init(api:barcode:): unallowed RBTF.API specified") }
        self.init(api: api)
        self.path = self.path + "/" + barcode.description
    }

}

// The specific errors that can be produced by the server
public enum RBTFError: Error {
    case authenticationRequired
    case barcodeInvalid
    case connectionFailure
    case dataCorrupted(DecodingError.Context)
    //case detail(Any) // if a 404 Detail struct is received
    case errorAnalysis
    case insightUnknown // used if the insight detail responds with a 404
    case keyNotFound(CodingKey, DecodingError.Context)
    case methodNotAllowed
    case missingParameter(String)
    case noBody
    //case notFound
   // case null
    case typeMismatch(Any.Type, DecodingError.Context)
    case unsupportedSuccessResponseType
    case valueNotFound(Any.Type, DecodingError.Context)

    
    static func analyse(_ message: String) -> RBTFError {
        if message.contains("Not Found") {
            return .connectionFailure
        } else if message.contains("Method Not Allowed") {
            return .methodNotAllowed
        } else if message.contains("Authentication required") {
            return .authenticationRequired
        } else {
            return .unsupportedSuccessResponseType
        }
    }
    public var description: String {
        switch self {
        case .authenticationRequired:
            return "RobotoffError: Authentication Required. Log in before using this function"
        case .barcodeInvalid:
            return "RobotoffError: A valid barcode is required (length 8, 12 or 13)"
        case .connectionFailure:
            return "RobotoffError: Not able to connect to the Folksonomy server"
        case .errorAnalysis:
            return "RobotoffError: unexpected error in error json"
        //case .detail(let detail):
        //    if let validDetail = detail as? RBTF.Detail,
        //       let valid = validDetail.detail {
        //            return valid
         //   } else {
         //       return "RobotoffError: Wrong detail struct or nil value"
        //    }
        case .insightUnknown:
            return "RobotoffError: insightID unknown"
        case .methodNotAllowed:
            return "RobotoffError: Method Not Allowed, probably a missing parameter"
        case .missingParameter(let parameter):
            return "RobotoffError: \(parameter)"
        case .noBody:
            return ""
        //case .notFound:
        //    return "RobotoffError: API not found, probably a typo in the path"
        //case .null:
        //    return" RobotoffError: null - probably a non-existing key"
        case .unsupportedSuccessResponseType:
            return ""
        case .dataCorrupted(let context):
            return "RobotoffError:decode " + context.debugDescription
        case .keyNotFound(let key, let context):
            return "RobotoffError:Key '\(key)' not found: \(context.debugDescription) codingPath:  \(context.codingPath)"
        case .typeMismatch(let value, let context):
            return "RobotoffError:Value '\(value)' not found \(context.debugDescription) codingPath: \(context.codingPath)"
        case .valueNotFound(let type, let context):
            return "RobotoffError:Type '\(type)' mismatch: \(context.debugDescription) codingPath:  \(context.codingPath)"
        }
    }
}
