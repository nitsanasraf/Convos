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
    
    private var newTopicVotes = [ParticipantCodableModel]()
    
    private lazy var participants = [
        ParticipantUIModel(container: UIStackView(), videoView: UIView(),buttonContainer: UIStackView(), muteButton: UIButton(),color: UIColor.clear.cgColor),
        ParticipantUIModel(container: UIStackView(), videoView: UIView(),buttonContainer: UIStackView(), muteButton: UIButton(),color: UIColor.clear.cgColor),
        ParticipantUIModel(container: UIStackView(), videoView: UIView(),buttonContainer: UIStackView(), muteButton: UIButton(),color: UIColor.clear.cgColor),
        ParticipantUIModel(container: UIStackView(), videoView: UIView(),buttonContainer: UIStackView(), muteButton: UIButton(),color: UIColor.clear.cgColor),
        ParticipantUIModel(container: UIStackView(), videoView: UIView(),buttonContainer: UIStackView(), muteButton: UIButton(),color: UIColor.clear.cgColor),
        ParticipantUIModel(container: UIStackView(), videoView: UIView(),buttonContainer: UIStackView(), muteButton: UIButton(),color: UIColor.clear.cgColor),
    ]
    
    
    //MARK: - Web Socket Functions
    private func receiveData() {
        WebSocketModel.shared.webSocketTask.receive { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let msg):
                switch msg {
                case .data(let data):
                    do {
                        let decodedData = try JSONDecoder().decode([ParticipantCodableModel].self, from: data)
                        self.newTopicVotes = decodedData
                        DispatchQueue.main.async {
                            self.renderVoteOrbs()
                        }
                    } catch {
                        print("Error decoding: \(error)")
                    }
                case .string(let str):
                    DispatchQueue.main.async {
                        self.changeTopic(topic: str)
                    }
                default:
                    break
                }
            case .failure(let err):
                print("Receive Error: \(err)")
                return
            }
            self.receiveData()
        }
    }
    
    private func resumeSocket() {
        WebSocketModel.shared.webSocketTask.resume()
    }
    
    private func sendData() {
        do {
            let dummyJSON = try JSONEncoder().encode(newTopicVotes)
            WebSocketModel.shared.webSocketTask.send( URLSessionWebSocketTask.Message.data(dummyJSON) ) { error in
                if let error = error {
                    print("Web socket couldn't send message: \(error)")
                }
            }
        } catch {
            print("Error encoding: \(error)")
        }
    }
    
    
    private func ping() {
        WebSocketModel.shared.webSocketTask.sendPing { error in
            if let error = error {
                print("Ping Error: \(error)")
            }
        }
    }
    
    private func closeSocket() {
        WebSocketModel.shared.webSocketTask.cancel(with: .goingAway, reason: "Room left".data(using: .utf8))
    }
    
    //MARK: - UI Views
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        return stackView
    }()
    
    private let topVideoStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let middleQustionsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.layer.cornerRadius = 10
        stackView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top:5, left: 15, bottom: 5, right: 15)
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
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    private let newVoteOrbsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private func createNewVoteOrb(color:UIColor) -> UIView {
        let size:CGFloat = 10
        let view = UIView()
        view.backgroundColor = color
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: size).isActive = true
        view.heightAnchor.constraint(equalToConstant: size).isActive = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = size/2
        return view
    }
    
    private func renderVoteOrbs() {
        for subview in newVoteOrbsStackView.arrangedSubviews {
            newVoteOrbsStackView.removeArrangedSubview(subview)
        }
        newVoteOrbsStackView.removeFromSuperview()
        for newTopicVote in newTopicVotes {
            if newVoteOrbsStackView.superview == nil {
                middleSkipCounterStack.addArrangedSubview(newVoteOrbsStackView)
            }
            let orb = createNewVoteOrb(color: newTopicVote.color.getColorByName())
            newVoteOrbsStackView.addArrangedSubview(orb)
        }
        newTopicVotesLabel.text = "New topic votes: \(newTopicVotes.count)"
    }
    
    private func appendNewTopicVote(isPressed:Bool) {
        if isPressed {
            if let participantIndex = newTopicVotes.firstIndex(where: {$0.id == participants[0].uid}) {
                newTopicVotes.remove(at: participantIndex)
            }
        } else {
            let colorName = UIColor(cgColor:participants[0].color).accessibilityName
            newTopicVotes.append(ParticipantCodableModel(id: participants[0].uid, color: colorName))
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
        WebSocketModel.shared.webSocketTask.send( URLSessionWebSocketTask.Message.string("Some new topic coming from the sever") ) { error in
            if let error = error {
                print("Web socket couldn't send message: \(error)")
            }
        }
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
        appendNewTopicVote(isPressed: isPressed)
        changeActionButtonUI(isPressed: isPressed, config: &sender.configuration!)
        sendData()
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
        for participant in participants {
            if isPressed {
                mute(with: participant, button: participant.muteButton, unmute: true)
            } else {
                mute(with: participant, button: participant.muteButton, unmute: false)
            }
            
        }
    }
    
    private let bottomVideoStack:UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private func configureVideoStackViews() {
        for (ix,participant) in participants.enumerated() {
            participant.container.axis = .vertical
            participant.container.spacing = 10
            switch ix {
            case 0,1,2:
                if ix != 1 {
                    mainStackView.addSubview(participant.buttonContainer)
                    participant.container.addArrangedSubview(participant.videoView)
                    participant.container.addArrangedSubview(UIView.spacer(size: 5, for: .vertical))
                } else {
                    participant.container.addArrangedSubview(UIView.spacer(size: 5, for: .vertical))
                    mainStackView.addSubview(participant.buttonContainer)
                    participant.container.addArrangedSubview(participant.videoView)
                }
            case 3,4,5:
                if ix != 4 {
                    participant.container.addArrangedSubview(UIView.spacer(size: 5, for: .vertical))
                    participant.container.addArrangedSubview(participant.videoView)
                    mainStackView.addSubview(participant.buttonContainer)
                } else {
                    participant.container.addArrangedSubview(participant.videoView)
                    mainStackView.addSubview(participant.buttonContainer)
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
    
    private func setRandomParticipantColor() {
        guard let url = URL(string: "http://127.0.0.1:8080/color") else {return}
        for (ix,_) in participants.enumerated() {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error fetching colors: \(error)")
                } else {
                    guard let data = data else {return}
                    do {
                        let colors = try JSONDecoder().decode([String].self, from: data)
                        DispatchQueue.main.async {
                            self.participants[ix].videoView.layer.borderColor = colors[ix].getColorByName().cgColor
                            self.participants[ix].setColor(color: colors[ix].getColorByName().cgColor)
                            self.participants[ix].muteButton.backgroundColor = colors[ix].getColorByName()
                            
                        }
                    } catch {
                        print("Error decoding: \(error)")
                    }
                    
                }
            }
            task.resume()
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
        for (ix,participant) in participants.enumerated() {
            let size:CGFloat = 35
            participant.muteButton.translatesAutoresizingMaskIntoConstraints = false
            participant.muteButton.widthAnchor.constraint(equalToConstant: size).isActive = true
            participant.muteButton.heightAnchor.constraint(equalToConstant: size).isActive = true
            participant.muteButton.layer.masksToBounds = true
            participant.muteButton.layer.cornerRadius = size/2
            participant.muteButton.tag = ix
            participant.muteButton.setBackgroundImage(UIImage(systemName: "mic.circle"), for: .normal)
            participant.muteButton.tintColor = .black
            participant.muteButton.addTarget(self, action: #selector(muteClicked), for: .touchUpInside)
        }
    }
    
    private func mute(with participant:ParticipantUIModel, button:UIButton, unmute:Bool) {
        if !unmute {
            button.setBackgroundImage(UIImage(systemName: "mic.slash.circle"), for: .normal)
            participant.container.alpha = 0.5
            button.alpha = 0.5
        } else {
            button.setBackgroundImage(UIImage(systemName: "mic.circle"), for: .normal)
            participant.container.alpha = 1
            button.alpha = 1
        }
    }
    
    private func muteParticipant(isMuted:Bool, button: UIButton) {
        for participant in participants {
            if participant.muteButton.tag == button.tag {
                if isMuted {
                    mute(with: participant, button: button, unmute: true)
                } else {
                    mute(with: participant, button: button, unmute: false)
                }
            }
        }
    }
    
    @objc private func muteClicked(_ sender:UIButton) {
        let isMuted = sender.currentBackgroundImage == UIImage(systemName: "mic.circle") ? false : true
        muteParticipant(isMuted: isMuted, button: sender)
    }
    
    private func configureButtonsStackViews() {
        for participant in participants {
            let muteBtnSize:CGFloat = 35/2
            participant.buttonContainer.translatesAutoresizingMaskIntoConstraints = false
            participant.buttonContainer.axis = .vertical
            participant.buttonContainer.alignment = .center
            participant.buttonContainer.addArrangedSubview(participant.muteButton)
            participant.buttonContainer.bottomAnchor.constraint(equalTo: participant.videoView.bottomAnchor, constant: muteBtnSize - 3).isActive = true
            participant.buttonContainer.centerXAnchor.constraint(equalTo: participant.videoView.centerXAnchor).isActive = true
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
        label.text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s?"
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
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
        title = "Category"
        
        WebSocketModel.shared.webSocketTask.delegate = self
        resumeSocket()
        addViews()
        addLayouts()
        
        configureVideoViews()
        createActivityIndicators()
        configureMuteButtons()
        configureVideoStackViews()
        configureButtonsStackViews()
        
        setRandomParticipantColor()
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
        mainStackView.addArrangedSubview(UIView.spacer(size: 0, for: .vertical))
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
        print("user left channel")
    }
    
}

//MARK: - URLSessionWebSocketDelegate
extension RoomViewController:URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Connected to socket")
        ping()
        receiveData()
    }
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Closed connection to socket")
    }
}
