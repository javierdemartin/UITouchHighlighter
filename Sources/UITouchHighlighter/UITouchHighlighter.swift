//
//  UITouchHighlighter.swift
//
//  Created by Javier de Martín Gil on 22/5/21.
//

import Foundation
import UIKit
import Combine

class UITouchHighlighter: UIWindow {
    
    var fingertip: UserFingertipView?

    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        
        let events = event.allTouches?.compactMap({ $0 }) ?? []
        
        for touch in events {
            
            let t = touch.location(in: self)
            
            switch touch.phase {
            
            case .began, .moved:
                                
                fingertip = UserFingertipView(frame: CGRect(x: t.x, y: t.y, width: 30.0, height: 30.0), color: .lightGray)
                fingertip?.alpha = 0.6
                addSubview(fingertip!)
                
                UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseIn, animations: {
                    self.fingertip?.alpha = 0.0
                    self.fingertip?.frame = CGRect(origin: (self.fingertip?.frame.origin)!, size: CGSize(width: 25, height: 25))
                }, completion: { _ in
                    self.fingertip?.removeFromSuperview()
                })
                
                
                break
            case .stationary:
                
                fingertip = UserFingertipView(frame: CGRect(x: t.x, y: t.y, width: 30.0, height: 30.0), color: .lightGray)
                fingertip?.tag = touch.hash

                if fingertip != nil, touch.phase != .stationary {
                    fingertip!.removeFromSuperview()
                    fingertip = nil
                }
            
            case .ended: break
            case .cancelled:
                removeFingertip(identifiedBy: touch.hash)
                break
            case .regionEntered:
                break
            case .regionMoved:
                break
            case .regionExited:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func removeFingertip(identifiedBy hash: Int, animated: Bool = true) {
        
        guard let ring = fingertip else { return }
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .transitionCrossDissolve, animations: {
            ring.alpha = 0
            ring.frame = CGRect(x: ring.center.x - ring.frame.size.width,
                                 y: ring.center.y - ring.frame.size.height,
                                 width: ring.frame.size.width * 2,
                                 height: ring.frame.size.height * 2)
        }, completion: { _ in
            ring.removeFromSuperview()
        })
    }
}

/// Visual user representation of a user tap
class UserFingertipView: UIView {
    
    var color: UIColor
    
    
    init(frame: CGRect, color: UIColor = .gray) {
        self.color = color
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        drawUserTap()
    }

    internal func drawUserTap() -> () {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2), radius: CGFloat(bounds.size.width), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
            
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
            
        shapeLayer.fillColor = color.withAlphaComponent(0.7).cgColor
        shapeLayer.strokeColor = color.withAlphaComponent(0.9).cgColor
        shapeLayer.lineWidth = 3.0
            
        layer.addSublayer(shapeLayer)
         
     }
}
