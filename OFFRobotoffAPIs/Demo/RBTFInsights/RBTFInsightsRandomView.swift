//
//  RBTFInsightsRandomView.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 28/11/2022.
//

import SwiftUI
import Collections

class RBTFInsightsRandomViewModel: ObservableObject {

    @Published var insightsResponse: RBTF.InsightsResponse?
    
    @Published var count: UInt?
    @Published var country: String?
    @Published var valueTag: String?
    @Published var insightType: String?

    @Published var errorMessage: String?

    private var rbtfSession = URLSession.shared

    fileprivate var insightsDictArray: [OrderedDictionary<String, String>] {
        guard let questions = insightsResponse?.insights else { return [] }
        return questions.map({ $0.dict })
    }
    
    fileprivate var insightTypeInput: RBTF.InsightType? {
        insightType != nil ? RBTF.InsightType.value(for: insightType!): nil
    }

    // get the properties
    fileprivate func update() {
        // get the remote data
        rbtfSession.RBTFInsights(insightType: insightTypeInput, country: country, valueTag: valueTag, count: count){ (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.insightsResponse = response
                case .failure(let error):
                    self.errorMessage = error.description
                }
            }
        }
    }
}

struct RBTFInsightsRandomView: View {
    @StateObject var model = RBTFInsightsRandomViewModel()
    
    @State private var count: String = ""
    @State private var country: String = ""
    @State private var valueTag: String = ""
    @State private var insightType: String = ""

    @State private var isFetching = false
    
    // Either show a barcode input field wth the possibility to start a fetch.
    // If the fetch is doen show the results
    
    var body: some View {

        if isFetching {
            VStack {
                if let insightsResponse = model.insightsResponse {
                    
                    if insightsResponse.responseStatus == .found {
                        ListView(text: "Random insights", dictArray: model.insightsDictArray)
                    } else {
                        Text("No insights available")
                    }
                } else if model.errorMessage != nil {
                    Text(model.errorMessage!)
                } else {
                    Text("Search in progress for random insights")
                }
            }
            .navigationTitle("Random insights")

        } else {
            Text("This fetch retrieves random insights.")
                .padding()
            InputView(title: "Enter insight type", placeholder: "all", text: $insightType)
            InputView(title: "Enter country", placeholder: "en:france", text: $country)
            InputView(title: "Enter value tag", placeholder: "some value", text: $valueTag)
            InputView(title: "Enter count", placeholder: "25", text: $count)
            Button( action: {
                model.update()
                isFetching = true
                })
            { Text("Fetch insights") }
                .font(.title)
                
            .navigationTitle("Insights")
            .onAppear {
                isFetching = false
            }
        }
    }
}

struct RBTFInsightsRandomView_Previews: PreviewProvider {
    static var previews: some View {
        RBTFInsightsRandomView()
    }
}
