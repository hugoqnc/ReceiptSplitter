//
//  InputItemDetails.swift
//  ReceiptSplitter
//
//  Created by Hugo Queinnec on 28/01/2022.
//

import SwiftUI

struct InputItemDetails: View {
    internal init(title: String, message: String, placeholder1: String = "", placeholder2: String = "", initialText: String? = nil, initialDouble: Double? = nil, accept: String = "OK", cancel: String = "Cancel", action: @escaping (String?, Double?) -> ()) {
        self.title = title
        self.message = message
        self.placeholder1 = placeholder1
        self.placeholder2 = placeholder2
        self.initialText = initialText
        self.initialDouble = initialDouble
        self.accept = accept
        self.cancel = cancel
        self.action = action
        
        if initialText != nil {
            _textState = State(initialValue: initialText!)
        } else {
            _textState = State(initialValue: "")
        }
        if initialDouble != nil {
            _doubleState = State(initialValue: initialDouble!)
        } else {
            _doubleState = State(initialValue: 0.0)
        }
    }
    
    @EnvironmentObject var model: ModelData
    @Environment(\.dismiss) var dismiss
    
    var title: String
    var message: String
    var placeholder1: String = ""
    var placeholder2: String = ""
    var initialText: String?
    var initialDouble: Double?
    var accept: String = "OK"
    var cancel: String = "Cancel"
    var action: (String?, Double?) -> ()
    
    @State private var textState: String
    @State private var doubleState: Double
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        TextField(placeholder1, text: $textState)
                            .listRowBackground(Color.secondary.opacity(0.1))
                        TextField(model.showPrice(price: doubleState), value: $doubleState, format: .number)
                            .listRowBackground(Color.secondary.opacity(0.1))
                            .keyboardType(.decimalPad)

                    } header: {
                        Text("Item details")
                    }
                }
//                .onAppear {
//                    if initialText != nil {
//                        textState = initialText!
//                    }
//                    if initialDouble != nil {
//                        doubleState = initialDouble!
//                    }
//                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        action(nil,nil)
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.red)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        action(textState, doubleState)
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
            .navigationBarTitle(Text(""), displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct InputItemDetails_Previews: PreviewProvider {
    static var previews: some View {
        InputItemDetails(title: "Modify item",
                         message:"You can change the name and the price of this item",
                         placeholder1: "Name",
                         placeholder2: "Price",
                         initialText: "Potato Wedges",
                         initialDouble: 3.85,
                         action: {_,_ in 
                          })
    }
}
