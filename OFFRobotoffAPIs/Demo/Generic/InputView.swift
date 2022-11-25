//
//  FSNMInput.swift
//  OFFFolksonomy
//
//  Created by Arnaud Leene on 22/10/2022.
//

import SwiftUI

struct InputView: View {
    public var title: String
    public var placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.footnote)
                .bold()
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.gray)
                }
                TextField("", text: $text)
                    .padding(.horizontal, 27.0)
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    .autocapitalization(.none)
                    .keyboardType(.default)
                    .disableAutocorrection(true)
            }
        }
        .padding(.bottom)
    }
}

struct InputView_Previews: PreviewProvider {
    
    static let text = "enter a field"
    
    static var previews: some View {
        InputView(title: "Field", placeholder: "a number", text: .constant(text))
            .previewLayout(.sizeThatFits)
    
    }
}
