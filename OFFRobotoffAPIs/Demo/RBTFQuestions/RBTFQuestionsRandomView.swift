//
//  RBTFQuestionsRandomView.swift
//  OFFRobotoffAPIsTests
//
//  Created by Arnaud Leene on 21/11/2022.
//

import SwiftUI
import Collections

class RBTFQuestionsRandomViewModel: ObservableObject {

    @Published var questionsResponse: RBTF.QuestionsResponse?
    
    fileprivate var language: ISO693_1?
    fileprivate var count: UInt?
    fileprivate var country: Country?
    fileprivate var brands: String?
    fileprivate var valueTag: String?
    fileprivate var page: UInt?
    fileprivate var insightTypes: [RBTF.InsightType] = []

    fileprivate var errorMessage: String?

    private var rbtfSession = URLSession.shared

    fileprivate var questionsDictArray: [OrderedDictionary<String, String>] {
        guard let questions = questionsResponse?.questions else { return [] }
        return questions.map({ $0.dict })
    }
    
    fileprivate var brandsInput: [String] {
        brands != nil ? [brands!] : []
    }
    
    // get the properties
    fileprivate func update() {
        // get the remote data
        rbtfSession.RBTFQuestionsRandomExtended(language: language,
                                                count: count,
                                                insightTypes: insightTypes,
                                                country: country,
                                                brands: brandsInput,
                                                valueTag: valueTag,
                                                page: page){ (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.questionsResponse = response
                case .failure(let error):
                    self.errorMessage = error.description
                }
            }
        }
    }
}

struct RBTFQuestionsRandomView: View {
    @StateObject var model = RBTFQuestionsRandomViewModel()
    
    @State private var language: String = ""
    @State private var count: String = ""
    @State private var country: String = ""
    @State private var brands: String = ""
    @State private var valueTag: String = ""
    @State private var insightTypes: String = ""
    @State private var page: String = ""

    @State private var isFetching = false
    
    fileprivate var insightTypesInput: [RBTF.InsightType] {
        var input: [RBTF.InsightType] = []
        let strings = insightTypes.split(separator: ",")
        for element in strings {
            input.append(RBTF.InsightType.value(for: String(element)))
        }
        return input
    }

    // Either show a barcode input field wth the possibility to start a fetch.
    // If the fetch is doen show the results
    
    var body: some View {

        if isFetching {
            VStack {
                if let products = model.questionsResponse {
                    
                    if products.responseStatus  == .found {
                        ListView(text: "Random questions", dictArray: model.questionsDictArray)
                    } else {
                        Text("No random questions available")
                    }
                } else if model.errorMessage != nil {
                    Text(model.errorMessage!)
                } else {
                    Text("Search in progress for random questions")
                }
            }
            .navigationTitle("Questions")

        } else {
            Text("This fetch retrieves random questions.")
                .padding()
            InputView(title: "Enter language code", placeholder: "en", text: $language)
                .onChange(of: language, perform: { newValue in model.language = ISO693_1(rawValue: language) })
            InputView(title: "Enter count", placeholder: "25", text: $count)
                .onChange(of: count, perform: { newValue in model.count = UInt(count) })
            InputView(title: "Enter country", placeholder: "en:france", text: $country)
                .onChange(of: country, perform: { newValue in model.country = Country(rawValue: country)  })
            InputView(title: "Enter brands", placeholder: "brand1, brand2, all", text: $brands)
                .onChange(of: brands, perform: { newValue in model.brands = brands })
            InputView(title: "Enter value tag", placeholder: "some value", text: $valueTag)
                .onChange(of: valueTag, perform: { newValue in model.valueTag = valueTag })
            InputView(title: "Enter insight types", placeholder: "all", text: $insightTypes)
                .onChange(of: insightTypes, perform: { newValue in model.insightTypes = insightTypesInput })
            InputView(title: "Enter page", placeholder: "1", text: $page)
                .onChange(of: page, perform: { newValue in model.page = UInt(page) })
            Button( action: {
                model.update()
                isFetching = true
                })
            { Text("Fetch questions") }
                .font(.title)
                
            .navigationTitle("Product Questions")
            .onAppear {
                isFetching = false
            }
        }
    }
}

struct RBTFQuestionsRandomView_Previews: PreviewProvider {
    static var previews: some View {
        RBTFQuestionsRandomView()
    }
}
