//
//  TimeZone+Util.swift
//  AppleClock
//
//  Created by yk on 1/30/25.
//

import Foundation

fileprivate let formatter = DateFormatter()

extension TimeZone {
    var currentTime: String? {
        formatter.timeZone = self
        formatter.dateFormat = "h:mm"
        
        return formatter.string(from: .now)
    }
    
    var timePeriod: String? {
        formatter.timeZone = self
        formatter.dateFormat = "a" // 오전, 오후
        
        return formatter.string(from: .now)
    }
    
    var city: String? {
       // Asia/Seoul
    
    }
}
