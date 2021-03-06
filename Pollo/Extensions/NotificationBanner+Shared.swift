//
//  NotificationBanner+Shared.swift
//  Pollo
//
//  Created by Jack Thompson on 2/4/20.
//  Copyright © 2020 CornellAppDev. All rights reserved.
//

import Foundation
import UIKit
import NotificationBannerSwift

extension NotificationBanner {

    override public func isEqual(_ object: Any?) -> Bool {
        guard let banner = object as? NotificationBanner,
            let title1 = self.titleLabel?.text,
            let title2 = banner.titleLabel?.text else { return false }
        return title1 == title2
    }

    static func connectingBanner() -> BaseNotificationBanner {
        let banner = StatusBarNotificationBanner(title: "Connecting...", style: .warning, colors: PolloBannerColors())
        banner.autoDismiss = false
        banner.haptic = .none
        return banner
    }

    /// Displayed when a connection is successfully established
    static func connectedBanner() -> BaseNotificationBanner {
        let banner = StatusBarNotificationBanner(title: "Connected", style: .success, colors: PolloBannerColors())
        banner.haptic = .light

        return banner
    }

    /// Displayed when a connection is failed and will not automatically reconnect
    static func disconnectedBanner() -> BaseNotificationBanner {
        let banner = StatusBarNotificationBanner(title: "Connection failed. Tap to retry.", style: .danger, colors: PolloBannerColors())
        banner.haptic = .light
        banner.autoDismiss = false

        return banner
    }

    /// Displayed when a reconnect attempt is made
    static func reconnectingBanner(reason: String = "") -> BaseNotificationBanner {
        let banner = StatusBarNotificationBanner(title: "\(reason) Trying to reconnect...".trim(), style: .warning, colors: PolloBannerColors())
        banner.autoDismiss = false
        banner.haptic = .none

        return banner
    }

}

class PolloBannerColors: BannerColorsProtocol {

    internal func color(for style: BannerStyle) -> UIColor {
        switch style {
        case .danger, .warning: return .grapefruit
        default: return .polloGreen
        }
    }

}
