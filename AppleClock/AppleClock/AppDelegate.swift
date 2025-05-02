//
//  AppDelegate.swift
//  AppleClock
//
//  Created by yk on 1/29/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func setupCategory() {
        let remindLaterAction = UNNotificationAction(identifier: ActionIdentifier.remindLater.rawValue, title: "다시 알림", icon: UNNotificationActionIcon(systemImageName: "zzz"))
        
        let stopAction = UNNotificationAction(identifier: ActionIdentifier.stop.rawValue, title: "중단", icon: UNNotificationActionIcon(systemImageName: "stop.circle"))
        
        let alarmCategory = UNNotificationCategory(identifier: CategoryIdentifier.alarm.rawValue, actions: [remindLaterAction, stopAction], intentIdentifiers: [])
        
        // 셋으로 전달하면 됨
        UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupCategory()
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // 클로저를 넘겨서 직접 호출해야 하는 방식
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.banner, .sound])
//    }
    
    // 자동으로 흐름과 메모리를 관리해주는 방식
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        
        Task {
            let pendingList = await UNUserNotificationCenter.current().pendingNotificationRequests().map {
                $0.identifier
            }
            
            // 엔티티에 액티베이트속성 업데이트
            DataManager.shared.refreshActivationState(pendingIds: pendingList)
        }
        
        return [.banner, .sound]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        // code (리턴안해도됨)
        // print(#function)
        
        
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier :
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate,
               let tabBarController = sceneDelegate.window?.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 1
            }
        case ActionIdentifier.remindLater.rawValue:
            let content = response.notification.request.content
            
            let date = Date(timeIntervalSinceNow: 10)
            let comp = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: comp, repeats: false)
            
            var id = response.notification.request.identifier + "-remind"
            if !id.contains("-remind") {
                id.append("-remind")
            }
            
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print(error)
            }
            
            // 중단했을때 기능 추가하고싶으면
        case ActionIdentifier.stop.rawValue:
            // Code
            break
        default:
            break
        }
        
    }
}
