//
//  ContentView.swift
//  Something Todo
//
//  Created by 구성욱 on 12/29/25.
//

import SwiftUI

struct TodoItems: Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool
    var dueDate: Date?
}

struct ContentView: View {
    @State var todoITems: [TodoItems] = [
        TodoItems(title: "Learn SwiftUI", isDone: false, dueDate: nil),
        TodoItems(title: "Build a SwiftUI app", isDone: false, dueDate: nil),
    ]
    
    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
        HStack {
            
            Spacer()
        }
        .padding()
        
        ForEach($todoITems) { $item in
            HStack {
                Image(systemName: "checkmark.square.fill")
                Toggle(item.title, isOn: $item.isDone)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
