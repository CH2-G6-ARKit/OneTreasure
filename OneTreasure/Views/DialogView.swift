//
//  DialogView.swift
//  OneTreasure
//
//  Created by Ardelia on 03/06/25.
//



import Foundation
import SwiftUI


struct DialogView: View {
    @ObservedObject var viewModel: DialogViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var showDialog : Bool
    
    
    
    
    var body: some View {
            
        
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
                                print("first page", viewModel.currentIndex)
                                print(viewModel.dialogPages.count)
                                viewModel.nextPage()
                            }label: {
                                Image("rightArrowD")
                            }.buttonStyle(.plain)
                        }else if viewModel.isMiddlePage() {
                            Button(){
                                viewModel.prevPage()
                            }label: {
                                Image("leftArrowD")
                            }.buttonStyle(.plain)
                            Button(){
                                
                                viewModel.nextPage()
                            }label: {
                                Image("rightArrowD")
                            }.buttonStyle(.plain)
                        }else if viewModel.isLastPage() {
                            Button(){
                                print("Continue Button tapped")
                                print("last page", viewModel.currentIndex)
                                withAnimation{
                                    showDialog = false
                                }
                                viewModel.currentIndex = 0
                                
                            }label:{
                                Image("ContinueD")
                            }.buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth:.infinity, alignment: .bottomTrailing)
                    .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 20))
                    .onTapGesture {
                        withAnimation {
                            showDialog = false
                        }
                    }
                    
                    
                    
                }
                .background(Color("AccentColor"))
                //            .padding()
                .border(Color("BorderColorD"), width: 4)
                .cornerRadius(12)
                //                        .offset(y: 200)
                
            }
            .padding(EdgeInsets(top: 90, leading: 5, bottom: 2, trailing: 5))
        
        
    }
}

#Preview {
    @Previewable  var viewModel = DialogViewModel()
    
    DialogView(viewModel: viewModel, showDialog:.constant(true))
}
