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
    
    init() {
        if self.eventStore == nil {
            self.eventStore = EKEventStore()
            self.eventStore!.requestAccess(to: EKEntityType.reminder, completion: { (isAccessible, errors) in })
        }
    }
    
    func addEvent(title:String, date:Date) -> (result:Bool, identifier:String) {
        let reminder = EKReminder(eventStore: self.eventStore!)
        reminder.title = title
        reminder.calendar = self.eventStore!.defaultCalendarForNewReminders()
        
        let alarm = EKAlarm(absoluteDate: date)
        reminder.addAlarm(alarm)
        
        do {
            try self.eventStore!.save(reminder, commit: true)
        } catch {
            return (false, "")
        }
        return (true, reminder.calendarItemIdentifier)
    }
    
    func removeEvent(identifier:String) -> Bool {
        let predicateForEvents: NSPredicate = self.eventStore!.predicateForReminders(in: [self.eventStore!.defaultCalendarForNewReminders()!])
        
        self.eventStore!.fetchReminders(matching: predicateForEvents, completion: { (reminders)  in
            for reminder in reminders! {
                //if reminder.calendarItemIdentifier == "840D41D6-13C5-4793-80FE-356A758777A5" {
                if reminder.calendarItemIdentifier == identifier {
                    do {
                        try self.eventStore!.remove(reminder, commit: true)
                    } catch {
                        //return false
                    }
                    //return true
                }
            }
            //return false
        })
        
        return true
    }
}
