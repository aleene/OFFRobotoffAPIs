//
//  ContentView.swift
//  OFFFolksonomy
//
//  Created by Arnaud Leene on 13/10/2022.
//

import SwiftUI
import Collections

class RBTFQuestionsForProductViewModel: ObservableObject {
    
    @Published var questionsResponse: RBTF.QuestionsResponse?
    @Published var barcode: OFFBarcode = OFFBarcode(barcode: "")
    @Published var count: String?
    @Published var language: String?
    @Published var errorMessage: String?

    private var rbtfSession = URLSession.shared
    private var countInt : Int? {
        count != nil ? Int(count!) : nil
    }
    
    var questionsDictArray: [OrderedDictionary<String, String>] {
        guard let questions = questionsResponse?.questions else { return [] }
        return questions.map({ $0.dict })
    }
    
    // get the properties
    func update() {
        // get the remote data
        rbtfSession.RBTFQuestionsProduct(with: barcode, count: countInt, lang: language) { (result) in
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

struct RBTFQuestionsForProductView: View {
    
    @StateObject var model = RBTFQuestionsForProductViewModel()
    
    @State private var barcode: String = ""
    @State private var language: String = ""
    @State private var count: String = ""
    @State private var isFetching = false
    
    private var string1: String {
        var text = "The questions for the product with barcode \(model.barcode.barcode) with "
        text += (model.count ?? "nil")
        text += " and language " + (model.language ?? "en:")
        return text
    }
    
    private var string2: String {
        var text = "No questions for product \(model.barcode.barcode) with " + (model.count ?? "nil")
        text += " and language "
        text += (model.language ?? "en:") + " available"
        return text
    }
    
    private var string3: String {
        var text = "Search in progress for questions of \(model.barcode.barcode) with "
        text += (model.count ?? "nil")
        text += " and language "
        text += (model.language ?? "en:")
        return text
    }

    // Either show a barcode input field wth the possibility to start a fetch.
    // If the fetch is doen show the results
    
    var body: some View {

        if isFetching {
            VStack {
                if let products = model.questionsResponse {
                    switch products.responseStatus {
                    case .found:
                        ListView(text: string1, dictArray: model.questionsDictArray)
                    case .no_questions:
                        Text(string2)
                    case .unknown:
                        Text("We have an issue as this is a non-existing response")
                    }
                } else if model.errorMessage != nil {
                    Text(model.errorMessage!)
                } else {
                    Text(string3)
                }
            }
            .navigationTitle("Questions")

        } else {
            Text("This fetch retrieves the questions for a product.")
                .padding()
            InputView(title: "Enter barcode", placeholder: "4056489098683", text: $barcode)
            InputView(title: "Enter language code", placeholder: "en", text: $language)
            InputView(title: "Enter count", placeholder: "25", text: $count)
            Button(action: {
                model.barcode = OFFBarcode(barcode: barcode)
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

struct RBTFQuestionsForProductView_Previews: PreviewProvider {
            
    static var previews: some View {
        RBTFQuestionsForProductView()
    }
}

fileprivate extension RBTF.Question {
        
    // We like to keep the presentation order of the elements in RBTF.Question as it maps to the Swagger documentation
    var dict: OrderedDictionary<String, String> {
        var temp: OrderedDictionary<String, String> = [:]
        temp["barcode"] = barcode ?? "nil"
        temp["type"] = questionType.rawValue
        temp["value"] = value ?? "nil"
        temp["question"] = question ?? "nil"
        temp["insight_id"] = insight_id ?? "nil"
        temp["insight_type"] = insightType.rawValue
        temp["value_tag"] = value_tag ?? "nil"
        temp["source_image_url"] = source_image_url ?? "nil"
        return temp
    }
}

