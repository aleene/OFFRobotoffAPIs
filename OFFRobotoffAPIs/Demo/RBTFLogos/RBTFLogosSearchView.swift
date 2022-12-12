//
//  RBTFLogosSearchView.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 12/12/2022.
//

import SwiftUI

//
//  RBTFLogosFetchView.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 09/12/2022.
//

import SwiftUI
import Collections

class RBTFLogosSearchViewModel: ObservableObject {

    @Published var logosResponse: RBTF.LogosResponse?
    
    @Published var logoIds: String = "test"
    @Published var count: UInt?
    @Published var type: String?
    @Published var barcode: OFFBarcode?
    @Published var value: String?
    @Published var taxonomy_value: String?
    @Published var min_confidence: Int?
    @Published var random: Bool?
    @Published var annotated: Bool?

    @Published var errorMessage: String?

    private var rbtfSession = URLSession.shared
    
    fileprivate var logosDict: [OrderedDictionary<String, String>] {
        guard let logos = logosResponse?.logos else { return [] }
        return logos.map({ $0.dict })
    }
    
    fileprivate func update() {
        // get the remote data
        rbtfSession.RBTFLogos(count: count, type: type, barcode: barcode, value: value, taxonomy_value: taxonomy_value, min_confidence: min_confidence, random: random, annotated: annotated ){ (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.logosResponse = response
                case .failure(let error):
                    self.errorMessage = error.description
                }
            }
        }
    }
}

struct RBTFLogosSearchView: View {
    @StateObject var model = RBTFLogosSearchViewModel()
    
    @State private var count: String = "" {
        didSet {
            if !count.isEmpty {
                model.count = UInt(count)
            }
        }
    }
    @State private var type: String = "" {
        didSet {
            if !type.isEmpty {
                model.type = type
            }
        }
    }
    @State private var barcode: String = "" {
        didSet {
            if !barcode.isEmpty {
                model.barcode = OFFBarcode(barcode: barcode)
            }
        }
    }
    @State private var value: String = "" {
        didSet {
            if !value.isEmpty {
                model.value = value
            }
        }
    }
    @State private var taxonomy_value: String = "" {
        didSet {
            if !taxonomy_value.isEmpty {
                model.taxonomy_value = taxonomy_value
            }
        }
    }
    @State private var min_confidence: String = "" {
        didSet {
            if !min_confidence.isEmpty {
                model.min_confidence = Int(min_confidence)
            }
        }
    }
    @State private var random: String = "" {
        didSet {
            if !random.isEmpty {
                switch random {
                case "true":
                    model.random = true
                case "false":
                    model.random = false
                default:
                    break
                }
            }
        }
    }
    @State private var annotated: String = "" {
        didSet {
            if !annotated.isEmpty {
                switch annotated {
                case "true":
                    model.annotated = true
                case "false":
                    model.annotated = false
                default:
                    break
                }
            }
        }
    }

    @State private var isFetching = false
    
    // Either show a barcode input field wth the possibility to start a fetch.
    // If the fetch is doen show the results
    
    var body: some View {

        if isFetching {
            VStack {
                if model.logosResponse != nil {
                    
                    ListView(text: "Logo ID's", dictArray: model.logosDict)
                } else if model.errorMessage != nil {
                    Text(model.errorMessage!)
                } else {
                    Text("Search in progress for logo ids")
                }
            }
            .navigationTitle("Logos")

        } else {
            Text("This fetch retrieves logos.")
                .padding()
            InputView(title: "Enter count", placeholder: "25", text: $count)
            InputView(title: "Enter type", placeholder: "packager_code", text: $type)
            InputView(title: "Enter barcode", placeholder: "1234567890123", text: $barcode)
            InputView(title: "Enter value", placeholder: "lidl", text: $value)
            InputView(title: "Enter count", placeholder: "25", text: $count)
            InputView(title: "Enter taxonomy_value", placeholder: "en:organic", text: $taxonomy_value)
            InputView(title: "Enter random", placeholder: "false", text: $random)
            InputView(title: "Enter annotated (true/false)", placeholder: "nil", text: $annotated)
            Button( action: {
                model.update()
                isFetching = true
                })
            { Text("Fetch logo id's") }
                .font(.title)
                
            .navigationTitle("Logos")
            .onAppear {
                isFetching = false
            }
        }
    }
}

struct RBTFLogosSearchView_Previews: PreviewProvider {
    static var previews: some View {
        RBTFLogosSearchView()
    }
}
