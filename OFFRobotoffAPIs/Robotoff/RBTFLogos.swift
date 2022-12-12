//
//  RBTFLogos.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 09/12/2022.
//

import Foundation

extension RBTF {
    
    public struct LogosResponse: Codable {
        var logos: [Logo]?
        var count: Int?
    }
    
    public struct Logo: Codable {
        var id: Int?
        var index: Int?
        var bounding_box: [Double]?
        var score: Double?
        var annotation_value: String?
        var annotation_value_tag: String?
        var taxonomy_value: String?
        var annotation_type: String?
        var username: String?
        var completed_at: String?
        var nearest_neighbours: String?
        var image: LogoImage?
    }
    
    public struct LogoImage: Codable {
        var id: Int?
        var barcode: String?
        var uploaded_at: String?
        var imaged_id: String?
        var source_image: String?
        var width: Int?
        var height: Int?
        var deleted: Bool?
        var server_domain: String?
        var server_type: String?
    }
}

extension URLSession {

/**
Function to get the details for a specific logo

 - Parameters:
    - logoIds: Comma-separated string of logo IDs
     
- returns:
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.LogosResponse struct and for the failure an Error.
         
*/
    func RBTFLogos(logoIds: String, completion: @escaping (_ result: Result<RBTF.LogosResponse, RBTFError>) -> Void) {
        let request = HTTPRequest(logoIds: logoIds)
                fetch(request: request, responses: [200:RBTF.LogosResponse.self]) { (result) in
                    completion(result)
                    return
                }
            }

    /**
     
Function to get a list of logos with details

- Parameters:
     - count: Number of results to return (default 25);
     - type: Filter by logo type (example: **type=packager_code**);
     - barcode: Filter by barcode;
     - value: Filter by annotated value (example: **value=lidl**);
     - taxonomy_value: Filter by taxonomy value, i.e. the canonical value present is the associated taxonomy. This parameter is mutually exclusive with value, and should be used for label type (example: **taxonomy_value=en:organic**);.
     - min_confidence: Filter logos that have a confidence score above a threshold;
     - random: If true, randomized result order (default false);
     - annotated: The annotation status of the logo. If not provided, both annotated and non-annotated logos are returned (default nil)
         
- returns:
A completion block with a Result enum (success or failure). The associated value for success is a RBTF.LogosResponse struct and for the failure an Error.
             
*/
        func RBTFLogos(count: UInt?, type: String?, barcode: OFFBarcode?, value: String?, taxonomy_value: String?, min_confidence: Int?, random: Bool?, annotated: Bool?, completion: @escaping (_ result: Result<RBTF.LogosResponse, RBTFError>) -> Void) {
            let request = HTTPRequest(count: count, type: type, barcode: barcode, value: value, taxonomy_value: taxonomy_value, min_confidence: min_confidence, random: random, annotated: annotated)
                    fetch(request: request, responses: [200:RBTF.LogosResponse.self]) { (result) in
                        completion(result)
                        return
                    }
                }


}
