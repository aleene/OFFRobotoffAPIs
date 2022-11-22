//
//  FSNMInput.swift
//  OFFFolksonomy
//
//  Created by Arnaud Leene on 22/10/2022.
//

import SwiftUI

struct FSNMInput: View {
    public var title: String
    public var placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(title)
                .font(.footnote)
                .bold()
            TextField(placeholder, text: $text)
                .padding(.horizontal, 27.0)
                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                .autocapitalization(.none)
                .keyboardType(.default)
                .disableAutocorrection(true)
        }
        .padding(.bottom)
    }
}

struct FSNMBarcodeInput_Previews: PreviewProvider {
    
    static let text = "enter a field"
    
    static var previews: some View {
        FSNMInput(title: "Field", placeholder: "a number", text: .constant(text))
            .previewLayout(.sizeThatFits)
    
    }
}
