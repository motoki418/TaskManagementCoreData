//
//  TaskViewModel.swift
//  TaskManagementCoreData
//
//  Created by nakamura motoki on 2022/02/11.
//

import SwiftUI

class TaskViewModel: ObservableObject{
    
    // MARK: Current Week Days
    //Let's write a code which will fetch the current week dates(Erom SUn to Sat)
    @Published var currentWeek: [Date] = []
    
    // MARK: Current Day
    // Storing the currentDay(This will be updated when ever user tapped on another date, basedon that tasks will be displayed)
    //currentは現在という意味　今日の日付
    @Published var currentDay: Date = Date()
    
    // MARK: Filtering Today Tasks
    // Filtering the tasks for the date user is selected
    @Published var filteredTasks: [Task]?
    
    //MARK: New Task View
    @Published var addNewTask: Bool = false
    
    // MARK: Edit Data
    //The logic is simple when ever the edit button is clicked it will store the current task in our view model nd triggers the new task view
    @Published var editTask: Task?
    // MARK: Intializing
    // 一番最初に現在の週の日付（日〜土）を取得するfetchCurrentWeekを呼び出す
    init(){
        fetchCurrentWeek()
    }
    
    // 今日を起点に一週間を取得するメソッド
    func fetchCurrentWeek(){
        // 現在の日時を取得
        let today = Date()
        // カレンダーを生成
        let calender = Calendar.current
        
        let week = calender.dateInterval(of: .weekOfMonth, for: today)
        
        guard let firstWeekDay = week?.start else{
            return
        }
        // 7日間を生成
        (1...7).forEach{ day in
            
            if let weekday = calender.date(byAdding: .day, value: day, to: firstWeekDay){
                currentWeek.append(weekday)
            }
        }
    }
    
    // MARK: Extracting Date
    // 日付のフォーマットを定義
    func extractDate(date: Date, format: String) -> String{
        let formatter = DateFormatter()
        
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    // MARK: Checking if current Date is Today
    // When the app is opened we need highlight the currentDay in week days scrollview,
    // In order to do that we need to wirte a function which will verify if the week day is today
    // 今日かどうかを判定して、今日であればtrue、今日以外であればfalseを返すメソッド
    func isToday(date: Date) -> Bool {
        
        let calender = Calendar.current
        
        return calender.isDate(currentDay, inSameDayAs: date)
    }
    
    // MARK: Checking if the currentHour is
    //Writing a code which will verify whether the given task date and time is same as current Date and time(To highlight the Current Hour Tasks)
    // 現在の日時のタスクをハイライト表示するためのメソッド
    func isCurrentHour(date: Date) -> Bool{
        let calender = Calendar.current
        let hour = calender.component(.hour, from: date)
        let currentHour = calender.component(.hour, from: Date())
        
        let isToday = calender.isDateInToday(date)
        // タスクの日時と現在の日時が同じ場合にtrueを返す
        return (hour == currentHour && isToday)
    }
}
