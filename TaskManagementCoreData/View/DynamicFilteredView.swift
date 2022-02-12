//
//  DynamicFilteredView.swift
//  TaskManagementCoreData
//
//  Created by nakamura motoki on 2022/02/11.
//

import SwiftUI
import CoreData
//Now we're going to create a Custon view builder which will dynamically filter the core data using NSPredicates and returns the ManagedObjects to define the Views
// Why we need this?
// Since swiftUI @FetchRequest can be called once and cannot be sorted/ filtered, so were writing a Custom View which will dynamically updates the @FetchRequest
struct DynamicFilteredView<Content: View, T>: View where T: NSManagedObject {
    
    // MARK: Core Data Request
    @FetchRequest var request: FetchedResults<T>
    let content: (T) -> Content
    
    // MARK: Building Custom ForEach which will give CoreData object to build View
    init(dateToFilter: Date, @ViewBuilder content : @escaping (T) -> Content){
        
        //Initializing Request with NSPredicate
        _request = FetchRequest(entity: T.entity(), sortDescriptors: [], predicate: nil)
        self.content = content
    }
    var body: some View {
        Group{
            if request.isEmpty{
                Text("No tasks found!!!")
                    .font(.system(size: 16))
                    .fontWeight(.light)
                    .offset(x: 100)
            }
            else{
                
                ForEach(request, id: \.objectID){object in
                    self.content(object)
                }
            }
        }
    }
}
