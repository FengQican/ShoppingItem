//
//  ContentView.swift
//  ShoppingItems
//
//  Created by Marc Harvey on 05/01/2020.
//  Copyright © 2020 Marc Harvey. All rights reserved.
//
import SwiftUI
import MapKit

///Images used across the ContentView
enum ContentViewImages: String {
    case cuteWeeImage = "cuteWee" ///Will take user to the MapVIew
    case plusImage = "plusIcon" ///On the textEntry field and will let the user add an item
}

struct ContentView: View {
    
    //MARK: - Properties
    @State private var newShoppingItem = ""
    @State var showsAlert = false
    let characterEntryLimit = 60
    let generator = UINotificationFeedbackGenerator()
    @Environment (\.managedObjectContext) var managedObjectContext
    @Environment (\.presentationMode) var presentationMode
    @FetchRequest(fetchRequest: ShoppingItem.getAllShoppingItems()) var shoppingItemsFetch:FetchedResults<ShoppingItem>
    
    //MARK: Setting the empty/potential cells to the desired blue colour
    init() {
        UITableView.appearance().backgroundColor = .init(red: 0.07, green: 0.45, blue: 0.87, alpha: 1)
        UITableView.appearance().separatorInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        ///For the unpopulated cells: the separators will be clear
        UITableView.appearance().separatorColor = .clear
    }
    
    //MARK: - Body of the view
    var body: some View {
        NavigationView {
            ZStack{
                Color.init(red: 0.07, green: 0.45, blue: 0.87)
                    .edgesIgnoringSafeArea(.all)
                
                //MARK: - Start of the list and it's defining elements
                List{
                    Section(header: HStack{
                        Text("Enter What You Need Here")
                            .underline()
                            .padding(10)
                            .font(Font.system(size: 30, design: .rounded))
                            .foregroundColor(.yellow)
                            .textCase(.none)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(3)
                    .background(Color.init(red: 0.07, green: 0.45, blue: 0.87))
                    .listRowInsets(EdgeInsets())
                    ){
                        
                        //MARK: - TextEntry field
                        
                        HStack {
                            ///$newShoppingItem to get the binding to the state newShoppingItem
                            TextField("Type here", text: self.$newShoppingItem)
                                .foregroundColor(.white)
                                
                                ///If the entered text in this field exceeds 'characterEntryLimit' then the field is disabled
                                .disabled(newShoppingItem.count > (characterEntryLimit - 1))
                            
                            ///Uses the two entities of model and then applies them to shoppingItemNew variable
                            Button(action: {
                                let shoppingItemNew = ShoppingItem(context: self.managedObjectContext)
                                shoppingItemNew.itemToBeAdded = self.newShoppingItem
                                
                                ///Will just print the error for the time being should it be unable to save the new entries
                                do {
                                    try self.managedObjectContext.save()
                                } catch {
                                    Alert(title: Text("Unable to save that one"), message: Text("Please try again"), dismissButton: .default(Text("Okay")))
                                }
                                
                                ///Resets the newShoppingItem back to being blank
                                self.newShoppingItem = ""
                                
                                ///Haptic feedback for when the user has tapped on the Add/Plus button
                                self.generator.notificationOccurred(.success)
                                
                            }) {
                                Image (ContentViewImages.plusImage.rawValue)
                                    .foregroundColor(.black)
                                    .imageScale(.large)
                            }
                                ///Have disabled the newShoppingItem text unless there is some text within the field. Button won't add empty entries now
                                .frame (height: 60)
                                .disabled(self.newShoppingItem.isEmpty)
                        }
                        .font(.headline)
                    }
                        ///Sets the background colour for the text entry box
                        .listRowBackground(Color.init(red: 0.07, green: 0.45, blue: 0.87))
                    
                    //MARK: - HStack that deals with how the cells are displayed and populated
                    Section (header: HStack {
                        Text("Items Needed")
                            .underline()
                            .padding(10)
                            .font(.title)
                            .foregroundColor(.yellow)
                            .textCase(.none)
                            .frame(maxWidth: .infinity )
                    }
                    .padding(3)
                    .background(Color.init(red: 0.07, green: 0.45, blue: 0.87))
                    .listRowInsets(EdgeInsets()))
                    {
                        
                        ///Iterates through the model and fetches any entries from the ShoppingItem model
                        ForEach(self.shoppingItemsFetch) { shoppingItemNew in
                            ShoppingItemNewView(itemToBeAdded: shoppingItemNew.itemToBeAdded!)
                            
                            ///.onDelete does the heavy lifting for removing an item
                            ///Items must be on ForEach or else can't be applied
                        } .onDelete {indexSet in
                            let deleteItem = self.shoppingItemsFetch[indexSet.first!]
                            self.managedObjectContext.delete(deleteItem)
                            
                            ///Haptic feedback for when the user taps on Delete
                            self.generator.notificationOccurred(.error)
                        }
                            ///Sets background colour to the desired blue
                            .listRowBackground(Color.init(red: 0.07, green: 0.45, blue: 0.87))
                    }
                    .listStyle(PlainListStyle())
                }
                    
                    //MARK: - NavigationBarItems: Leading item will be the EditButton that lets the user edit the list, the trailing launches MapView
                    .navigationBarItems(leading: EditButton(),
                                        trailing: NavigationLink(destination: MapView()
                                            .navigationBarTitle("Shops Nearby")
                                            .frame(minWidth: 0, idealWidth: 0, maxWidth: .infinity, minHeight: 0, idealHeight: 0, maxHeight: .infinity, alignment: .center)
                                            .edgesIgnoringSafeArea(.all)
                                        ){
                                            ///Image of the trailing icon tha leads the user to the map
                                            Image(ContentViewImages.cuteWeeImage.rawValue)
                                        })
                    .foregroundColor(.white)
                    
                    ///Light blue colour that appears on the populated cells and the text entry box
                    .listRowBackground(Color.init(red: 0.07, green: 0.45, blue: 0.87))
                    .padding(.trailing, 5)
                    .padding(.leading, 5)
                    .padding(.top, 4)
                    .padding(.bottom, 4)
                
            }
        }
            ///Removes the split view from iPad versions
            .navigationViewStyle(StackNavigationViewStyle())
    }
}

extension View {
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct KeyboardAvoiderDemo: View {
    @State var text = ""
    var body: some View {
        VStack {
            TextField("Demo", text: self.$text)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {}
        .onLongPressGesture(
            pressing: { isPressed in if isPressed { self.endEditing() } },
            perform: {})
    }
}