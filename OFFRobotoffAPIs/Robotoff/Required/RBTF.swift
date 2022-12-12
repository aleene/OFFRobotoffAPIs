//
//  FSNMAPI.swift
//  OFFRobotoffSAPIs
//
//  Created by Arnaud Leene on 21/10/2022.
//

import Foundation

struct RBTF {

/** all possible Robotoff API's
 */
    enum APIs {
        case questions
        case questionsRandom
        case questionsPopular
        case questionsUnanswered
        case insightsBarcode
        case insightsDetail
        case insightsRandom
        case logos
        
        var path: String {
            switch self {
            case .questions: return "/questions"
            case .questionsRandom: return "/questions/random"
            case .questionsPopular: return "/questions/popular"
            case .questionsUnanswered: return "/questions/unanswered"
            case .insightsDetail: return "/insights/detail" // yje insights id must be added
            case .insightsRandom: return "/insights/random"
            case .insightsBarcode: return "/insights" // the barcode must be addded
            case .logos: return "/images/logos"
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
                            completion(.failure( RBTFError.dataType) )
                            return
                        }
                    } else {
                        completion(.failure( RBTFError.noBody) )
                        return
                    // unsupported response type
                    }
                }
            case .failure(let error):
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

extension HTTPRequest {
    
/**
Init for all producttypes supported by OFF. This will setup the correct host and path of the API URL
 
 - Parameters:
    - productType: one of the productTypes (.food, .beauty, .petFood, .product);
    - api: the api required (i.e. .auth, .ping, etc)
*/
    init(for productType: OFFProductType, for api: RBTF.APIs) {
        self.init()
        self.host = "robotoff." + productType.host + ".org"
        self.path = "/api/v1" + api.path
    }
    
/**
 Init for the food folksonomy API. This will setup the correct host and path of the API URL
  
- Parameters:
 - api: the api required (i.e. .auth, .ping, etc)
 */
    init(api: RBTF.APIs) {
        self.init(for: .food, for: api)
    }
    
    init(api: RBTF.APIs, barcode: OFFBarcode) {
        guard api == .questions ||
                api == .insightsBarcode else { fatalError("HTTPRequest:init(api:barcode:): unallowed RBTF.API specified") }
        self.init(api: api)
        self.path = self.path + "/" + barcode.barcode.description
    }

    init(api: RBTF.APIs, barcode: OFFBarcode, count: Int?, lang: String?) {
        self.init(api: api)
        self.path = self.path + "/" + barcode.barcode.description
        if count != nil || lang != nil {
            var queryItems: [URLQueryItem] = []
            
            if let validCount = count {
                queryItems.append(URLQueryItem(name: "count", value: "\(validCount)" ))
            }
            if let validLang = lang,
               validLang.count == 3,
               validLang.hasSuffix(":") {
                queryItems.append(URLQueryItem(name: "lang", value: validLang ))
            }
        }
    }
    
    init(count: UInt?, insightType: RBTF.InsightType?, country: String?, page: UInt?) {
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

    init(api: RBTF.APIs, languageCode: String?, count: UInt?, insightTypes: [RBTF.InsightType], country: String?, brands: [String], valueTag: String?, page: UInt?) {
        self.init(api: api)
        // Are any query parameters required?
        if count != nil ||
            languageCode != nil ||
            !insightTypes.isEmpty ||
            country != nil ||
            !brands.isEmpty ||
            valueTag != nil ||
            page != nil {
            
            if let validLang = languageCode,
               validLang.count == 3,
               validLang.hasSuffix(":") {
                queryItems.append(URLQueryItem(name: "lang", value: validLang ))
            }
            
            if let validCount = count,
               validCount >= 1 {
                queryItems.append(URLQueryItem(name: "count", value: "\(validCount)" ))
            }
            
            if !insightTypes.isEmpty {
                let insights = insightTypes.map({ $0.rawValue }).joined(separator: ",")
                queryItems.append(URLQueryItem(name: "insight_types", value: "\(insights)" ))
            }
            
            if let validCountry = country {
                queryItems.append(URLQueryItem(name: "country", value: "\(validCountry)" ))
            }
            
            if !brands.isEmpty {
                let brandsString = brands.joined(separator: ",")
                queryItems.append(URLQueryItem(name: "brands", value: "\(brandsString)" ))
            }
            
            if let validValueTag = valueTag {
                queryItems.append(URLQueryItem(name: "value_tag", value: "\(validValueTag)" ))
            }
            
            if let validPage = page,
               validPage >= 1 {
                queryItems.append(URLQueryItem(name: "page", value: "\(validPage)" ))
            }
        }
    }
    
    /// for insight/random
    init(insightType: RBTF.InsightType?, country: String?, valueTag: String?, count: UInt?) {
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
    
    /// for insight/random
    init(barcode: OFFBarcode, insightType: RBTF.InsightType?, country: String?, valueTag: String?, count: UInt?) {
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
    
    /// for insights/detail/(in\_insight\_id)
    init(insightId: String) {
        self.init(api: .insightsDetail)
        self.path = self.path + "/" + insightId

    }

    
    /// for logos detail fetch
    init(logoIds: String) {
        self.init(api: .logos)
        
        queryItems.append(URLQueryItem(name: "logo_ids", value: logoIds ))

    }
    
    /// for logos detail fetch
    init(count: UInt?, type: String?, barcode: OFFBarcode?, value: String?, taxonomy_value: String?, min_confidence: Int?, random: Bool?, annotated: Bool?) {
        self.init(api: .logos)
        
        if let validCount = count {
            queryItems.append(URLQueryItem(name: "count", value: "\(validCount)" ))
        }

        if let validType = type {
            queryItems.append(URLQueryItem(name: "type", value: "\(validType)" ))
        }
            
        if let validBarcode = barcode {
            queryItems.append(URLQueryItem(name: "barcode", value: "\(validBarcode.barcode)" ))
        }
            
        if let validValue = value {
            queryItems.append(URLQueryItem(name: "value", value: "\(validValue)" ))
        }
            
        if let validTaxonomy_value = taxonomy_value {
            queryItems.append(URLQueryItem(name: "value", value: "\(validTaxonomy_value)" ))
        }
            
        if let validMin_confidence = min_confidence {
            queryItems.append(URLQueryItem(name: "value", value: "\(validMin_confidence)" ))
        }
            
        if let validRandom = random {
            let value = validRandom ? "true" : "false"
            queryItems.append(URLQueryItem(name: "value", value: "\(value)" ))
        }
            
        if let validAnnotated = annotated {
            let value = validAnnotated ? "true" : "false"
            queryItems.append(URLQueryItem(name: "annotated", value: "\(value)" ))
        }
    }


}

// The specific errors that can be produced by the server
public enum RBTFError: Error {
    case network
    case dataCorrupted(DecodingError.Context)
    case keyNotFound(CodingKey, DecodingError.Context)
    case typeMismatch(Any.Type, DecodingError.Context)
    case valueNotFound(Any.Type, DecodingError.Context)
    case missingParameter(String)
    case insightUnknown // used if the insight detail responds with a 404
    case request
    case connectionFailure
    case dataNil
    case dataType
    case detail(Any) // if a 404 Detail struct is received
    case authenticationRequired
    case methodNotAllowed
    case noBody
    case notFound
    case null
    case unsupportedSuccessResponseType
    
    
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
        case .network:
            return ""
        case .request:
            return ""
        case .authenticationRequired:
            return "RobotoffError: Authentication Required. Log in before using this function"
        case .connectionFailure:
            return "RobotoffError: Not able to connect to the Folksonomy server"
        case .dataNil:
            return ""
        case .dataType:
            return "RobotoffError: unexpected datatype"
        case .detail(let detail):
            if let validDetail = detail as? RBTF.Detail,
               let valid = validDetail.detail {
                    return valid
            } else {
                return "RobotoffError: Wrong detail struct or nil value"
            }
        case .insightUnknown:
            return "RobotoffError: insightID unknown"
        case .methodNotAllowed:
            return "RobotoffError: Method Not Allowed, probably a missing parameter"
        case .missingParameter(let parameter):
            return "RobotoffError: \(parameter)"
        case .noBody:
            return ""
        case .notFound:
            return "RBTF:Error: API not found, probably a typo in the path"
        case .null:
            return" RBTFError: null - probably a non-existing key"
        case .unsupportedSuccessResponseType:
            return ""
        case .dataCorrupted(let context):
            return "decode " + context.debugDescription
        case .keyNotFound(let key, let context):
            return "Key '\(key)' not found: \(context.debugDescription) codingPath:  \(context.codingPath)"
        case .typeMismatch(let value, let context):
            return "Value '\(value)' not found \(context.debugDescription) codingPath: \(context.codingPath)"
        case .valueNotFound(let type, let context):
            return "Type '\(type)' mismatch: \(context.debugDescription) codingPath:  \(context.codingPath)"
        }
    }
}
