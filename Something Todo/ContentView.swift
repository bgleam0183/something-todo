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
    var priority: Bool
}

struct ContentView: View {
    @State private var showToast = false
    @State private var toastMsg = ""
    
    @State var todoItems: [TodoItems] = [
        TodoItems(title: "1번 항목", isDone: false, dueDate: nil, priority: false),
        TodoItems(title: "2번 항목", isDone: false, dueDate: nil, priority: false),
        TodoItems(title: "3번 항목", isDone: false, dueDate: .now, priority: false),
        TodoItems(title: "4번 항목", isDone: false, dueDate: Calendar.current.date(byAdding: .day, value: 1, to: .now)!, priority: false),
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
    
    private func toast(_ text: String) {
        toastMsg = text
        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { showToast = false }
        }
    }
    
    private func todoRow(_ item: Binding<TodoItems>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: item.wrappedValue.isDone ? "checkmark.square.fill" : "square")
            Text(item.wrappedValue.title)
                .strikethrough(item.wrappedValue.isDone)
                .foregroundStyle(item.wrappedValue.isDone ?  .secondary : .primary)
                .fontWeight(item.wrappedValue.isDone ? .regular : .bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            item.wrappedValue.isDone.toggle()
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            withAnimation(.smooth) {
                item.wrappedValue.priority.toggle()
            }
            toast(item.wrappedValue.priority ? "우선순위로 지정했어요" : "우선순위 해제했어요")
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }

    
    var body: some View {
        List {
            // 기한 없음
            if !noDueIndices.isEmpty {
                Section("기한 없음") {
                    let indices = noDueIndices.indices.sorted { a, b in
                        if todoItems[a].priority && !todoItems[b].priority {
                            return todoItems[a].priority && !todoItems[b].priority
                        }
                        if todoItems[a].isDone != todoItems[b].isDone {
                            return !todoItems[a].isDone && todoItems[b].isDone
                        }
                        return todoItems[a].title < todoItems[b].title
                    }
                    
                    ForEach(indices, id: \.self) { i in
                        todoRow($todoItems[i])
                    }
                }
            }
            // 날짜별
            ForEach(sortedDueKeys, id: \.self) { key in
                Section(key.formatted(date: .abbreviated, time: .omitted)) {
                    let indices = (dueGroups[key] ?? []).sorted { a, b in
                        if todoItems[a].priority && !todoItems[b].priority {
                            return todoItems[a].priority && !todoItems[b].priority
                        }
                        if todoItems[a].isDone != todoItems[b].isDone {
                            return !todoItems[a].isDone && todoItems[b].isDone
                        }
                        return todoItems[a].title < todoItems[b].title
                    }
                    
                    ForEach(indices, id: \.self) { i in
                        todoRow($todoItems[i])
                    }
                }
            }
        }
        .overlay(alignment: .top) {
            if showToast {
                Text(toastMsg)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

#Preview {
    ContentView()
}
