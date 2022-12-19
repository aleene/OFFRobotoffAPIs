//
//  RBTFInsightsBarcodeView.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 30/11/2022.
//

import SwiftUI
import Collections

class RBTFInsightsBarcodeViewModel: ObservableObject {

    @Published var insightsResponse: RBTF.InsightsResponse?
    
    @Published var barcode: String = "3046920029759"
    @Published var count: UInt?
    @Published var country: String?
    @Published var valueTag: String?
    @Published var insightType: String?

    @Published var errorMessage: String?

    private var rbtfSession = URLSession.shared

    fileprivate var offBarcode: OFFBarcode {
        OFFBarcode(barcode: barcode)
    }
    
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
        rbtfSession.RBTFInsights(barcode: offBarcode, insightType: insightTypeInput, country: country, valueTag: valueTag, count: count){ (result) in
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

struct RBTFInsightsBarcodeView: View {
    @StateObject var model = RBTFInsightsBarcodeViewModel()
    
    @State private var barcode: String = "3046920029759"
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
                        let text = "Barcode insights for barcode \(barcode)"
                        ListView(text: text, dictArray: model.insightsDictArray)
                    } else {
                        Text("No barcode insights available for barcode \(barcode)")
                    }
                } else if model.errorMessage != nil {
                    Text(model.errorMessage!)
                } else {
                    Text("Search in progress for insights for barcode \(barcode)")
                }
            }
            .navigationTitle("Barcode insights")

        } else {
            Text("This fetch retrieves random insights.")
                .padding()
            InputView(title: "Enter barcode", placeholder: "3046920029759", text: $barcode)
                .onChange(of: barcode, perform: { newValue in
                    if !barcode.isEmpty {
                        model.barcode = barcode
                    }
                })
            InputView(title: "Enter insight type", placeholder: "all", text: $insightType)
                .onChange(of: insightType, perform: { newValue in
                    if !insightType.isEmpty {
                        model.insightType = insightType
                    }
                })
            InputView(title: "Enter country", placeholder: "en:france", text: $country)
                .onChange(of: country, perform: { newValue in
                    if !country.isEmpty {
                        model.country = country
                    }
                })
            InputView(title: "Enter value tag", placeholder: "some value", text: $valueTag)
                .onChange(of: valueTag, perform: { newValue in
                    if !valueTag.isEmpty {
                        model.valueTag = valueTag
                    }
                })
           InputView(title: "Enter count", placeholder: "25", text: $count)
                .onChange(of: count, perform: { newValue in
                    if !count.isEmpty {
                        model.count = UInt(count)
                    }
                })
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

struct RBTFInsightsBarcodeView_Previews: PreviewProvider {
    static var previews: some View {
        RBTFInsightsBarcodeView()
    }
}
