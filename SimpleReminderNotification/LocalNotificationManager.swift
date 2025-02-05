//    MIT License
//
//    Copyright (c) [2025] [Divyesh Pansuriya]
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Foundation
import UserNotifications

enum NotificationPermission {
    case authorized
    case denied
    case unknown
    case notAsked
    case appClips
}

class LocalNotificationManager {
    let center = UNUserNotificationCenter.current()
    
    // Check permission status
    func checkIfRegistered(completion: @escaping (NotificationPermission) -> Void) {
        center.getNotificationSettings { permission in
            switch permission.authorizationStatus {
            case .authorized:
                completion(.authorized)
            case .denied:
                completion(.denied)
            case .ephemeral:
                //Temporary notification for App Clips
                completion(.appClips)
            case .notDetermined:
                completion(.notAsked)
            case .provisional:
                //Authorized to post non-interruptive notification
                completion(.authorized)
            default:
                //Unknown
                completion(.unknown)
            }
        }
    }
    
    // Ask for permission to send push notification
    func registerLocal(completion: @escaping (Bool, Error?) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            completion(granted, error)
        }
    }
    
    // Schedule push notification to be sent
    func schedule(title: String, body: String, id: String, date: Date, repeats: Bool = false) {
        let units: Set<Calendar.Component> = [.minute, .hour, .day, .month, .year]
        let dateComponents = Calendar.current.dateComponents(units, from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        schedule(title: title, body: body, id: id, trigger: trigger)
    }
    
    func schedule(title: String, body: String, id: String, interval: TimeInterval, repeats: Bool = false) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: repeats)
        schedule(title: title, body: body, id: id, trigger: trigger)
    }
    
    private func schedule(title: String, body: String, id: String, trigger: UNNotificationTrigger) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = body
        notificationContent.sound = UNNotificationSound.default
        let trigger = trigger
        let request = UNNotificationRequest(identifier: id, content: notificationContent, trigger: trigger)
        center.add(request)
    }
    
    // Remove push notification
    func removeAllPendingNotifications() {
        center.removeAllPendingNotificationRequests()
    }

    func removePendingNotificationsWithId(ids: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }
    
    func removeNotificationsWithId(ids: [String]) {
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }
    
    // Find push notifications
    func findDeliveredNotifications(completion: @escaping ([UNNotification]) -> Void) {
        center.getDeliveredNotifications { notificationList in
            completion(notificationList)
        }
    }
    
    func findDeliveredNotificationForId(id: String, completion: @escaping (UNNotification?) -> Void) {
        findDeliveredNotifications { notificationList in
            let notification = notificationList.filter { notification -> Bool in
                notification.request.identifier == id
            }.first
            completion(notification)
        }
    }
    
    func findPendingNotificationRequests(completion: @escaping ([UNNotificationRequest]) -> Void) {
        center.getPendingNotificationRequests { notificationRequestList in
            completion(notificationRequestList)
        }
    }
    
    func findPendingNotificationForId(id: String, completion: @escaping (UNNotificationRequest?)->Void) {
        findPendingNotificationRequests { notificationRequestList in
            let notificationRequest = notificationRequestList.filter { request -> Bool in
                request.identifier == id
            }.first
            completion(notificationRequest)
        }
    }
}
