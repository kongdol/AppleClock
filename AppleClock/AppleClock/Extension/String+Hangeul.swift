//
//  String+Hangeul.swift
//  AppleClock
//
//  Created by yk on 2/3/25.
//

import Foundation

extension String {
    var chosung: String? {
        guard trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else {
            return nil
        }
        
        guard let firstChar = first, let unicodeScalar = UnicodeScalar(String(firstChar)) else {
            return nil
        }
        
        // 한글 유니코드 스칼라 범위
        guard (0xAC00 ... 0xD7AF).contains(unicodeScalar.value) else {
            return String(firstChar)
        }
        
        let chosungList = ["ㄱ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ","ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]
        
        // 상수에 초성인덱스 저장됨
        let chosungIndex = (unicodeScalar.value - 0xAC00) / (21*28)
        return chosungList[Int(chosungIndex)]
        
    }
}
