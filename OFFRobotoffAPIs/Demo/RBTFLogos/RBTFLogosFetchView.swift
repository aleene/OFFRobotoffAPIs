//
//  RBTFLogosFetchView.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 09/12/2022.
//

import SwiftUI
import Collections

class RBTFLogosFetchViewModel: ObservableObject {

    @Published var logosResponse: RBTF.LogosResponse?
    
    fileprivate var logoIds: String = "122299"
    fileprivate var errorMessage: String?

    private var rbtfSession = URLSession.shared
    
    fileprivate var logosDict: [OrderedDictionary<String, String>] {
        guard let logos = logosResponse?.logos else { return [] }
        return logos.map({ $0.dict })
    }
    
    fileprivate func update() {
        // get the remote data
        rbtfSession.RBTFLogos(logoIds: logoIds){ (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.logosResponse = response
                case .failure(let error):
                    self.errorMessage = error.description
                }
            }
        }
    }
}

struct RBTFLogosFetchView: View {
    @StateObject var model = RBTFLogosFetchViewModel()
    
    @State private var logoIds: String = "122299"

    @State private var isFetching = false
    
    // Either show a barcode input field wth the possibility to start a fetch.
    // If the fetch is doen show the results
    
    var body: some View {

        if isFetching {
            VStack {
                if model.logosResponse != nil {
                    
                    ListView(text: "Logo ID's", dictArray: model.logosDict)
                } else if model.errorMessage != nil {
                    Text(model.errorMessage!)
                } else {
                    Text("Search in progress for logos details")
                }
            }
            .navigationTitle("Logos")

        } else {
            Text("This fetch retrieves logos details.")
                .padding()
            InputView(title: "Enter logo id", placeholder: "", text: $logoIds)
                .onChange(of: logoIds, perform: { newValue in
                    if !logoIds.isEmpty {
                        model.logoIds = logoIds
                    }
                })
            Button( action: {
                model.update()
                isFetching = true
                })
            { Text("Fetch logos details") }
                .font(.title)
                
            .navigationTitle("Logos")
            .onAppear {
                isFetching = false
            }
        }
    }
}

struct RBTFLogosFetchView_Previews: PreviewProvider {
    static var previews: some View {
        RBTFLogosFetchView()
    }
}
