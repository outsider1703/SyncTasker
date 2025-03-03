//
//  Array+Ext.swift
//  SyncTasker
//
//  Created by ingvar on 23.02.2025.
//

import Foundation

extension Array where Element == TaskItem {
    func groupByAppointmentDate() -> (appointmentTasks: [Date: [TaskItem]], backlogTasks: [TaskItem]) {
        let calendar = Calendar.current
        
        let (withAppointment, withoutAppointment) = self.reduce(into: ([TaskItem](), [TaskItem]())) { result, task in
            if task.appointmentDate != nil {
                result.0.append(task)
            } else {
                result.1.append(task)
            }
        }
        
        let groupedAppointmentTasks = Dictionary(grouping: withAppointment) { task in
            guard let date = task.appointmentDate else { return Date() }
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            return calendar.date(from: components) ?? date
        }
        
        return (appointmentTasks: groupedAppointmentTasks, backlogTasks: withoutAppointment)
    }
}
