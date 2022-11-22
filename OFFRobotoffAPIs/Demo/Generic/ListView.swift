//
//  FSNMListView.swift
//  OFFFolksonomy
//
//  Created by Arnaud Leene on 22/10/2022.
//

import SwiftUI
import Collections

struct ListView: View {
        
    public var text: String
    public var dictArray: [ OrderedDictionary<String, String> ]

    var body: some View {
        Text(text)
        List(dictArray.indices, id:\.self) { index in
            DictView(dict: dictArray[index])
        }
        .listStyle(.grouped)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(text: "Teststring", dictArray: [["test1":"test1"], ["test2":"test2"]])
    }
}
