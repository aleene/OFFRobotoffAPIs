//
//  RBTFLogosView.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 09/12/2022.
//

import SwiftUI

struct RBTFLogosView: View {
    var body: some View {
        VStack {
            NavigationLink(destination: RBTFLogosFetchView() ) {
                Text("Logos Fetch API")
            }
            Text("Logos Search API")
        }
        .navigationTitle("Logos API's")
    }
}

struct RBTFLogosView_Previews: PreviewProvider {
    static var previews: some View {
        RBTFLogosView()
    }
}
