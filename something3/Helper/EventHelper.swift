//
//  EventHelper.swift
//  something3
//
//  Created by 김동현 on 22/12/2018.
//  Copyright © 2018 John Kim. All rights reserved.
//

import Foundation
import EventKit

class EventHelper {
    var eventStore: EKEventStore?
    
    func addEvent(title:String, date:Date) -> Bool {
        let reminder = EKReminder(eventStore: self.eventStore!)
        reminder.title = title
        reminder.calendar = self.eventStore!.defaultCalendarForNewReminders()
        
        let alarm = EKAlarm(absoluteDate: date)
        reminder.addAlarm(alarm)
        
        do {
            try self.eventStore!.save(reminder, commit: true)
        } catch {
            return false
        }
        return true
    }
    
    //func removeEvent(
}
