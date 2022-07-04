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
    
    private lazy var participants = [
        ParticipantModel(container: UIStackView(), videoView: UIView(),buttonContainer: UIStackView(), skipButton: UIButton()),
        ParticipantModel(container: UIStackView(), videoView: UIView(),buttonContainer: UIStackView(), skipButton: UIButton()),
        ParticipantModel(container: UIStackView(), videoView: UIView(),buttonContainer: UIStackView(), skipButton: UIButton()),
        ParticipantModel(container: UIStackView(), videoView: UIView(),buttonContainer: UIStackView(), skipButton: UIButton()),
        ParticipantModel(container: UIStackView(), videoView: UIView(),buttonContainer: UIStackView(), skipButton: UIButton()),
        ParticipantModel(container: UIStackView(), videoView: UIView(),buttonContainer: UIStackView(), skipButton: UIButton()),
    ]
    
    private func configureVideoStackViews() {
        for (ix,participant) in participants.enumerated() {
            participant.container.axis = .vertical
            participant.container.spacing = 10
            switch ix {
            case 0,1,2:
                participant.container.addArrangedSubview(participant.buttonContainer)
                participant.container.addArrangedSubview(participant.videoView)
            case 3,4,5:
                participant.container.addArrangedSubview(participant.videoView)
                participant.container.addArrangedSubview(participant.buttonContainer)
            default:
                break
            }
        }
    }
    
    private func configureVideoViews() {
        let screenHeight = UIScreen.main.bounds.height
        for participant in participants {
            participant.videoView.translatesAutoresizingMaskIntoConstraints = false
            participant.videoView.backgroundColor = .black
            participant.videoView.layer.cornerRadius = 10
            participant.videoView.clipsToBounds = true
            participant.videoView.heightAnchor.constraint(equalToConstant: screenHeight/4.65).isActive = true
        }
    }
    
    private func createActivityIndicators() {
        for participant in participants {
            let indicator = UIActivityIndicatorView()
            indicator.translatesAutoresizingMaskIntoConstraints = false
            participant.videoView.addSubview(indicator)
            indicator.style = .medium
            indicator.color = .white
            indicator.centerXAnchor.constraint(equalTo: participant.videoView.centerXAnchor).isActive = true
            indicator.centerYAnchor.constraint(equalTo: participant.videoView.centerYAnchor).isActive = true
            indicator.startAnimating()
        }
    }
    
    private func configureSkipButtons() {
        for participant in participants {
            let size:CGFloat = 35
            participant.skipButton.isEnabled = false
            participant.skipButton.backgroundColor = .clear
            participant.skipButton.translatesAutoresizingMaskIntoConstraints = false
            participant.skipButton.widthAnchor.constraint(equalToConstant: size).isActive = true
            participant.skipButton.heightAnchor.constraint(equalToConstant: size).isActive = true
            participant.skipButton.layer.masksToBounds = true
            participant.skipButton.layer.cornerRadius = size/2
            participant.skipButton.layer.borderColor = UIColor.black.cgColor
            participant.skipButton.layer.borderWidth = 3
            participant.skipButton.setBackgroundImage(UIImage(systemName: "arrow.clockwise.circle"), for: .normal)
            participant.skipButton.tintColor = .white
            participant.skipButton.addTarget(self, action: #selector(skipClicked), for: .touchUpInside)
        }
    }
    
    @objc private func skipClicked() {
        changeTopic(topic: "Should abortions be legal or not?")
    }
    
    private func configureButtonsStackViews() {
        for participant in participants {
            participant.buttonContainer.axis = .vertical
            participant.buttonContainer.alignment = .center
            participant.buttonContainer.addArrangedSubview(participant.skipButton)
        }
    }
    
    private func changeTopic(topic:String) {
        UIView.animate(withDuration: 0.4, delay: 0.0, animations: {
            self.discussionTopic.alpha = 0
        }) { finished in
            self.discussionTopic.text = topic
            UIView.animate(withDuration: 0.4, delay: 0, animations: {
                self.discussionTopic.alpha = 1.0
            })
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
        createActivityIndicators()
        configureButtonsStackViews()
        configureSkipButtons()
        configureVideoStackViews()
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
        
        topVideoStack.addArrangedSubview(participants[3].container)
        topVideoStack.addArrangedSubview(participants[4].container)
        topVideoStack.addArrangedSubview(participants[5].container)
        
        middleQustionsStack.addArrangedSubview(discussionTopic)
        
        
        bottomVideoStack.addArrangedSubview(participants[0].container)
        bottomVideoStack.addArrangedSubview(participants[1].container)
        bottomVideoStack.addArrangedSubview(participants[2].container)
        
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
        videoCanvas.uid = participants[0].uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = participants[0].videoView
        agoraKit?.setupLocalVideo(videoCanvas)
        
        // Join the channel with a token. Pass in your token and channel name here
        agoraKit?.joinChannel(byToken: KeyCenter.Token, channelId: "Main", info: nil, uid: 0, joinSuccess: { (channel, uid, elapsed) in
            self.videoSessions += 1
            self.participants[0].skipButton.isEnabled = true
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
            videoCanvas.view = participants[1].videoView
        } else if videoSessions == 3 {
            videoCanvas.view = participants[2].videoView
        } else if videoSessions == 4 {
            videoCanvas.view = participants[3].videoView
        } else if videoSessions == 5 {
            videoCanvas.view = participants[4].videoView
        } else if videoSessions == 6 {
            videoCanvas.view = participants[5].videoView
        }
        agoraKit?.setupRemoteVideo(videoCanvas)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        print("left")
    }
    
}
