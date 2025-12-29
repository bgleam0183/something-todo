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
    @State var todoItems: [TodoItems] = [
        TodoItems(title: "1번 항목", isDone: false, dueDate: nil),
        TodoItems(title: "2번 항목", isDone: false, dueDate: nil),
        TodoItems(title: "3번 항목", isDone: false, dueDate: .now),
        TodoItems(title: "4번 항목", isDone: false, dueDate: Calendar.current.date(byAdding: .day, value: 1, to: .now)!),
    ]
    
    private var noDueIndices: [Int] {
        todoItems.indices.filter { todoItems[$0].dueDate == nil }
    }

    private var dueGroups: [Date: [Int]] {
        var dict: [Date: [Int]] = [:]
        let cal = Calendar.current
        
        for i in todoItems.indices {
            guard let due = todoItems[i].dueDate else { continue }
            let key = cal.startOfDay(for: due)   // ✅ 시간 제거(날짜 키)
            dict[key, default: []].append(i)
        }
        return dict
    }

    private var sortedDueKeys: [Date] {
        dueGroups.keys.sorted()
    }
    
    private func todoRow(_ item: Binding<TodoItems>) -> some View {
        Button {
            item.wrappedValue.isDone.toggle()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: item.wrappedValue.isDone ? "checkmark.square.fill" : "square")
                Text(item.wrappedValue.title)
                    .strikethrough(item.wrappedValue.isDone)
                    .foregroundStyle(item.wrappedValue.isDone ?  .secondary : .primary)
                    .fontWeight(item.wrappedValue.isDone ? .regular : .bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }

    
    var body: some View {
        List {
            // 기한 없음
            if !noDueIndices.isEmpty {
                Section("기한 없음") {
                    ForEach(noDueIndices, id: \.self) { i in
                        todoRow($todoItems[i])
                    }
                }
            }
            // 날짜별
            ForEach(sortedDueKeys, id: \.self) { key in
                Section(key.formatted(date: .abbreviated, time: .omitted)) {
                    let indices = dueGroups[key] ?? []
                    
                    ForEach(indices, id: \.self) { i in
                        todoRow($todoItems[i])
                    }
                }
            }
        }
        
//        ForEach($todoItems) { $item in
//            Button {
//                item.isDone.toggle()
//            } label: {
//                HStack(spacing: 12) {
//                    Image(systemName: item.isDone ? "checkmark.square.fill" : "square")
//                    Text(item.title)
//                        .strikethrough(item.isDone)
//                        .foregroundStyle(item.isDone ?  .secondary : .primary)
//                        .fontWeight(item.isDone ? .regular : .bold)
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            .buttonStyle(.plain)
//            .padding(5)
//        }
    }
}

#Preview {
    ContentView()
}
