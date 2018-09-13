//
//  SocketDelegate.swift
//  Clicker
//
//  Created by Kevin Chan on 4/14/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

protocol SocketDelegate {
    func sessionConnected()
    func sessionDisconnected()
    func receivedUserCount(_ count: Int)
    func pollEnded(_ poll: Poll)
    
    // USER RECEIVES
    func pollStarted(_ poll: Poll)
    func receivedResults(_ currentState: CurrentState)
    
    // ADMIN RECEIVES
    func updatedTally(_ currentState: CurrentState)
}
