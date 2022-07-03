//
//  ViewController.swift
//  DebateMaster
//
//  Created by Nitsan Asraf on 01/07/2022.
//

import UIKit
import AgoraRtcKit

class RoomViewController: UIViewController {
    
    private var agoraKit: AgoraRtcEngineKit?
    
    private var videoSessions = 0
    
    //MARK: - UI Views
    private let mainStackView:UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        return stackView
    }()
    
    private let topVideoStack:UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let middleQustionsStack:UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.layer.cornerRadius = 10
        stackView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        stackView.alignment = .center
        return stackView
    }()
    
    private let bottomVideoStack:UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let localView = UIView()
    private let remoteView = UIView()
    private let remoteView2 = UIView()
    private let remoteView3 = UIView()
    private let remoteView4 = UIView()
    private let remoteView5 = UIView()

    
    private lazy var videoViews = [localView,remoteView,remoteView2,remoteView3,remoteView4,remoteView5]
    
    private func configureVideoViews() {
        let screenHeight = UIScreen.main.bounds.height
        for view in videoViews {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .black
            view.layer.cornerRadius = 10
            view.clipsToBounds = true
            view.heightAnchor.constraint(equalToConstant: screenHeight/4.65).isActive = true
        }
    }
    
    private let activityIndicator = UIActivityIndicatorView()
    private let activityIndicator2 = UIActivityIndicatorView()
    private let activityIndicator3 = UIActivityIndicatorView()
    private let activityIndicator4 = UIActivityIndicatorView()
    private let activityIndicator5 = UIActivityIndicatorView()
    private let activityIndicator6 = UIActivityIndicatorView()
    
    private lazy var activityIndicators = [activityIndicator,activityIndicator2,activityIndicator3,activityIndicator4,activityIndicator5,activityIndicator6]

    private func configureActivityIndicators() {
        for (ix,indicator) in activityIndicators.enumerated() {
            indicator.translatesAutoresizingMaskIntoConstraints = false
            videoViews[ix].addSubview(indicator)
            indicator.style = .medium
            indicator.color = .white
            indicator.centerXAnchor.constraint(equalTo: videoViews[ix].centerXAnchor).isActive = true
            indicator.centerYAnchor.constraint(equalTo: videoViews[ix].centerYAnchor).isActive = true
            indicator.startAnimating()
        }
    }
    
    private let discussionTopic:UILabel = {
        let label = UILabel()
        label.text = "Do you think violent movies encourage the use of guns?"
        label.font = UIFont.systemFont(ofSize: 16,weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        title = "Room name"

        configureVideoViews()
        configureActivityIndicators()
        addViews()
        addLayouts()
        initializeAndJoinChannel()
        
    }
    
    deinit {
        agoraKit?.leaveChannel(nil)
        AgoraRtcEngineKit.destroy()
    }
    
    //MARK: - Utils Setups
    private func addViews() {
        view.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(topVideoStack)
        mainStackView.addArrangedSubview(middleQustionsStack)
        mainStackView.addArrangedSubview(bottomVideoStack)
        
        topVideoStack.addArrangedSubview(remoteView3)
        topVideoStack.addArrangedSubview(remoteView4)
        topVideoStack.addArrangedSubview(remoteView5)
        
        middleQustionsStack.addArrangedSubview(discussionTopic)


        bottomVideoStack.addArrangedSubview(localView)
        bottomVideoStack.addArrangedSubview(remoteView)
        bottomVideoStack.addArrangedSubview(remoteView2)
        
    }
    
    private func addLayouts() {
        let mainStackViewConstraints = [
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(mainStackViewConstraints)
    }
    
    //MARK: - Agora Funcs
    private func initializeAndJoinChannel() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.AppId, delegate: self)
        // Video is disabled by default. You need to call enableVideo to start a video stream.
        agoraKit?.enableVideo()
        // Create a videoCanvas to render the local video
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.renderMode = .hidden
        videoCanvas.view = localView
        agoraKit?.setupLocalVideo(videoCanvas)
        
        // Join the channel with a token. Pass in your token and channel name here
        agoraKit?.joinChannel(byToken: KeyCenter.Token, channelId: "Main", info: nil, uid: 0, joinSuccess: { (channel, uid, elapsed) in
            self.videoSessions += 1
        })
    }
    
}

//MARK: - AgoraRtcEngineDelegate
extension RoomViewController: AgoraRtcEngineDelegate {
    // This callback is triggered when a remote user joins the channel
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        videoSessions += 1
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        if videoSessions == 2 {
            videoCanvas.view = remoteView
        } else if videoSessions == 3 {
            videoCanvas.view = remoteView2
        } else if videoSessions == 4 {
            videoCanvas.view = remoteView3
        } else if videoSessions == 5 {
            videoCanvas.view = remoteView4
        } else if videoSessions == 6 {
            videoCanvas.view = remoteView5
        }
        agoraKit?.setupRemoteVideo(videoCanvas)
    }
}
