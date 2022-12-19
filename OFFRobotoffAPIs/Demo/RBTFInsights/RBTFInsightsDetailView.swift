//
//  RBTFInsightsDetailView.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 06/12/2022.
//

import SwiftUI
import Collections

class RBTFInsightsDetailViewModel: ObservableObject {
    
    @Published var insight: RBTF.Insight?
    
    fileprivate var insightId: String?
    fileprivate var errorMessage: String?
    
    private var rbtfSession = URLSession.shared
    private var validInsightId: String {
        insightId ?? "3cd5aecd-edcc-4237-87d0-6595fc4e53c9"
    }
    
    fileprivate var insightsDictArray: [OrderedDictionary<String, String>] {
        guard let question = insight else { return [] }
        return [question].map({ $0.dict })
    }
    
    // get the properties
    fileprivate func update() {
        // get the remote data
        rbtfSession.RBTFInsights(insightId: validInsightId){ (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.insight = response
                case .failure(let error):
                    self.errorMessage = error.description
                }
            }
        }
    }
}

struct RBTFInsightsDetailView: View {
    @StateObject var model = RBTFInsightsDetailViewModel()
    
    @State private var insightId: String = ""

    @State private var isFetching = false
        
    var body: some View {

        if isFetching {
            VStack {
                if model.insight != nil {
                    let text = "Insight details for id \(insightId)"
                    ListView(text: text, dictArray: model.insightsDictArray)
                } else if model.errorMessage != nil {
                    Text(model.errorMessage!)
                } else {
                    Text("Search in progress for insight details of id \(insightId)")
                }
            }
            .navigationTitle("Insight detail")

        } else {
            Text("This fetch retrieves the insight details for a specific insight.")
                .padding()
            InputView(title: "Enter insight id", placeholder: "3cd5aecd-edcc-4237-87d0-6595fc4e53c9", text: $insightId)
                .onChange(of: insightId, perform: { newValue in
                    if !insightId.isEmpty {
                        model.insightId = insightId
                    }
                })
            Button( action: {
                model.insightId = insightId
                model.update()
                isFetching = true
                })
            { Text("Fetch insight details") }
                .font(.title)
                
            .navigationTitle("Insights")
            .onAppear {
                isFetching = false
            }
        }
    }
}

struct RBTFInsightsDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RBTFInsightsDetailView()
    }
}
