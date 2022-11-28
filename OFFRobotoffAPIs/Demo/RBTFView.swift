//
//  RBTFView.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 20/11/2022.
//

import SwiftUI

struct RBTFView: View {
    
   // @ObservedObject var authController: AuthController
    
    var body: some View {
        VStack {
            NavigationLink(destination: RBTFQuestionsView() ) {
                Text("Questions API's")
            }
            NavigationLink(destination: RBTFInsightsView() ) {
                Text("Insights API's")
            }
        }
        .navigationTitle("Robotoff API's")
    }
}

// Give an overview of all RBTF API's
struct RBTFView_Previews: PreviewProvider {
    static var previews: some View {
        RBTFView()
    }
}
