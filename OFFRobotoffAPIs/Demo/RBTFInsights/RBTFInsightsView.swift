//
//  RBTFInsightsView.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 28/11/2022.
//

import SwiftUI

struct RBTFInsightsView: View {
    
    var body: some View {
        VStack {
            NavigationLink(destination: RBTFInsightsRandomView() ) {
                Text("Insights Random API")
            }
            NavigationLink(destination: RBTFInsightsBarcodeView() ) {
                Text("Insights Barcode API")
            }
            NavigationLink(destination: RBTFInsightsDetailView() ) {
                Text("Insights Detail API")
            }
        }
        .navigationTitle("Robotoff Insights API's")
    }
}

struct RBTFInsightsView_Previews: PreviewProvider {
    static var previews: some View {
        RBTFInsightsView()
    }
}
