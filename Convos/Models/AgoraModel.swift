//
//  AgoraModel.swift
//  Convos
//
//  Created by Nitsan Asraf on 19/09/2022.
//

import Foundation
import AgoraRtcKit

class AgoraModel {
    static var shared = AgoraModel()
    
    private init() {}
    
    lazy var agoraKit: AgoraRtcEngineKit = {
        guard let appID = KeyCenter.appID else {
            print("NO key")
            return AgoraRtcEngineKit.sharedEngine(withAppId: "", delegate: nil)
        }
        return AgoraRtcEngineKit.sharedEngine(withAppId: appID, delegate: nil)
    }()
    
    func leaveChannel() {
        self.agoraKit.setupLocalVideo(nil)
        self.agoraKit.leaveChannel()
        self.agoraKit.stopPreview()
        print("LEFT CHANNEL")
    }
}
