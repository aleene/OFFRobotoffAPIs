//
//  FSNMViewDictElement.swift
//  OFFFolksonomy
//
//  Created by Arnaud Leene on 22/10/2022.
//

import SwiftUI

struct DictElementView: View {
    public var dict: [String:String]
    
    var body: some View {
        HStack {
            Text(dict.first!.key)
            Text(dict.first!.value)
        }
    }
}

struct DictElementView_Previews: PreviewProvider {
    static var testDict = ["test":"value"]
    static var previews: some View {
        DictElementView(dict: testDict)
    }
}
