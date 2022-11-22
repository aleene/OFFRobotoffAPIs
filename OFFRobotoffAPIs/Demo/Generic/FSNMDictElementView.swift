//
//  FSNMViewDictElement.swift
//  OFFFolksonomy
//
//  Created by Arnaud Leene on 22/10/2022.
//

import SwiftUI

struct FSNMDictElementView: View {
    public var dict: [String:String]
    
    var body: some View {
        HStack {
            Text(dict.first!.key)
            Text(dict.first!.value)
        }
    }
}

struct FSNMDictElementView_Previews: PreviewProvider {
    static var testDict = ["test":"value"]
    static var previews: some View {
        FSNMDictElementView(dict: testDict)
    }
}
