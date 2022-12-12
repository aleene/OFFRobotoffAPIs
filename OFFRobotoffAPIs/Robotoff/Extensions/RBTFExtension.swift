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

        // can I make this to a separate dict and add it?
        temp["image:id"] = image?.id != nil ? "\(image!.id!)" : "nil"
        temp["image:barcode"] = image?.barcode ?? "nil"
        temp["image:uploaded_at"] = image?.uploaded_at ?? "nil"
        temp["image:imaged_id"] = image?.imaged_id ?? "nil"
        temp["image:source_image"] = image?.source_image ?? "nil"
        temp["image:width"] = image?.width != nil ? "\(image!.width!)" : "nil"
        temp["image:height"] = image?.height != nil ? "\(image!.height!)" : "nil"
        temp["image:deleted"] = image?.deleted != nil ? (image!.deleted! ? "true" : "false" ) : "nil"
        temp["image:server_domain"] = image?.server_domain ?? "nil"
        temp["image:server_type"] = image?.server_type ?? "nil"
        return temp
    }
}
