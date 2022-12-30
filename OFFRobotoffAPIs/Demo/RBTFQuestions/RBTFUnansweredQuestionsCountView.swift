//
//  RBTFUnansweredQuestionsCountView.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 25/11/2022.
//

import SwiftUI
import Collections

class RBTFUnansweredQuestionsCountViewModel: ObservableObject {

    // variable that needs to be tracked by the view
    @Published var unansweredQuestionsResponse: RBTF.UnansweredQuestionsResponse?
    
    fileprivate var count: UInt?
    fileprivate var country: Country?
    fileprivate var page: UInt?
    fileprivate var insightType: String?

    fileprivate var errorMessage: String?

    private var rbtfSession = URLSession.shared

    fileprivate var unansweredQuestionsCountDictArray: [OrderedDictionary<String, String>] {
        guard let questions = unansweredQuestionsResponse?.questions else { return [] }
        var orderedQuestionsArray : [OrderedDictionary<String, String>] = []
        for element in questions {
            if let firstElement = element.first,
               let key = firstElement.key {
                let validIntAsString = "\(firstElement.value)"
                orderedQuestionsArray.append([key:validIntAsString])
            }
        }
        return orderedQuestionsArray
    }
    
    fileprivate var insightTypeInput: RBTF.InsightType? {
        insightType != nil ? RBTF.InsightType.value(for: insightType!): nil
    }
    
    // get the properties
    fileprivate func update() {
        // get the remote data
        rbtfSession.RBTFUnansweredQuestionsCountExtended(count: count, insightType: insightTypeInput, country: country, page: page ){ (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.unansweredQuestionsResponse = response
                case .failure(let error):
                    self.errorMessage = error.description
                }
            }
        }
    }
}

struct RBTFUnansweredQuestionsCountView: View {
    
    @StateObject var model = RBTFUnansweredQuestionsCountViewModel()
    
    @State private var count: String = ""
    @State private var country: String = ""
    @State private var insightType: String = ""
    @State private var page: String = ""

    @State private var isFetching = false
    
    // Either show a barcode input field wth the possibility to start a fetch.
    // If the fetch is doen show the results
    
    var body: some View {

        if isFetching {
            VStack {
                if let products = model.unansweredQuestionsResponse {
                    
                    if products.responseStatus  == .found {
                        ListView(text: "Unanswered questions count", dictArray: model.unansweredQuestionsCountDictArray)
                    } else {
                        Text("No unanswered questions count available")
                    }
                } else if model.errorMessage != nil {
                    Text(model.errorMessage!)
                } else {
                    Text("Search in progress for unanswered questions count")
                }
            }
            .navigationTitle("Unanswered questions count")

        } else {
            Text("This fetch retrieves the unanswered questions count.")
                .padding()
            InputView(title: "Enter count", placeholder: "25", text: $count)
                .onChange(of: count, perform: { newValue in
                    if !count.isEmpty {
                        model.count = UInt(count)
                    }
                })
            InputView(title: "Enter country", placeholder: "en:france", text: $country)
                .onChange(of: country, perform: { newValue in
                    if !country.isEmpty {
                        model.country = Country(rawValue: country)
                    }
                })
            InputView(title: "Enter insight types string", placeholder: "categories", text: $insightType)
                .onChange(of: insightType, perform: { newValue in
                    if !insightType.isEmpty {
                        model.insightType = insightType
                    }
                })
            InputView(title: "Enter page", placeholder: "1", text: $page)
                .onChange(of: page, perform: { newValue in
                    if !page.isEmpty {
                        model.page = UInt(page)
                    }
                })
            Button( action: {
                model.update()
                isFetching = true
                })
            { Text("Fetch questions count") }
                .font(.title)
                
            .navigationTitle("Questions count")
            .onAppear {
                isFetching = false
            }
        }
    }
}

struct RBTFUnansweredQuestionsCountView_Previews: PreviewProvider {
    static var previews: some View {
        RBTFUnansweredQuestionsCountView()
    }
}
