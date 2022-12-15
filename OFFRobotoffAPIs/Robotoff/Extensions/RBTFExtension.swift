//
//  RBTFExtension.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 26/11/2022.
//

import Foundation
import Collections

extension RBTF.Question {
        
    // We like to keep the presentation order of the elements in RBTF.Question as it maps to the Swagger documentation
    var dict: OrderedDictionary<String, String> {
        var temp: OrderedDictionary<String, String> = [:]
        temp["barcode"] = barcode ?? "nil"
        temp["type"] = questionType.rawValue
        temp["value"] = value ?? "nil"
        temp["question"] = question ?? "nil"
        temp["insight_id"] = insight_id ?? "nil"
        temp["insight_type"] = insightType.rawValue
        temp["value_tag"] = value_tag ?? "nil"
        temp["source_image_url"] = source_image_url ?? "nil"
        return temp
    }

}

extension RBTF.Insight {
    
    // We like to keep the presentation order of the elements in RBTF.Insight as it maps to the OpenAPI documentation
    var dict: OrderedDictionary<String, String> {
           
        var langConfidence: String {
            guard let dataLang = data!.lang else { return "nil" }
            guard let dataConfidence = data!.confidence else { return "nil" }
            return dataLang + " " + "\(dataConfidence)"
        }
        var temp: OrderedDictionary<String, String> = [:]
        temp["id"] = id ?? "nil"
        temp["type"] = insightType.rawValue
        temp["barcode"] = offBarcode.debugDescription
        temp["data"] =  data != nil ? langConfidence : "nil"
        temp["timestamp"] =  timestamp ?? "nil"
        temp["completed_at"] = completed_at ?? "nil"
        temp["annotation"] = annotation != nil ? "\(annotation!)" : "nil"
        temp["annotated_result"] = annotated_result ?? "nil"
        temp["n_votes"] = n_votes != nil ? "\(n_votes!)" : "nil"
        temp["username"] = username ?? "nil"
        temp["countries"] = countriesCombined
        temp["brands"] = brandsCombined
        temp["process_after"] = process_after ?? "nil"
        temp["value_tag"] = value_tag ?? "nil"
        temp["value"] = value ?? "nil"
        temp["source_image"] = source_image ?? "nil"
        temp["automatic_processing"] = automatic_processing != nil ? automatic_processing!.description : "nil"
        temp["server_domain"] = server_domain ?? "nil"
        temp["server_type"] = server_type ?? "nil"
        temp["unique_scans_n"] = unique_scans_n != nil ? "\(unique_scans_n!)" : "nil"
        temp["reserved_barcode"] = reserved_barcode != nil ? (reserved_barcode! ? "true" : "false" ) : "nil"
        temp["predictor"] = predictor ?? "nil"
        temp["campaign"] = campaignCombined

        return temp
    }

}

extension RBTF.Logo {
    
    var dict: OrderedDictionary<String, String> {
        var temp: OrderedDictionary<String, String> = [:]
        temp["id"] = id != nil ? "\(id!)" : "nil"
        temp["index"] = index != nil ? "\(index!)" : "nil"
        temp["bounding_box"] = bounding_box != nil ? "\(bounding_box![0])" + ", " + "\(bounding_box![1])" + ", " + "\(bounding_box![2])" + ", " + "\(bounding_box![3])" : "nil"
        temp["score"] = score != nil ? "\(score!)" : "nil"
        temp["annotation_value"] = annotation_value ?? "nil"
        temp["annotation_value_tag"] = annotation_value_tag ?? "nil"
        temp["taxonomy_value"] = taxonomy_value ?? "nil"
        temp["annotation_type"] = annotation_type ?? "nil"
        temp["username"] = username ?? "nil"
        temp["completed_at"] = completed_at ?? "nil"
        temp["nearest_neighbours"] = nearest_neighbours ?? "nil"
        
        temp = temp.merging(image?.dict.newKey(prefix: "image:") ?? [:]) { $1 }
        return temp
    }
    
}

extension RBTF.LogoImage {
    
    var dict: OrderedDictionary<String, String> {
        var temp: OrderedDictionary<String, String> = [:]
        // can I make this to a separate dict and add it? Yes we could
        temp["id"] = id != nil ? "\(id!)" : "nil"
        temp["barcode"] = barcode ?? "nil"
        temp["uploaded_at"] = uploaded_at ?? "nil"
        temp["imaged_id"] = imaged_id ?? "nil"
        temp["source_image"] = source_image ?? "nil"
        temp["width"] = width != nil ? "\(width!)" : "nil"
        temp["height"] = height != nil ? "\(height!)" : "nil"
        temp["deleted"] = deleted != nil ? (deleted! ? "true" : "false" ) : "nil"
        temp["server_domain"] = server_domain ?? "nil"
        temp["server_type"] = server_type ?? "nil"
        
        return temp
    }

}

extension RBTF.PredictResponse {
    
    var dict: OrderedDictionary<String, String> {
        var temp: OrderedDictionary<String, String> = [:]
        
        temp = temp.merging(neural?.dict.newKey(prefix: "neural:") ?? [:]) { $1 }
        temp = temp.merging(matcher?.dict.newKey(prefix: "matcher:") ?? [:]) { $1 }
        return temp
    }
    
}

extension RBTF.NeuralResponse {
    var dict: OrderedDictionary<String, String> {
        var temp: OrderedDictionary<String, String> = [:]
        temp["value_tag"] = value_tag ?? "nil"
        temp["confidence"] = confidence != nil ? "\(confidence!)" : "nil"
        return temp
    }
}

extension RBTF.MatcherResponse {
    var dict: OrderedDictionary<String, String> {
        var temp: OrderedDictionary<String, String> = [:]
        temp["value_tag"] = value_tag ?? "nil"
        temp = temp.merging(debug?.dict.newKey(prefix: "debug:") ?? [:]) { $1 }
        return temp
    }
}

extension RBTF.MatcherDebug {
    var dict: OrderedDictionary<String, String> {
        var temp: OrderedDictionary<String, String> = [:]
        temp["pattern"] = pattern ?? "nil"
        temp["lang"] = lang ?? "nil"
        temp["product_name"] = product_name ?? "nil"
        temp["processed_product_name"] = processed_product_name ?? "nil"
        temp["category_name"] = category_name ?? "nil"
        temp["start_idx"] = start_idx != nil ? "\(start_idx!)" : "nil"
        temp["end_idx"] = end_idx != nil ? "\(end_idx!)" : "nil"
        temp["is_full_match"] = is_full_match != nil ? is_full_match!.description : "nil"
        return temp
    }
}

extension OrderedDictionary <String, String> {
/**
 Function to prefix the keys of an ordered dictionary with a string.
 
 - Parameters:
    - prefix: string to put in front of all existing keys
 */
    func newKey(prefix: String) -> [String:String]{
        var newDict: [String:String] = [:]
        for (key, value) in self {
            newDict[prefix + key] = value
        }
        return newDict
    }
}
