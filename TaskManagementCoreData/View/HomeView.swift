//
//  HomeView.swift
//  TaskManagementCoreData
//
//  Created by nakamura motoki on 2022/02/11.
//

import SwiftUI

struct HomeView: View {
    
    // TaskViewModelを監視
    @StateObject private var taskViewModel: TaskViewModel = TaskViewModel()
    
    // 名前空間
    @Namespace var animation
    
    // MARK: Core Data Context
    @Environment(\.managedObjectContext) var context
    
    // MARK: Core Data Context
    // Contextは環境という意味
    @Environment(\.editMode) var editButton
    
    var body: some View {
        // Our home view basically consists of a horizontal scrollview which will allows us to select a date from current week
        // Below that all the tasks of the selected date will be displayed and the if the current hour is having any task, that will be highlighted
        ScrollView(.vertical, showsIndicators: false){
            
            // MARK: Lazy Stack With Pinned Header
            LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]){
                
                Section{
                    // MARK: Current Week View
                    // ScrollViewは縦横にスクロール可能なViewを生成する
                    // 【引数】axis
                    //スクロール方向を .vertical（縦方向）か .horizontal（横方向）のいずれかで指定
                    //[.vertical, .horizontal] と配列形式で指定すると縦横両方へのスクロールが可能となる
                    //未指定の場合、デフォルト値は .vertial
                    // 【引数】showIndicators
                    //スクロールインジケーターの表示/非表示をBool値で指定
                    //未指定の場合、デフォルト値は true（表示）
                    ScrollView(.horizontal, showsIndicators: false){
                        
                        HStack(spacing: 10){
                            
                            ForEach(taskViewModel.currentWeek, id: \.self){ day in
                                // 日付と曜日を表示
                                VStack(spacing: 10){
                                    Text(taskViewModel.extractDate(date: day, format: "dd"))
                                        .font(.system(size: 15))
                                        .fontWeight(.semibold)
                                    // EEE will return day as MON,TUE,.....etc
                                    // 日付のフォーマットはTaskViewModelにあるextractDateメソッドを呼び出して決める
                                    // 曜日で表示
                                    Text(taskViewModel.extractDate(date: day, format: "EEE"))
                                        .font(.system(size: 14))
                                    
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 8, height: 8)
                                    // TaskViewModelのisTodayメソッドを利用して今日の日付だけ白丸を表示する
                                        .opacity(taskViewModel.isToday(date: day) ? 1 : 0 )
                                }// VStack(spacing: 10)
                                // MARK: Foreground Style
                                .foregroundStyle(taskViewModel.isToday(date: day) ? .primary : .secondary)
                                // 今日の日付と曜日の文字色を白に　今日以外の日付と曜日の文字色を黒に
                                .foregroundColor(taskViewModel.isToday(date: day) ? .white : .black)
                                // MARK: Capsule Shape
                                .frame(width: 45, height: 90)
                                .background(
                                    ZStack{
                                        // MARK: Matched Geometry Effect
                                        // Adding Matched Geometry Animation when a Week day is changed
                                        // 今日の日付のみ日付・曜日・黒丸・白丸を表示
                                        if taskViewModel.isToday(date: day){
                                            Capsule()
                                                .fill(.black)
                                                .matchedGeometryEffect(id: "CURRNTDAY", in: animation)
                                        }
                                    }// ZStack
                                )// .background
                                .contentShape(Capsule())
                                // 日付をタップしたときに黒カプセルを移動させる
                                .onTapGesture {
                                    // Updating Current Day
                                    withAnimation{
                                        taskViewModel.currentDay = day
                                    }
                                }//  .onTapGesture
                            }//ForEach
                        }// HStack(spacing: 10)
                        .padding(.horizontal)
                    }// ScrollView(.horizontal, showsIndicators: false)
                    TasksView()
                }header: {
                    HeaderView()
                }// Section
            }// LazyVStack
        }// ScrollView(.vertical, showsIndicators: false)
        .ignoresSafeArea(.container, edges: .top)
        
        // MARK: Add Button
        .overlay(
            
            Button{
                taskViewModel.addNewTask.toggle()
            }label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black,in: Circle())
            }
                .padding()
            
            ,alignment: .bottomTrailing
        )
        //In our New Task view it will check if the view model contains any edit task data, if so then it will display the already stored task info and allows the user to edit them(but not and whenever the new task view is dismissed, we're the clearing the edit task data in the view modell(to avoid unnecessary bhus)
        .sheet(isPresented: $taskViewModel.addNewTask){
            // Clearing Edit Data
            taskViewModel.editTask = nil
        }content:{
            NewTaskView()
                .environmentObject(taskViewModel)
        }
    }// body
    
    // MARK: Tasks View
    // Let's build the Tasks View, which will update dynamically when ever user is tapped on another date
    func TasksView() -> some View {
        LazyVStack(spacing: 20){
            // Converting object as Our TaskModel
            DynamicFilteredView(dateToFilter: taskViewModel.currentDay){ (object: Task) in
                TaskCardView(task: object)
            }
        }// LazyVStack
        .padding()
        .padding(.top)
    }// TasksView()
    
    
    // MARK: Task Card View
    func TaskCardView(task: Task) -> some View{
        // Let's create the Card View for each Task
        // MARK: Since CoreData Values will Give Optional data
        HStack(alignment: editButton?.wrappedValue == .active ? .center : .top, spacing: 30){
            // If the editbutton is active then hiding the timeline view and showing the edit actons(delete update)
            if editButton?.wrappedValue == .active{
                // Edit Button for Current and Future Tasks
                //Update task button will only visible if the task is current/future but not for the past tasks!
                VStack(spacing: 12){
                    
                    if task.taskDate?.compare(Date()) == .orderedDescending || Calendar .current.isDateInToday(task.taskDate ?? Date()){
                        Button{
                            
                            taskViewModel.editTask = task
                            taskViewModel.addNewTask.toggle()
                        }label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title)
                                .foregroundColor(.primary)
                        }
                    }
                    Button{
                        //MARK: Deleting Task
                        context.delete(task)
                        
                        // Saving
                        try? context.save()
                        
                    }label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                    
                }
                
            }
            else{
                // 黒丸と黒線を縦並びに
                VStack(spacing: 10){
                    // 内側の黒丸
                    Circle()
                    //現在の日時と同じ日時のタスクのみタスク名の左側に表示している丸の色を黒にする
                        .fill(taskViewModel.isCurrentHour(date: task.taskDate ?? Date()) ? (task.isCompleted ? .green : .black) : .clear)
                        .frame(width: 15, height: 15)
                        .background(
                            // 外側の細い円
                            Circle()
                                .stroke(.black, lineWidth: 1)
                                .padding(-3)
                        )
                    // 現在の日時と同じ日時のタスクのみ丸を大きくする
                    // 引数の先頭に！をつけているので、現在の日時と違う日時のタスクの丸の大きさを0.5にする
                        .scaleEffect(!taskViewModel.isCurrentHour(date: task.taskDate ?? Date()) ? 0.5 : 1)
                    Rectangle()
                        .fill(.black)
                        .frame(width: 3)
                }// VStack
            }// if文
            VStack{
                HStack(alignment: .top, spacing: 10){
                    VStack(alignment: .leading, spacing: 12){
                        Text(task.taskTitle ?? "")
                            .font(.title2.bold())
                        Text(task.taskDescription ?? "")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }// VStack(alignment: .leading, spacing: 12)
                    .hLeading()
                    Text(task.taskDate?.formatted(date: .omitted, time: .shortened ) ?? "")
                }// HStack(alignment: .top, spacing: 10)
                
                // Highlighting Current Tasks
                // 現在の日時と同じ日時のタスクのみチームメンバーの画像とチェックマークを表示する
                if taskViewModel.isCurrentHour(date: task.taskDate ?? Date()){
                    // MARK: Team Members
                    // チームメンバーの画像を表示
                    HStack(spacing: 12){
                        // MARK: Check Button
                        if !task.isCompleted{
                            Button{
                                // MARK: Updating Task
                                task.isCompleted = true
                                
                                //Saving
                                try? context.save()
                            }label: {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.black)
                                    .padding(10)
                                    .background(.white, in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        Text(task.isCompleted ? "Marked as Completed" : "Mark Task s Completed")
                            .font(.system(size: task.isCompleted ? 14 :16, weight: .light))
                            .foregroundColor(task.isCompleted ? .gray : .white)
                            .hLeading()
                    }// HStack(spacing: 0)
                    .padding(.top)
                }
            }// VStack
            // 現在の日時と同じ日時のタスクのみ文字色を白にする
            .foregroundColor(taskViewModel.isCurrentHour(date: task.taskDate ?? Date()) ? .white : .black)
            // 現在の日時と同じ日時のタスクのみ余白を空ける
            .padding(taskViewModel.isCurrentHour(date: task.taskDate ?? Date()) ? 15 : 0)
            // 現在の日時と違う日時のタスクの下の余白を10空ける
            .padding(.bottom, taskViewModel.isCurrentHour(date: task.taskDate ?? Date()) ? 0 : 10)
            .hLeading()
            .background(
                Color("Black")
                    .cornerRadius(25)
                // 現在の日時と同じ日時のタスクのみ背景色の黒色を不透明にする
                    .opacity(taskViewModel.isCurrentHour(date: task.taskDate ?? Date()) ? 1 : 0)
            )
        }// HStack
        // 左寄せにする
        .hLeading()
    } // TaskCardView()
    
    // MARK: Header
    func HeaderView() -> some View{
        HStack(spacing: 10){
            VStack(alignment: .leading, spacing: 10){
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .foregroundColor(.gray)
                Text("Today")
                    .font(.largeTitle.bold())
            }// VStack
            // Textを左寄せ
            .hLeading()
            
            // MARK: Edit Button
            EditButton()
        }// HStack
        .padding()
        .padding(.top, getSafeArea().top)
        .background(.white)
    }// HeaderView()
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}


// MARK: UI Design Helper functions
// Viewの位置を決める
extension View{
    // 左寄せ
    func hLeading() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    // 右寄せ
    func hTrailing() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    // 中央に
    func hCenter() -> some View {
        self
            .frame(maxHeight: .infinity, alignment: .center)
    }
    
    //MARK: Safe Area
    func getSafeArea() -> UIEdgeInsets{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{
            return .zero
        }
        guard let safeArea = screen.windows.first?.safeAreaInsets else {
            return .zero
        }
        return safeArea
    }
}
