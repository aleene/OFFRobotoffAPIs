//
//  OFFAddtionsExtension.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 30/12/2022.
//

// Extensions for the OFFAdditions. Required
import Foundation

extension OFFProductType {
/// The host part of an URL endpoint for a producttype
    var host: String {
        switch self {
        case .food: return "openfoodfacts"
        case .petFood: return "openpetfoodfacts"
        case .beauty: return "openbeautyfacts"
        case .product: return "openproductfacts"
        }
    }
}
