//
//  RBTFInsightsAnnotateView.swift
//  OFFRobotoffAPIs
//
//  Created by Arnaud Leene on 16/12/2022.
//

import SwiftUI
import Collections

class RBTFInsightsAnnotateViewModel: ObservableObject {

    @Published var annotateResponse: RBTF.AnnotateResponse?
    
    public var insightID: String = "cdcf033b-f156-4068-a1bd-858c5effd2ac"
    public var annotation: RBTF.Annotation = .skip
    public var username: String?
    public var password: String?

    public var errorMessage: String?

    private var rbtfSession = URLSession.shared
    
    fileprivate var annotateResponseDictArray: [OrderedDictionary<String, String>] {
        guard let response = annotateResponse else { return [] }
        return [response.dict]
    }
    
    // get the properties
    fileprivate func update() {
        // get the remote data
        rbtfSession.RBTFInsights(insightID: insightID,
                                 annotation: annotation,
                                 username: username,
                                 password: password) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.annotateResponse = response
                case .failure(let error):
                    self.errorMessage = error.description
                }
            }
        }
    }
}

struct RBTFInsightsAnnotateView: View {
    @StateObject var model = RBTFInsightsAnnotateViewModel()
    
    @State private var insightID: String = "" {
        didSet {
            if !insightID.isEmpty {
                model.insightID = insightID
            }
        }
    }
    
    @State private var annotation: String = "" {
        didSet {
            if !annotation.isEmpty {
                switch annotation {
                case "accept":
                    model.annotation = .accept
                case "refuse":
                    model.annotation = .refuse
                default:
                    model.annotation = .skip
                }
            }
        }
    }
    
    @State private var username: String = "" {
        didSet {
            if !username.isEmpty {
                model.username = username
            }
        }
    }
    
    @State private var password: String = "" {
        didSet {
            if !password.isEmpty {
                model.password = password
            }
        }
    }
    
    @State private var isFetching = false
    
    // Either show a barcode input field wth the possibility to start a fetch.
    // If the fetch is doen show the results
    
    var body: some View {

        if isFetching {
            VStack {
                if model.annotateResponse != nil {
                    
                    ListView(text: "Annotate response", dictArray: model.annotateResponseDictArray)
                } else if model.errorMessage != nil {
                    Text(model.errorMessage!)
                } else {
                    Text("Put  annotation")
                }
            }
            .navigationTitle("Insight annotation")

        } else {
            Text("This put uploades an annotation.")
                .padding()
            InputView(title: "Enter insight id", placeholder: "some id", text: $insightID)
                .onChange(of: insightID, perform: { newValue in
                    if !insightID.isEmpty {
                        model.insightID = insightID
                    }
                })
            InputView(title: "Enter annotation(accept, refuse, skip (default)", placeholder: "skip", text: $annotation)
                .onChange(of: annotation, perform: { newValue in
                    if !annotation.isEmpty {
                        model.annotation = RBTF.Annotation(string: annotation)
                    }
                })
           InputView(title: "Enter username", placeholder: "username", text: $username)
                .onChange(of: username, perform: { newValue in
                    if !username.isEmpty {
                        model.username = username
                    }
                })
           InputView(title: "Enter password", placeholder: "password", text: $password)
                .onChange(of: password, perform: { newValue in
                    if !password.isEmpty {
                        model.password = password
                    }
                })
           Button( action: {
                model.update()
                isFetching = true
                })
            { Text("Post annotation") }
                .font(.title)
                
            .navigationTitle("Insights annotation")
            .onAppear {
                isFetching = false
            }
        }
    }
}

struct RBTFInsightsAnnotateView_Previews: PreviewProvider {
    static var previews: some View {
        RBTFInsightsAnnotateView()
    }
}
