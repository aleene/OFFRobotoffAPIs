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
    @Published var errorMessage: String?

    private var rbtfSession = URLSession.shared
    
    var questionsDictArray: [OrderedDictionary<String, String>] {
        guard let questions = questionsResponse?.questions else { return [] }
        return questions.map({ $0.dict })
    }
    
    // get the properties
    func update() {
        // get the remote data
        rbtfSession.RBTFQuestionsProduct(with: barcode) { (result) in
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
    
    @State private var barcode: String = "3760091720115"
    @State private var isFetching = false
    
    // Either show a barcode input field wth the possibility to start a fetch.
    // If the fetch is doen show the results
    
    var body: some View {

        if isFetching {
            VStack {
                if let products = model.questionsResponse {
                    
                    if products.status == "found" {
                        ListView(text: "The questions for the product with barcode \(model.barcode.barcode)", dictArray: model.questionsDictArray)
                    } else {
                        Text("No questions for \(model.barcode.barcode) available")
                    }
                } else if model.errorMessage != nil {
                    Text(model.errorMessage!)
                } else {
                    Text("Search in progress for questions of \(model.barcode.barcode)")
                }
            }
            .navigationTitle("Products")

        } else {
            Text("This fetch retrieves the questions for a product.")
                .padding()
            FSNMInput(title: "Enter barcode", placeholder: barcode, text: $barcode)
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
        temp["type"] = type ?? "nil"
        temp["value"] = value ?? "nil"
        temp["question"] = question ?? "nil"
        temp["insight_id"] = insight_id ?? "nil"
        temp["value_tag"] = value_tag ?? "nil"
        temp["source_image_url"] = source_image_url ?? "nil"
        return temp
    }
}
