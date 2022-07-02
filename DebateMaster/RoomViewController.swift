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
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
    
    private let localView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let remoteView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let remoteView2:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let remoteView3:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let remoteView4:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let remoteView5:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        localView.addSubview(indicator)
        indicator.style = .medium
        indicator.color = .white
        indicator.centerXAnchor.constraint(equalTo: localView.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: localView.centerYAnchor).isActive = true
        indicator.startAnimating()
        return indicator
    }()
    
    private lazy var activityIndicator2: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        remoteView.addSubview(indicator)
        indicator.style = .medium
        indicator.color = .white
        indicator.centerXAnchor.constraint(equalTo: remoteView.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: remoteView.centerYAnchor).isActive = true
        indicator.startAnimating()
        return indicator
    }()
    
    private lazy var activityIndicator3: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        remoteView2.addSubview(indicator)
        indicator.style = .medium
        indicator.color = .white
        indicator.centerXAnchor.constraint(equalTo: remoteView2.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: remoteView2.centerYAnchor).isActive = true
        indicator.startAnimating()
        return indicator
    }()
    
    private lazy var activityIndicator4: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        remoteView3.addSubview(indicator)
        indicator.style = .medium
        indicator.color = .white
        indicator.centerXAnchor.constraint(equalTo: remoteView3.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: remoteView3.centerYAnchor).isActive = true
        indicator.startAnimating()
        return indicator
    }()
    
    private lazy var activityIndicator5: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        remoteView4.addSubview(indicator)
        indicator.style = .medium
        indicator.color = .white
        indicator.centerXAnchor.constraint(equalTo: remoteView4.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: remoteView4.centerYAnchor).isActive = true
        indicator.startAnimating()
        return indicator
    }()
    
    private lazy var activityIndicator6: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        remoteView5.addSubview(indicator)
        indicator.style = .medium
        indicator.color = .white
        indicator.centerXAnchor.constraint(equalTo: remoteView5.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: remoteView5.centerYAnchor).isActive = true
        indicator.startAnimating()
        return indicator
    }()
    
    private let questionLabel:UILabel = {
        let label = UILabel()
        label.text = "Question 1:"
        label.font = UIFont.systemFont(ofSize: 16,weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let questionText:UILabel = {
        let label = UILabel()
        label.text = "Do you think violent movies encourage the use of guns?"
        label.font = UIFont.systemFont(ofSize: 15,weight: .regular)
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink
        addViews()
        addLayouts()
        initializeAndJoinChannel()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        title = "Room name"
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
        
        middleQustionsStack.addArrangedSubview(questionLabel)
        middleQustionsStack.addArrangedSubview(questionText)

        bottomVideoStack.addArrangedSubview(localView)
        bottomVideoStack.addArrangedSubview(remoteView)
        bottomVideoStack.addArrangedSubview(remoteView2)
        
        localView.addSubview(activityIndicator)
        remoteView.addSubview(activityIndicator2)
        remoteView2.addSubview(activityIndicator3)
        remoteView3.addSubview(activityIndicator4)
        remoteView4.addSubview(activityIndicator5)
        remoteView5.addSubview(activityIndicator6)
        
    }
    
    private func addLayouts() {
        let screenBounds = UIScreen.main.bounds
        let screenHeight = screenBounds.height
        let mainStackViewConstraints = [
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        let viewsConstraints = [
            localView.heightAnchor.constraint(equalToConstant: screenHeight/4.65),
            remoteView.heightAnchor.constraint(equalToConstant: screenHeight/4.65),
            remoteView2.heightAnchor.constraint(equalToConstant: screenHeight/4.65),
            remoteView3.heightAnchor.constraint(equalToConstant: screenHeight/4.65),
            remoteView4.heightAnchor.constraint(equalToConstant: screenHeight/4.65),
            remoteView5.heightAnchor.constraint(equalToConstant: screenHeight/4.65),
        ]
        
        NSLayoutConstraint.activate(mainStackViewConstraints)
        NSLayoutConstraint.activate(viewsConstraints)
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
