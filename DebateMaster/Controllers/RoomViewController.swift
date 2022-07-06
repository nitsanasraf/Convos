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
    
    private var newTopicVotes = [ParticipantModel]()
    
    //MARK: - UI Views
    private let mainStackView:UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
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
    
    private let middleSkipCounterStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.layer.cornerRadius = 10
        stackView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        return stackView
    }()
    
    private let middleActionStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private func changeActionButtonUI(isPressed:Bool,config: inout UIButton.Configuration) {
        if isPressed {
            config.baseBackgroundColor = UIColor(white: 0, alpha: 0.3)
            config.baseForegroundColor = .white
        } else {
            config.baseBackgroundColor = .white
            config.baseForegroundColor = .systemPink
        }
    }
    
    private lazy var newTopicVotesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14,weight: .regular)
        label.text = "New Topic Votes: \(newTopicVotes.count)"
        return label
    }()
    
    private let newTopicVotesColorsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let newTopicVoteColorView = UIView()
    
    private func configureNewTopicVotesInformation(color:CGColor, isPressed:Bool) {
        let size:CGFloat = 10
        newTopicVoteColorView.backgroundColor = UIColor(cgColor:color)
        newTopicVoteColorView.translatesAutoresizingMaskIntoConstraints = false
        newTopicVoteColorView.widthAnchor.constraint(equalToConstant: size).isActive = true
        newTopicVoteColorView.heightAnchor.constraint(equalToConstant: size).isActive = true
        newTopicVoteColorView.layer.masksToBounds = true
        newTopicVoteColorView.layer.cornerRadius = size/2
        if newTopicVotesColorsStackView.superview == nil {
            middleSkipCounterStack.addArrangedSubview(newTopicVotesColorsStackView)
        }
        if isPressed {
            newTopicVoteColorView.removeFromSuperview()
            if let participantIndex = newTopicVotes.firstIndex(where: {$0.uid == participants[0].uid}) {
                newTopicVotes.remove(at: participantIndex)
            }
            newTopicVotesLabel.text = "New topic votes: \(newTopicVotes.count)"
            if newTopicVotes.count == 0 {
                newTopicVotesColorsStackView.removeFromSuperview()
            }
        } else {
            newTopicVotesColorsStackView.addArrangedSubview(newTopicVoteColorView)
            newTopicVotes.append(participants[0])
            newTopicVotesLabel.text = "New topic votes: \(newTopicVotes.count)"
        }
    }

    private lazy var newRoomButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(white: 0, alpha: 0.3)
        config.baseForegroundColor = .white
        config.title = "New room"
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14,weight: .bold)
            return outgoing
        }
        config.image = UIImage(systemName: "rectangle.portrait.and.arrow.right",withConfiguration: imageConfig)
        config.imagePlacement = .trailing
        config.imagePadding = 5
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(newRoomPressed), for: .touchUpInside)
        return button
    }()
    
    @objc private func newRoomPressed() {
        //change room
    }
    
    private lazy var newTopicButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(white: 0, alpha: 0.3)
        config.baseForegroundColor = .white
        config.title = "New topic"
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14,weight: .bold)
            return outgoing
        }
        config.image = UIImage(systemName: "arrow.clockwise",withConfiguration: imageConfig)
        config.imagePlacement = .trailing
        config.imagePadding = 5
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(newTopicPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    @objc private func newTopicPressed(_ sender:UIButton) {
        let isPressed = sender.configuration?.baseBackgroundColor == UIColor(white: 0, alpha: 0.3) ? false : true
        configureNewTopicVotesInformation(color: participants[0].color,isPressed: isPressed)
        changeActionButtonUI(isPressed: isPressed, config: &sender.configuration!)
    }
    
    private lazy var muteAllButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(white: 0, alpha: 0.3)
        config.baseForegroundColor = .white
        config.title = "Mute all"
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14,weight: .bold)
            return outgoing
        }
        config.image = UIImage(systemName: "mic.slash",withConfiguration: imageConfig)
        config.imagePlacement = .trailing
        config.imagePadding = 5
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(muteAllPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    @objc private func muteAllPressed(_ sender:UIButton) {
        let isPressed = sender.configuration?.baseBackgroundColor == UIColor(white: 0, alpha: 0.3) ? false : true
        changeActionButtonUI(isPressed: isPressed, config: &sender.configuration!)
    }
    
    private let bottomVideoStack:UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var participants = [
        ParticipantModel(container: UIStackView(), videoView: UIView(),buttonContainer: UIStackView(), muteButton: UIButton(),color: UIColor.clear.cgColor),
        ParticipantModel(container: UIStackView(), videoView: UIView(),buttonContainer: UIStackView(), muteButton: UIButton(),color: UIColor.clear.cgColor),
        ParticipantModel(container: UIStackView(), videoView: UIView(),buttonContainer: UIStackView(), muteButton: UIButton(),color: UIColor.clear.cgColor),
        ParticipantModel(container: UIStackView(), videoView: UIView(),buttonContainer: UIStackView(), muteButton: UIButton(),color: UIColor.clear.cgColor),
        ParticipantModel(container: UIStackView(), videoView: UIView(),buttonContainer: UIStackView(), muteButton: UIButton(),color: UIColor.clear.cgColor),
        ParticipantModel(container: UIStackView(), videoView: UIView(),buttonContainer: UIStackView(), muteButton: UIButton(),color: UIColor.clear.cgColor),
    ]
    
    private func configureVideoStackViews() {
        for (ix,participant) in participants.enumerated() {
            participant.container.axis = .vertical
            participant.container.spacing = 10
            switch ix {
            case 0,1,2:
                if ix != 1 {
                    participant.container.addArrangedSubview(participant.buttonContainer)
                    participant.container.addArrangedSubview(participant.videoView)
                    participant.container.addArrangedSubview(UIView.spacer(size: 5, for: .vertical))
                } else {
                    participant.container.addArrangedSubview(UIView.spacer(size: 5, for: .vertical))
                    participant.container.addArrangedSubview(participant.buttonContainer)
                    participant.container.addArrangedSubview(participant.videoView)
                }
            case 3,4,5:
                if ix != 4 {
                    participant.container.addArrangedSubview(UIView.spacer(size: 5, for: .vertical))
                    participant.container.addArrangedSubview(participant.videoView)
                    participant.container.addArrangedSubview(participant.buttonContainer)
                } else {
                    participant.container.addArrangedSubview(participant.videoView)
                    participant.container.addArrangedSubview(participant.buttonContainer)
                    participant.container.addArrangedSubview(UIView.spacer(size: 5, for: .vertical))
                    
                }
            default:
                break
            }
        }
    }
    
    private var availableColors = [
        UIColor.white.cgColor,
        UIColor.systemGreen.cgColor,
        UIColor.systemCyan.cgColor,
        UIColor.orange.cgColor,
        UIColor.systemYellow.cgColor,
        UIColor.systemPurple.cgColor,
    ]
    
    private func setRandomParticipantColor(index: Int) {
        let randIndex = Int.random(in: 0..<availableColors.count)
        let color = availableColors[randIndex]
        participants[index].videoView.layer.borderColor = color
        participants[index].setColor(color: color)
        availableColors.remove(at: randIndex)
    }
    
    private func configureVideoViews() {
        let screenHeight = UIScreen.main.bounds.height
        for (ix,participant) in participants.enumerated() {
            participant.videoView.translatesAutoresizingMaskIntoConstraints = false
            participant.videoView.backgroundColor = .black
            participant.videoView.layer.cornerRadius = 10
            participant.videoView.clipsToBounds = true
            participant.videoView.heightAnchor.constraint(equalToConstant: screenHeight/4.65).isActive = true
            setRandomParticipantColor(index: ix)
            participant.videoView.layer.borderWidth = 3
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
    
    private func configureMuteButtons() {
        for participant in participants {
            let size:CGFloat = 35
            participant.muteButton.backgroundColor = .clear
            participant.muteButton.translatesAutoresizingMaskIntoConstraints = false
            participant.muteButton.widthAnchor.constraint(equalToConstant: size).isActive = true
            participant.muteButton.heightAnchor.constraint(equalToConstant: size).isActive = true
            participant.muteButton.layer.masksToBounds = true
            participant.muteButton.layer.cornerRadius = size/2
            participant.muteButton.layer.borderColor = UIColor.black.cgColor
            participant.muteButton.layer.borderWidth = 3
            participant.muteButton.setBackgroundImage(UIImage(systemName: "mic.circle"), for: .normal)
            participant.muteButton.tintColor = .white
            participant.muteButton.addTarget(self, action: #selector(muteClicked), for: .touchUpInside)
        }
    }
    
    private func changeMuteButtonUI(isMuted:Bool, button: UIButton) {
        if isMuted {
            button.setBackgroundImage(UIImage(systemName: "mic.circle"), for: .normal)
            button.alpha = 1
        } else {
            button.setBackgroundImage(UIImage(systemName: "mic.slash.circle"), for: .normal)
            button.alpha = 0.5
        }
    }
    
    @objc private func muteClicked(_ sender:UIButton) {
        let isMuted = sender.currentBackgroundImage == UIImage(systemName: "mic.circle") ? false : true
        changeMuteButtonUI(isMuted: isMuted, button: sender)
        changeTopic(topic: "Should abortions be legal or not?")
    }
    
    private func configureButtonsStackViews() {
        for participant in participants {
            participant.buttonContainer.axis = .vertical
            participant.buttonContainer.alignment = .center
            participant.buttonContainer.addArrangedSubview(participant.muteButton)
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
        configureMuteButtons()
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
        mainStackView.addArrangedSubview(middleActionStack)
        mainStackView.addArrangedSubview(middleSkipCounterStack)
        mainStackView.addArrangedSubview(bottomVideoStack)

        
        topVideoStack.addArrangedSubview(participants[3].container)
        topVideoStack.addArrangedSubview(participants[4].container)
        topVideoStack.addArrangedSubview(participants[5].container)
        
        middleQustionsStack.addArrangedSubview(discussionTopic)
        
        middleActionStack.addArrangedSubview(newRoomButton)
        middleActionStack.addArrangedSubview(newTopicButton)
        middleActionStack.addArrangedSubview(muteAllButton)
        
        middleSkipCounterStack.addArrangedSubview(newTopicVotesLabel)
        
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
