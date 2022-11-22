//
//  FSNMDictView.swift
//  OFFFolksonomy
//
//  Created by Arnaud Leene on 22/10/2022.
//

import SwiftUI
import Collections

struct DictView: View {

    // These variables will only be set from outside
    // They are decoupled from datatypes
    // The stored properties/initializers model is used
    public var dict: OrderedDictionary<String, String>
    
    internal var body: some View {
        Section() {
            ForEach(dict.elements, id:\.key) {
                DictElementView(dict: [$0.key:$0.value])
            }
        }
    }
}

struct DictView_Previews: PreviewProvider {
    
    static var previews: some View {
        DictView(dict: ["test":"test"])
    }
}
