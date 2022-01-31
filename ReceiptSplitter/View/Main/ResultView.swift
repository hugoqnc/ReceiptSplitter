//
//  ResultView.swift
//  ReceiptSplitter
//
//  Created by Hugo Queinnec on 08/01/2022.
//

import SwiftUI
import UIKit

struct ResultView: View {
    @EnvironmentObject var model: ModelData
    @State private var showAllList = false
    @State private var showUserDetails = false
    @State private var selectedUser = User()
    @State private var showSharingOptions = false
    @State private var showIndividualSharingOptions = false
    @State private var chosenSharingOption = ""
    
    func fontSizeProportionalToPrice(total: Double, price: Double) -> Double {
        let minSize = 12.0
        let maxSize = 35.0
        var size = 20.0
        if !(total==0.0){
            size = minSize + (price/total)*(maxSize-minSize)
        }
        return size
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    VStack{
                        Text("Total".uppercased())
                            .font(.title2)
                        Text(model.showPrice(price: model.totalBalance))
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                    }
                    .padding(.top,25)
                    .padding(.bottom,15)
                    
                    HStack {
                        Spacer()
                        
                        Menu {
                            Button {
                                chosenSharingOption = "overview"
                                showSharingOptions = true
                            } label: {
                                Label("Share overview", systemImage: "doc.text")
                            }
                            
                            Button {
                                chosenSharingOption = "details"
                                showSharingOptions = true
                            } label: {
                                Label("Share detailed results", systemImage: "doc.text.fill")
                            }
                            
                            Button {
                                chosenSharingOption = "scan"
                                showSharingOptions = true
                            } label: {
                                Label("Share scanned receipt", systemImage: "doc.text.viewfinder")
                            }
                        } label: {
                            Label("See all", systemImage: "square.and.arrow.up")
                                .labelStyle(.iconOnly)
                        }
                        .padding(.trailing, 30)
                        .padding(.bottom,60)
                        .background(SharingViewController(isPresenting: $showSharingOptions) {
                            var toShare: [Any] = []
                            
                            if chosenSharingOption=="overview" {
                                toShare = [model.sharedText]
                            } else if chosenSharingOption=="details" {
                                toShare = [model.sharedTextDetailed]
                            } else if chosenSharingOption=="scan" {
                                let images = model.images.map { i in
                                    return i.image ?? UIImage()
                                }
                                toShare = images
                            }
                            
                            let av = UIActivityViewController(activityItems: toShare, applicationActivities: nil)
                            av.completionWithItemsHandler = { _, _, _, _ in
                                showSharingOptions = false
                            }
                            return av
                        })
                        
                    }
                }
                
                
                ScrollView {
                    ForEach(model.users.sorted(by: {model.balance(ofUser: $0)>model.balance(ofUser: $1)})) { user in
                        HStack {
                            HStack {
                                Button {
                                    selectedUser = user
                                    showUserDetails = true
                                } label: {
                                    Image(systemName: "person")
                                        .font(.title2)
                                    
                                    VStack(alignment: .leading) {
                                        Text(user.name)
                                            .font(.title3)
                                        Text("\(model.chosenItems(ofUser: user).count) items")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text(model.showPrice(price: model.balance(ofUser: user)))
                                        .fontWeight(.semibold)
                                        .font(.system(size: fontSizeProportionalToPrice(total: model.totalBalance, price: model.balance(ofUser: user))))
                                        .foregroundColor(.primary)
                                }
                                
                                Button {
                                    selectedUser = user
                                    showIndividualSharingOptions = true
                                } label: {
                                    Label("See all", systemImage: "square.and.arrow.up")
                                        .labelStyle(.iconOnly)
                                }
                                .padding(.leading,7)
                                .padding(.bottom,4)
                                .background(SharingViewController(isPresenting: $showIndividualSharingOptions) {
                                     let av = UIActivityViewController(activityItems: [model.individualSharedText(ofUser: selectedUser)], applicationActivities: nil)
                                     av.completionWithItemsHandler = { _, _, _, _ in
                                         showIndividualSharingOptions = false
                                    }
                                    return av
                                })
                                
                            }
                            .padding()
                        }
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    VStack {
                        HStack {
                            Spacer()
                            
                            StatisticRectangle(iconString: "number", description: "Number of\npurchases", value: String(model.listOfProductsAndPrices.count), color: Color.blue)
                            
                            StatisticRectangle(iconString: "cart", description: "Average price\nof an item", value: String(round((model.totalPrice/Double(model.listOfProductsAndPrices.count))*100) / 100.0)+model.currency.value, color: Color.orange)
                            
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            
                            StatisticRectangle(iconString: "arrow.up.right.circle", description: "Maximum price\nof an item", value: String(round((model.listOfProductsAndPrices.map({ pair in
                                pair.price
                            }).max() ?? 0.0)*100) / 100.0)+model.currency.value, color: Color.green)
                            
                            StatisticRectangle(iconString: "arrow.down.right.circle", description: "Minimum price\nof an item", value: String(round((model.listOfProductsAndPrices.map({ pair in
                                pair.price
                            }).min() ?? 0.0)*100) / 100.0)+model.currency.value, color: Color.red)
                            
                            Spacer()
                        }
                    }
                    .padding(10)
                    
                    Text("\(selectedUser.name) \(chosenSharingOption)") //due to https://developer.apple.com/forums/thread/652080
                         .hidden()
                }
                
            }
            //.navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        withAnimation() {
                            model.eraseModelData()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Done")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(7)
                }
            }
            .sheet(isPresented: $showAllList, content: {
                ListSheetView(itemCounter: -1)
            })
//            .sheet(isPresented: $showSharingOptions, content: {
//                VStack(alignment: .leading) {
//                    Text("Choose how you want to share these results")
//                        .font(.caption)
//                        .foregroundColor(Color.secondary)
//                        .padding(.leading, 3)
//
//                    Picker("Currency", selection: $chosenSharingOption.animation()) {
//                        ForEach(sharingOptions, id: \.self, content: { sharingOption in
//                            Text(sharingOption)
//                        })
//                    }
//                    .pickerStyle(.segmented)
//                }
//                .padding()
//
//                Group {
//                    if chosenSharingOption=="Overview" {
//                        ActivityViewController(activityItems: [model.sharedText])
//                            .edgesIgnoringSafeArea(.bottom)
//                    } else if chosenSharingOption=="Detailed" {
//                        ActivityViewController(activityItems: [model.sharedTextDetailed])
//                            .edgesIgnoringSafeArea(.bottom)
//                    } else if chosenSharingOption=="Scan" {
//                        let images = model.images.map { i in
//                            return i.image ?? UIImage()
//                        }
//                        ActivityViewController(activityItems: images)
//                            .edgesIgnoringSafeArea(.bottom)
//                    }
//                }
//            })

            .sheet(isPresented: $showUserDetails, content: {
                UserChoicesView(user: selectedUser)
            })
        }
        .transition(.move(edge: .bottom))
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SharingViewController: UIViewControllerRepresentable {
    @Binding var isPresenting: Bool
    var content: () -> UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresenting {
            uiViewController.present(content(), animated: true, completion: nil)
        }
    }
}

struct ResultView_Previews: PreviewProvider {
    static let model: ModelData = {
        var model = ModelData()
        model.images = [IdentifiedImage(id: "1111", image: UIImage(named: "scan1")), IdentifiedImage(id: "2222", image: UIImage(named: "scan2"))]
        model.users = [User(name: "Hugo"), User(name: "Lucas"), User(name: "Thomas")]
        model.listOfProductsAndPrices = [PairProductPrice(id: "D401ECD5-109F-408D-A65E-E13C9B3EBDBB", name: "Potato Wedges 1kg", price: 4.99), PairProductPrice(id: "D401ECD5-109F-408D-A65E-E13C9B3EBDBC", name: "Finger Fish", price: 1.27), PairProductPrice(id: "D401ECD5-109F-408D-A65E-E13C9B3EBDBD", name: "Ice Cream Strawberry", price: 3.20)]
        model.listOfProductsAndPrices[0].chosenBy = [model.users[0].id]
        model.listOfProductsAndPrices[1].chosenBy = [model.users[0].id, model.users[1].id]
        model.listOfProductsAndPrices[2].chosenBy = [model.users[0].id, model.users[1].id, model.users[2].id]
        return model
    }()
    
    static var previews: some View {
        ResultView()
            .environmentObject(model)
    }
}
