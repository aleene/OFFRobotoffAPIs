//
//  RBTFQuestionsPopularView.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 25/11/2022.
//

import SwiftUI
import Collections

class RBTFQuestionsPopularViewModel: ObservableObject {

    @Published var questionsResponse: RBTF.QuestionsResponse?
    
    fileprivate var language: ISO693_1?
    fileprivate var count: UInt?
    fileprivate var country: Country?
    fileprivate var brands: String?
    fileprivate var valueTag: String?
    fileprivate var page: UInt?
    fileprivate var insightTypes: String?

    fileprivate var errorMessage: String?

    private var rbtfSession = URLSession.shared

    fileprivate var questionsDictArray: [OrderedDictionary<String, String>] {
        guard let questions = questionsResponse?.questions else { return [] }
        return questions.map({ $0.dict })
    }
    
    fileprivate var brandsInput: [String] {
        brands != nil ? [brands!] : []
    }

    fileprivate var insightTypesInput: [RBTF.InsightType] {
        if insightTypes != nil {
            var input: [RBTF.InsightType] = []
            let strings = insightTypes!.split(separator: ",")
            for element in strings {
                input.append(RBTF.InsightType.value(for: String(element)))
            }
            return input
        } else {
            return []
        }
    }
    
    // get the properties
    fileprivate func update() {
        // get the remote data
        rbtfSession.RBTFQuestionsPopular(language: language, count: count, insightTypes: insightTypesInput, country: country, brands: brandsInput, valueTag: valueTag, page: page){ (result) in
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

struct RBTFQuestionsPopularView: View {
    @StateObject var model = RBTFQuestionsPopularViewModel()
    
    @State private var language: String = ""
    @State private var count: String = ""
    @State private var country: String = ""
    @State private var brands: String = ""
    @State private var valueTag: String = ""
    @State private var insightTypes: String = ""
    @State private var page: String = ""

    @State private var isFetching = false
    
    // Either show a barcode input field wth the possibility to start a fetch.
    // If the fetch is doen show the results
    
    var body: some View {

        if isFetching {
            VStack {
                if let products = model.questionsResponse {
                    
                    if products.responseStatus  == .found {
                        ListView(text: "Popular questions", dictArray: model.questionsDictArray)
                    } else {
                        Text("No popular questions available")
                    }
                } else if model.errorMessage != nil {
                    Text(model.errorMessage!)
                } else {
                    Text("Search in progress for popular questions")
                }
            }
            .navigationTitle("Questions")

        } else {
            Text("This fetch retrieves popular questions.")
                .padding()
            InputView(title: "Enter language code", placeholder: "en", text: $language)
                .onChange(of: language, perform: { newValue in
                    if !language.isEmpty {
                        model.language = ISO693_1(rawValue: language)
                    }
                })
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
           InputView(title: "Enter brands", placeholder: "brand1, brand2, all", text: $brands)
                .onChange(of: brands, perform: { newValue in
                    if !brands.isEmpty {
                        model.brands = brands
                    }
                })
            InputView(title: "Enter value tag", placeholder: "some value", text: $valueTag)
                .onChange(of: valueTag, perform: { newValue in
                    if !valueTag.isEmpty {
                        model.valueTag = valueTag
                    }
                })
            InputView(title: "Enter insight types", placeholder: "all", text: $insightTypes)
                .onChange(of: insightTypes, perform: { newValue in
                    if !insightTypes.isEmpty {
                        model.insightTypes = insightTypes
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
            { Text("Fetch questions") }
                .font(.title)
                
            .navigationTitle("Product Questions")
            .onAppear {
                isFetching = false
            }
        }
    }
}

struct RBTFQuestionsPopularView_Previews: PreviewProvider {
    static var previews: some View {
        RBTFQuestionsPopularView()
    }
}
