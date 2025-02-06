//
//  Date+Util.swift
//  AppleClock
//
//  Created by yk on 2/6/25.
//

import Foundation

extension Date {
    private static var lastUpdateMinute: Int? = nil
    
    var minuteChanged: Bool {
        guard let last = Self.lastUpdateMinute else {
            Self.lastUpdateMinute = Calendar.current.component(.minute, from: .now)
            return true
        }
        
        let curretnMin = Calendar.current.component(.minute, from: .now)
        // 두개가 다르다면
        if last != curretnMin {
            Self.lastUpdateMinute = curretnMin
            return true
        }
        
        return false
    }
}
