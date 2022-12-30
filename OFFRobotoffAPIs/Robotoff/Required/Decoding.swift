 //
//  OpenFoodFactsRequest.swift
//  FoodViewer
//
//  Created by arnaud on 03/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

// Extensions to help decoding received jsons.
// The files are required, but depend on the endpoint used

import Foundation

public class Decoding {
    
/**
Generic function to decode a json struct
 
 - Parameters:
    - data: the data which contains the json
    - type: the type that is expected
    - completion: a Result enum with either the json as type or a decoding error
 
 */
    public static func decode<T:Decodable>(data: Data,
                                           type: T.Type,
                                           completion: @escaping (_ result: Result<T, DecodingError>) -> Void)  {
        do {
            if let validString = String(data: data, encoding: .utf8) {
                print(validString)
            }

            let decoded = try JSONDecoder().decode(type.self, from: data)
            completion(Result.success(decoded))

        }  catch let DecodingError.dataCorrupted(context) {
            print("decode " + context.debugDescription)
            completion(Result.failure(DecodingError.dataCorrupted(context)))

        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            completion(Result.failure(DecodingError.keyNotFound(key, context)))

        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            completion(Result.failure(DecodingError.valueNotFound(value, context)))

        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            completion(Result.failure(DecodingError.typeMismatch(type, context)))

        } catch let error {
            print("error: ", error)
            completion(Result.failure(error as! DecodingError))
        }
        return
    }

/**
Generic function to decode a json array containing elements of type
     
- Parameters:
 - data: the data which contains the json
 - type: the type that is expected
 - completion: a Result enum with either the json as type or a decoding error
     
     */
    public static func decodeArray<T:Decodable>(data: Data, type: T.Type, completion: @escaping (_ result: Result<[T], DecodingError>) -> Void)  {
        do {
            let decoded = try JSONDecoder().decode([T].self, from: data)
                completion(Result.success(decoded))
        }  catch let DecodingError.dataCorrupted(context) {
            print("decode " + context.debugDescription)
            completion(Result.failure(DecodingError.dataCorrupted(context)))

        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            completion(Result.failure(DecodingError.keyNotFound(key, context)))

        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            completion(Result.failure(DecodingError.valueNotFound(value, context)))

        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            completion(Result.failure(DecodingError.typeMismatch(type, context)))

        } catch let error {
            print("error: ", error)
            completion(Result.failure(error as! DecodingError))
        }
        return
    }

}
