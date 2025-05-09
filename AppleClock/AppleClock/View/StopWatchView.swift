//
//  StopWatchView.swift
//  AppleClock
//
//  Created by yk on 5/9/25.
//

import UIKit

class StopWatchView: UIView {

    override func draw(_ rect: CGRect) {
        drawTicks(count: 240, length: 5, width: 2, color: .systemGray3)
        drawTicks(count: 60, length: 10, width: 2, color: .systemGray3)
        drawTicks(count: 12, length: 10, width: 2, color: .white)
        drawSecond()
    }
    
    private func drawTicks(count: Int, length: CGFloat, width: CGFloat, color: UIColor) {
        let path = UIBezierPath()
        path.lineWidth = width
        color.setStroke()
        
        for i in 0..<count {
            let angle = CGFloat(Double.pi * 2 * Double(i) / Double(count))
            
            let startPoint = CGPoint(x: clockCenter.x + (radius - length) * cos(angle),
                                     y: clockCenter.y - (radius - length) * sin(angle))
            
            let endPoint = CGPoint(x: clockCenter.x + radius * cos(angle),
                                   y: clockCenter.y - radius * sin(angle))
            
            path.move(to: startPoint)
            path.addLine(to: endPoint)
        }
        
        path.stroke()
        
    }

    private func drawSecond() {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: bounds.width * 0.08),
            .foregroundColor: UIColor.white
        ]
        
        for i in 0 ..< 12 {
            let angle = CGFloat(Double.pi * 2 * Double(-i) / 12) + .pi / 2
            let text = "\(i == 0 ? 60 : i * 5)"
            let textSize = text.size(withAttributes: attrs)
            let textPoint = CGPoint(x: clockCenter.x + (radius - bounds.width * 0.1) * cos(angle) - textSize.width / 2,
                                    y: clockCenter.y - (radius - bounds.width * 0.1) * sin(angle) - textSize.height / 2)
            text.draw(at: textPoint, withAttributes: attrs)
        }
    }
    
    var clockCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    var radius: CGFloat {
        return min(bounds.width, bounds.height) * 0.45
    }
}
@available(iOS 17, *)
#Preview {
    let v = UIView(frame: .zero)
    v.translatesAutoresizingMaskIntoConstraints = false
    
    let stopwatchView = StopWatchView(frame: .zero)
    stopwatchView.translatesAutoresizingMaskIntoConstraints = false
    stopwatchView.widthAnchor.constraint(equalToConstant: 300).isActive = true
    stopwatchView.heightAnchor.constraint(equalToConstant: 300).isActive = true
    
    v.addSubview(stopwatchView)
    
    stopwatchView.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
    stopwatchView.centerYAnchor.constraint(equalTo: v.centerYAnchor).isActive = true
    
    return v
}
