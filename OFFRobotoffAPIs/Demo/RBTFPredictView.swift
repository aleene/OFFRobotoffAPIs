//
//  RBTFPredictView.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 15/12/2022.
//

import SwiftUI
import Collections

class RBTFPredictViewModel: ObservableObject {

    @Published var predictResponse: RBTF.PredictResponse?
    
    @Published var barcode = OFFBarcode(barcode: "748162621021")
    @Published var deepestOnly: Bool?
    @Published var threshold: Double?
    @Published var predictors: [RBTF.Predictors] = []

    @Published var errorMessage: String?

    private var rbtfSession = URLSession.shared
    
    fileprivate var predictResponseDictArray: [OrderedDictionary<String, String>] {
        guard let validPredictResponse = predictResponse else { return [] }
        return [validPredictResponse.dict]
    }
    
    fileprivate func update() {
        // get the remote data
        rbtfSession.RBTFPredictCategoriesProduct(barcode: barcode, deepestOnly: deepestOnly, threshold: threshold, predictors: predictors ) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.predictResponse = response
                case .failure(let error):
                    self.errorMessage = error.description
                }
            }
        }
    }
}

struct RBTFPredictView: View {
    
    @StateObject var model = RBTFPredictViewModel()

    @State private var barcode: String = "" {
        didSet {
            if !barcode.isEmpty {
                model.barcode = OFFBarcode(barcode: barcode)
            }
        }
    }
        
    @State private var deepestOnly: String = "" {
        didSet {
            if !deepestOnly.isEmpty {
                switch deepestOnly {
                case "true":
                    model.deepestOnly = true
                default:
                    model.deepestOnly = false
                }
            }
        }
    }
    
    @State private var threshold: String = "" {
        didSet {
            if !threshold.isEmpty {
                model.threshold = Double(threshold)
            }
        }
    }
    
    @State private var predictors: String = "" {
        didSet {
            if !predictors.isEmpty {
                let preds = predictors.components(separatedBy: ",")
                if !preds.isEmpty {
                    for element in preds {
                        for pred in RBTF.Predictors.allCases {
                            if pred.rawValue == element {
                                model.predictors.append(pred)
                            }
                        }
                    }
                }
            }
        }
    }

    @State private var isFetching = false

    var body: some View {

        if isFetching {
            VStack {
                if model.predictResponse != nil {
                    
                    ListView(text: "Category prediction", dictArray: model.predictResponseDictArray)
                } else if model.errorMessage != nil {
                    Text(model.errorMessage!)
                } else {
                    Text("Search in progress for category prediction")
                }
            }
            .navigationTitle("Predict category")

        } else {
            Text("This fetch retrieves the category prediction for a product.")
                .padding()
            InputView(title: "Enter barcode", placeholder: "748162621021", text: $barcode)
            InputView(title: "Enter deepestOnly", placeholder: "true or false", text: $deepestOnly)
            InputView(title: "Enter threshold", placeholder: "0.5", text: $threshold)
            InputView(title: "Enter predictors", placeholder: "neural or matcher", text: $predictors)
            Button( action: {
                model.update()
                isFetching = true
                })
            { Text("Fetch category prediction") }
                .font(.title)
                
            .navigationTitle("Predict category")
            .onAppear {
                isFetching = false
            }
        }
    }
}

struct RBTFPredictView_Previews: PreviewProvider {
    static var previews: some View {
        RBTFPredictView()
    }
}
