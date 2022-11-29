 //
//  OpenFoodFactsRequest.swift
//  FoodViewer
//
//  Created by arnaud on 03/02/16.
//  Copyright © 2016 Hovering Above. All rights reserved.
//

import Foundation

public class OFFAPI {
    
/// Generic function to decode a json struct
    public static func decode<T:Decodable>(data: Data?, type: T.Type, completion: @escaping (_ result: Result<T, RBTFError>) -> Void)  {
        do {
            if let responseData = data {
                if let validString = String(data: responseData, encoding: .utf8) {
                    print(validString)
                }

                let decoded = try JSONDecoder().decode(type.self, from: responseData)
                completion(Result.success(decoded))
                return
            } else {
                completion(Result.failure(RBTFError.dataNil))
                return
            }
        }  catch let DecodingError.dataCorrupted(context) {
            print("decode " + context.debugDescription)
            completion(Result.failure(RBTFError.parsing(context.debugDescription)))
            return

        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            completion(Result.failure(RBTFError.parsing(context.debugDescription)))

        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            completion(Result.failure(RBTFError.parsing(context.debugDescription)))

        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            completion(Result.failure(RBTFError.parsing(context.debugDescription)))

        } catch {
            print("error: ", error)
            completion(Result.failure(RBTFError.parsing(error.localizedDescription)))
        }
        return
    }

/// Generic function to decode a json array
    public static func decodeArray<T:Decodable>(data: Data?, type: T.Type, completion: @escaping (_ result: Result<[T], RBTFError>) -> Void)  {
        do {
            if let responseData = data {
                let decoded = try JSONDecoder().decode([T].self, from: responseData)
                completion(Result.success(decoded))
                return
            } else {
                completion(Result.failure(RBTFError.dataNil))
                return
            }
        }  catch let DecodingError.dataCorrupted(context) {
            print("decode " + context.debugDescription)
            completion(Result.failure(RBTFError.parsing(context.debugDescription)))
            return

        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            completion(Result.failure(RBTFError.parsing(context.debugDescription)))

        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            completion(Result.failure(RBTFError.parsing(context.debugDescription)))

        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            completion(Result.failure(RBTFError.parsing(context.debugDescription)))
        } catch {
            print("error: ", error)
            completion(Result.failure(RBTFError.parsing(error.localizedDescription)))
        }
        return
    }

}
