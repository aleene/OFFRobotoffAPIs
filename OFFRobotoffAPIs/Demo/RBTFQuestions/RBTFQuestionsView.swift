//
//  RBTFQuestionsView.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 28/11/2022.
//

import SwiftUI

struct RBTFQuestionsView: View {
    var body: some View {
        VStack {
            NavigationLink(destination: RBTFQuestionsForProductView() ) {
                Text("Questions for Product API")
            }
            NavigationLink(destination: RBTFQuestionsRandomView() ) {
                Text("Random Questions API")
            }
            NavigationLink(destination: RBTFQuestionsPopularView() ) {
                Text("Popular Questions API")
            }
            NavigationLink(destination: RBTFUnansweredQuestionsCountView() ) {
                Text("Unanswered questions count API")
            }
        }
        .navigationTitle("Robotoff Question API's")
    }
}

struct RBTFQuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        RBTFQuestionsView()
    }
}
