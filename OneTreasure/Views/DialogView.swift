//
//  DialogView.swift
//  OneTreasure
//
//  Created by Ardelia on 03/06/25.
//

//
//  DialogView.swift
//  ARIslandGame
//
//  Created by Ardelia on 22/05/25.
//

import Foundation
import SwiftUI

struct DialogView: View {
    @ObservedObject var viewModel: DialogViewModel
    //    @Binding var isPresented: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        HStack(){
            Spacer()
            Text("ONE TREASURE")
                .font(.largeTitle)
                .bold()
            Spacer()
        }.padding()
        
        
        ScrollView (){
            LazyVStack(alignment:.leading){
                
                Text(viewModel.dialogPages[viewModel.currentIndex].title)
                    .font(.londrinaHeadline)
                    .multilineTextAlignment(.leading)
                    .padding(EdgeInsets(top: 15, leading: 10, bottom: 2, trailing: 10))
                
                ExpandableTextView(text: viewModel.dialogPages[viewModel.currentIndex].description)
                    .font(.kanitRegularBody)
                
                
                HStack(){
                    if viewModel.isfirstPage(){
                        Button(){
                            viewModel.nextPage()
                        }label: {
                            Image("Right Arrow_Colored")
                        }.buttonStyle(.plain)
                    }else if viewModel.isMiddlePage() {
                        Button(){
                            viewModel.prevPage()
                        }label: {
                            Image("Left Arrow_Colored")
                        }.buttonStyle(.plain)
                        Button(){
                            viewModel.nextPage()
                        }label: {
                            Image("Right Arrow_Colored")
                        }.buttonStyle(.plain)
                    }else if viewModel.isLastPage() {
                        Button(){
                            print("Button tapped")
                            dismiss()
                        }label:{
                            Image("Continue")
                        }.buttonStyle(.plain)
                    }
                }
                .frame(maxWidth:.infinity, alignment: .bottomTrailing)
                .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 20))
                
                
                
            }
            .background(Color("AccentColor"))
            .padding()
            .border(Color("BorderColor"), width: 4)
            //                        .offset(y: 200)
            
        } .padding(EdgeInsets(top: 90, leading: 5, bottom: 2, trailing: 5))
    }
}


#Preview {
    @Previewable  var viewModel = DialogViewModel()
    
    DialogView(viewModel: viewModel)
}

