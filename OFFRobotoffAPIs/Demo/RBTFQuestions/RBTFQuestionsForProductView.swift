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
    
    fileprivate var barcode: OFFBarcode = OFFBarcode(barcode: "3046920029759")
    fileprivate var count: UInt?
    fileprivate var language: ISO693_1?
    fileprivate var errorMessage: String?

    private var rbtfSession = URLSession.shared
    private var countInt : UInt? {
        count != nil ? UInt(count!) : nil
    }
    
    public var countString: String {
        count != nil ? String(count!) : "nil"
    }
    
    fileprivate var questionsDictArray: [OrderedDictionary<String, String>] {
        guard let questions = questionsResponse?.questions else { return [] }
        return questions.map({ $0.dict })
    }
    
    // get the properties
    fileprivate func update() {
        // get the remote data
        rbtfSession.RBTFQuestionsForProduct(with: barcode,
                                                 count: countInt,
                                                 lang: language)
        { (result) in
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
        text += model.countString
        text += " and language " + (model.language?.rawValue ?? "en")
        return text
    }
    
    private var string2: String {
        var text = "No questions for product \(model.barcode.barcode) with " + model.countString
        text += " and language "
        text += (model.language?.rawValue ?? "en") + " available"
        return text
    }
    
    private var string3: String {
        var text = "Search in progress for questions of \(model.barcode.barcode) with "
        text += model.countString
        text += " and language "
        text += (model.language?.rawValue ?? "en")
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
                .onChange(of: barcode, perform: { newValue in
                    if !barcode.isEmpty {
                        model.barcode = OFFBarcode(barcode: barcode)
                    }
                })
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
           Button(action: {
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
