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
        rbtfSession.RBTFQuestionsRandom() { (result) in
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
    
    @State private var isFetching = false
    
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
