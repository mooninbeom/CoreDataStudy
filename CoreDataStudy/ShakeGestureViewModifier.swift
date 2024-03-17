//
//  ShakeGestureViewModifier.swift
//  CoreDataStudy
//
//  Created by 문인범 on 3/17/24.
//

import Foundation
import SwiftUI




struct ShakeGestureViewModifier: ViewModifier {
    
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShake)) { _ in
                action()
            }
    }
    
}


extension UIDevice {
    static let deviceDidShake = Notification.Name("deviceDidShake")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        
        NotificationCenter.default.post(name: UIDevice.deviceDidShake, object: nil)
    }
}

extension View {
    public func onShakeGesture(perform action: @escaping () -> Void) -> some View {
        self.modifier(ShakeGestureViewModifier(action: action))
    }
}
