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
        case random
        
        var path: String {
            switch self {
            case .questions: return "/questions"
            case .random: return "/questions/random"
            }
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
   
/// An alternative name URLSession to make clear all usage must be related to FSNM
    typealias FSNMSession = URLSession

/**
Generic function for multiple FSNM API's. Most of these API's can return two succesfull response codes. It is assumed that all successful calls that return the data have response code 200 and the successful calls that return an error have response code 422.
*/
    func fetchRBTFArray<T:Decodable> (request: HTTPRequest, response: T.Type, completion: @escaping (_ result: ( Result<[T], RBTFError> ) ) -> Void) {
        
        load(request: request) { result in
            switch result {
            case .success(let response):
                //print("fetchArray: response: \(response.status.rawValue)")

                if response.status.rawValue == 200 {
                    OFFAPI.decodeArray(data: response.body, type: T.self) { result in
                        switch result {
                        case .success(let array):
                            completion( .success(array) )
                            return
                        case .failure:
                            if let data = response.body {
                                if let validString = String(data: data, encoding: .utf8) {
                                    if !validString.isEmpty {
                                        if validString == "null" {
                                            completion( (.failure(RBTFError.null) ))
                                        } else {
                                            completion( (.failure(RBTFError.dataType)) )
                                        }
                                    } else {
                                        completion( (.failure(RBTFError.dataType) ))
                                    }
                                }
                            }
                        }
                    }
                } else if response.status.rawValue == 422 {
                    OFFAPI.decode(data: response.body, type: RBTF.ValidationError.self) { result in
                        switch result {
                        case .success(let validationError):
                            if let validValidationError = validationError as? T {
                                completion( .failure(RBTFError.validationError(validValidationError)) )
                                return
                            } else {
                                completion( .failure(RBTFError.dataType) )
                                return
                            }
                        case .failure:
                            if let data = response.body {
                                if let validString = String(data: data, encoding: .utf8) {
                                    if !validString.isEmpty {
                                        if validString == "null" {
                                            completion( .failure(RBTFError.null) )
                                        } else {
                                            completion( .failure(RBTFError.dataType) )
                                        }
                                    } else {
                                        completion( (.failure(RBTFError.dataType) ))
                                    }
                                }
                            }
                        }
                    }
                } else if response.status.rawValue == 404 {
                    // the expected one dit not work, so try another
                    OFFAPI.decode(data: response.body, type: RBTF.Detail.self) { result in
                        switch result {
                        case .success(let detail):
                            completion( .failure(RBTFError.detail(detail)) )
                            return
                        default:
                            completion( .failure(RBTFError.dataType) )
                            return
                        }
                    }
                } else {
                    //print(response.status.rawValue)

                    if let data = response.body {
                        if let str = String(data: data, encoding: .utf8) {
                            completion( .failure(RBTFError.analyse(str)) )
                            return
                        } else {
                            completion( .failure(RBTFError.dataNil) )
                            return
                        }
                    }
                }
            case .failure(_):
                // the original response failed
                print (result.response.debugDescription)
                completion( .failure(RBTFError.connectionFailure) )
                return
            }
        }

    }

/**
Generic function for multiple FSNM API's. Most of these API's can return two succesfull response codes. It is assumed that all successful calls that return the data have response code 200 with a string as response and the successful calls that return an error have response code 422.
*/
    func fetchRBTFString (request: HTTPRequest, completion: @escaping (_ result: (Result<String, RBTFError>) ) -> Void) {
                    
        load(request: request) { result in
            switch result {
            case .success(let response):
                if response.status.rawValue == 200 {
                    //print("fetchString: response: \(response.status.rawValue)")
                    if let data = response.body {
                        let str = String(data: data, encoding: .utf8)
                        // should check what T1 is
                        if let validString = str {
                            if !validString.isEmpty {
                                if validString == "null" {
                                    completion( (.failure(RBTFError.null) ))
                                } else {
                                    completion( (Result.success(validString)) )
                                }
                            } else {
                                completion( (.failure(RBTFError.dataType) ))
                            }
                        }
                    }
                } else if response.status.rawValue == 422 {
                    //print("fetchString: response: \(response.status.rawValue)")
                    OFFAPI.decode(data: response.body, type: RBTF.ValidationError.self) { result in
                        switch result {
                        case .success(let validationError):
                            completion( (.failure(RBTFError.validationError(validationError))) )
                            return
                        case .failure:
                            // the expected one did not work, so try another
                            OFFAPI.decode(data: response.body, type: RBTF.Detail.self) { result in
                                switch result {
                                case .success(let detail):
                                    completion( .failure(RBTFError.detail(detail)) )
                                    return
                                case .failure:
                                    if let data = response.body {
                                        if let validString = String(data: data, encoding: .utf8) {
                                            if !validString.isEmpty {
                                                if validString == "null" {
                                                    completion( (.failure(RBTFError.null) ))
                                                } else {
                                                    completion( (Result.success(validString)) )
                                                }
                                            } else {
                                                completion( (.failure(RBTFError.dataType) ))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if let data = response.body {
                        //print("fetchString: response: \(response.status.rawValue)")
                        if let str = String(data: data, encoding: .utf8) {
                            completion( (.failure(RBTFError.analyse(str))) )
                            return
                        } else {
                            completion( (.failure(RBTFError.dataNil)) )
                            return
                        }
                    }
                }
            case .failure(_):
                // the original response failed
                print (result.response.debugDescription)
                completion( (.failure(RBTFError.connectionFailure)) )
                return
            }
        }

    }
    
/// Used for responses
    public func fetch<T>(request: HTTPRequest, responses: [Int : T.Type], completion: @escaping (Result<T, RBTFError>) -> Void) where T : Decodable {
        
        load(request: request) { result in
            switch result {
            case .success(let response):
                print("success :", response.status.rawValue)
                if let responsetype = responses[response.status.rawValue] {
                    OFFAPI.decode(data: response.body, type: responsetype) { result in
                        completion(result)
                        return
                    }
              //  } else if response.status.rawValue == 404 {
                    // the expected one did not work, so try another
               //     OFFAPI.decode(data: response.body, type: RBTF.Detail.self) { result in
               //         switch result {
                //        case .success(let detail):
                //            completion( .failure(RBTFError.detail(detail)) )
                //            return
                  //      default:
                  //          completion( .failure(RBTFError.dataType) )
                  //          return
                   //     }
                   // }
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
            case .failure(_):
                // the original response failed
                //print (result.response.debugDescription)
                completion( .failure( RBTFError.connectionFailure) )
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
        self.init(api: api)
        self.path = self.path + "/" + barcode.barcode.description
    }

}

// The specific errors that can be produced by the server
public enum RBTFError: Error {
    case network
    case parsing
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
    case validationError(Any)
    
    
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
        case .parsing:
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
        case .methodNotAllowed:
            return "RobotoffError: Method Not Allowed, probably a missing parameter"
        case .noBody:
            return ""
        case .notFound:
            return "RBTF:Error: API not found, probably a typo in the path"
        case .null:
            return" RBTFError: null - probably a non-existing key"
        case .unsupportedSuccessResponseType:
            return ""
        case .validationError(let detail):
            if let validationError = detail as? RBTF.ValidationError {
                if !validationError.detail.isEmpty {
                    var errorMessage = ""
                    for item in validationError.detail {
                        errorMessage += item.msg ?? "FSNMError: message nil"
                        errorMessage += "; "
                    }
                    return errorMessage
                } else {
                    return "RobotoffError: No error received"
                }
            } else {
                return "RobotoffError: Not a validation error"
            }
        }
    }
}
