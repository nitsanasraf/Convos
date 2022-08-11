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
    
    private lazy var networkManager: NetworkManger? = {
        guard let userID = UserModel.shared.id else {return nil}
        
        var manager = NetworkManger()
        if let room = self.room {
            manager.configureWebSocketTask(userID: userID, roomID: room.id.uuidString)
        }
        return manager
    }()
    
    private var newTopicVotes = [ParticipantModel]()
    
    private var localFrameIndex: Int?
    
    var room: RoomModel?
    
    private lazy var frames = [FrameModel(), FrameModel(), FrameModel(), FrameModel(), FrameModel(), FrameModel()]
    
    //MARK: - Web Socket Functions
    private func receiveData() {
        networkManager?.webSocketTask?.receive { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let msg):
                switch msg {
                case .data(let data):
                    do {
                        let decodedData = try JSONDecoder().decode([ParticipantModel].self, from: data)
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
                        self.newTopicVotes = []
                        self.renderVoteOrbs()
                        self.changeActionButtonUI(isPressed: true, config: &self.newTopicButton.configuration!)
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
        networkManager?.webSocketTask?.resume()
    }
    
    private func sendData() {
        do {
            let dummyJSON = try JSONEncoder().encode(newTopicVotes)
            networkManager?.webSocketTask?.send( URLSessionWebSocketTask.Message.data(dummyJSON) ) { error in
                if let error = error {
                    print("Web socket couldn't send message: \(error)")
                }
            }
        } catch {
            print("Error encoding: \(error)")
        }
    }
    
    
    private func ping() {
        networkManager?.webSocketTask?.sendPing { error in
            if let error = error {
                print("Ping Error: \(error)")
            }
        }
    }
    
    private func closeSocket() {
        networkManager?.webSocketTask?.cancel(with: .goingAway, reason: "User left".data(using: .utf8))
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
        stackView.backgroundColor = UIColor(white: 0, alpha: 0.2)
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
        stackView.backgroundColor = UIColor(white: 0, alpha: 0.2)
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
            config.baseBackgroundColor = UIColor(white: 0, alpha: 0.2)
            config.baseForegroundColor = .white
        } else {
            config.baseBackgroundColor = .white
            config.baseForegroundColor = Constants.Colors.primary
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
        newTopicVotesLabel.text = "New Topic Votes: \(newTopicVotes.count)"
    }
    
    private func appendNewTopicVote(isPressed:Bool) {
        guard let localIX = localFrameIndex else {return}
        guard let userID = UserModel.shared.id else {return}
        if isPressed {
            if let participantIndex = newTopicVotes.firstIndex(where: { $0.userID == userID}) {
                newTopicVotes.remove(at: participantIndex)
            }
        } else {
            let colorName = UIColor(cgColor:frames[localIX].color).accessibilityName
            newTopicVotes.append(ParticipantModel(userID: userID, color: colorName))
        }
    }
    
    private lazy var newRoomButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(white: 0, alpha: 0.2)
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
    
    private func createLoadingModal() {
        let modal = UIView()
        modal.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        modal.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Looking for a new room..."
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        
        let indicator = UIActivityIndicatorView()
        indicator.color = .white
        indicator.startAnimating()
        
        self.view.addSubview(modal)
        modal.addSubview(stackView)
        stackView.addArrangedSubview(indicator)
        stackView.addArrangedSubview(label)
        
        modal.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        modal.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        stackView.centerXAnchor.constraint(equalTo: modal.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: modal.centerYAnchor).isActive = true
    }
    
    @objc private func newRoomPressed() {
        guard let room = room else {return}
        guard let networkManager = networkManager else {return}
        
        let alert = UIAlertController(title: "Are you sure you want to leave the room?", message: "You won't be able to join this room again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "EXIT", style: .destructive) { alert in
            self.createLoadingModal()
            networkManager.fetchData(type: RoomModel.self, url: "\(networkManager.roomsURL)/\(room.category)/\(room.id)") { [weak self] room in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    RoomModel.moveToRoom(room: room, fromViewController: self, withTitle: self.title)
                }
            }
        })
        alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private lazy var newTopicButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(white: 0, alpha: 0.2)
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
        let isPressed = sender.configuration?.baseBackgroundColor == UIColor(white: 0, alpha: 0.2) ? false : true
        appendNewTopicVote(isPressed: isPressed)
        changeActionButtonUI(isPressed: isPressed, config: &sender.configuration!)
        sendData()
    }
    
    private lazy var muteAllButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(white: 0, alpha: 0.2)
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
        let isPressed = sender.configuration?.baseBackgroundColor == UIColor(white: 0, alpha: 0.2) ? false : true
        changeActionButtonUI(isPressed: isPressed, config: &sender.configuration!)
        for frame in frames {
            if isPressed {
                mute(with: frame, button: frame.muteButton, unmute: true)
            } else {
                mute(with: frame, button: frame.muteButton, unmute: false)
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
        for (ix,frame) in frames.enumerated() {
            frame.container.axis = .vertical
            frame.container.spacing = 10
            switch ix {
            case 0,1,2:
                if ix != 1 {
                    mainStackView.addSubview(frame.buttonContainer)
                    frame.container.addArrangedSubview(frame.videoView)
                    frame.container.addArrangedSubview(UIView.spacer(size: 5, for: .vertical))
                } else {
                    frame.container.addArrangedSubview(UIView.spacer(size: 5, for: .vertical))
                    mainStackView.addSubview(frame.buttonContainer)
                    frame.container.addArrangedSubview(frame.videoView)
                }
            case 3,4,5:
                if ix != 4 {
                    frame.container.addArrangedSubview(UIView.spacer(size: 5, for: .vertical))
                    frame.container.addArrangedSubview(frame.videoView)
                    mainStackView.addSubview(frame.buttonContainer)
                } else {
                    frame.container.addArrangedSubview(frame.videoView)
                    mainStackView.addSubview(frame.buttonContainer)
                    frame.container.addArrangedSubview(UIView.spacer(size: 5, for: .vertical))
                    
                }
            default:
                break
            }
        }
    }
    
    private func setFramesColors() {
        guard let room = room else {return}
        for i in 0..<frames.count {
            self.frames[i].videoView.layer.borderWidth = 3
            self.frames[i].videoView.layer.borderColor = room.colors[i].getColorByName().cgColor
            self.frames[i].setColor(color: room.colors[i].getColorByName().cgColor)
            self.frames[i].muteButton.backgroundColor = room.colors[i].getColorByName()
            self.frames[i].muteButton.isHidden = false
        }
    }
    
    private func configureVideoViews() {
        let screenHeight = UIScreen.main.bounds.height
        for frame in frames {
            frame.videoView.translatesAutoresizingMaskIntoConstraints = false
            frame.videoView.backgroundColor = .black
            frame.videoView.layer.cornerRadius = 10
            frame.videoView.clipsToBounds = true
            frame.videoView.heightAnchor.constraint(equalToConstant: screenHeight/4.65).isActive = true
        }
    }
    
    private func createActivityIndicators() {
        for frame in frames {
            let indicator = UIActivityIndicatorView()
            indicator.translatesAutoresizingMaskIntoConstraints = false
            frame.videoView.addSubview(indicator)
            indicator.style = .medium
            indicator.color = .white
            indicator.centerXAnchor.constraint(equalTo: frame.videoView.centerXAnchor).isActive = true
            indicator.centerYAnchor.constraint(equalTo: frame.videoView.centerYAnchor).isActive = true
            indicator.startAnimating()
        }
    }
    
    private func configureMuteButtons() {
        for (ix,frame) in frames.enumerated() {
            let size:CGFloat = 35
            frame.muteButton.isHidden = true
            frame.muteButton.translatesAutoresizingMaskIntoConstraints = false
            frame.muteButton.widthAnchor.constraint(equalToConstant: size).isActive = true
            frame.muteButton.heightAnchor.constraint(equalToConstant: size).isActive = true
            frame.muteButton.layer.masksToBounds = true
            frame.muteButton.layer.cornerRadius = size/2
            frame.muteButton.tag = ix
            frame.muteButton.setBackgroundImage(UIImage(systemName: "mic.circle"), for: .normal)
            frame.muteButton.tintColor = .black
            frame.muteButton.addTarget(self, action: #selector(muteClicked), for: .touchUpInside)
        }
    }
    
    private func mute(with frame:FrameModel, button:UIButton, unmute:Bool) {
        if !unmute {
            button.setBackgroundImage(UIImage(systemName: "mic.slash.circle"), for: .normal)
            frame.container.alpha = 0.5
            button.alpha = 0.5
        } else {
            button.setBackgroundImage(UIImage(systemName: "mic.circle"), for: .normal)
            frame.container.alpha = 1
            button.alpha = 1
        }
    }
    
    private func muteParticipant(isMuted:Bool, button: UIButton) {
        for frame in frames {
            if frame.muteButton.tag == button.tag {
                if isMuted {
                    mute(with: frame, button: button, unmute: true)
                } else {
                    mute(with: frame, button: button, unmute: false)
                }
            }
        }
    }
    
    @objc private func muteClicked(_ sender:UIButton) {
        let isMuted = sender.currentBackgroundImage == UIImage(systemName: "mic.circle") ? false : true
        muteParticipant(isMuted: isMuted, button: sender)
    }
    
    private func configureButtonsStackViews() {
        for frame in frames {
            let muteBtnSize:CGFloat = 35/2
            frame.buttonContainer.translatesAutoresizingMaskIntoConstraints = false
            frame.buttonContainer.axis = .vertical
            frame.buttonContainer.alignment = .center
            frame.buttonContainer.addArrangedSubview(frame.muteButton)
            frame.buttonContainer.bottomAnchor.constraint(equalTo: frame.videoView.bottomAnchor, constant: muteBtnSize - 3).isActive = true
            frame.buttonContainer.centerXAnchor.constraint(equalTo: frame.videoView.centerXAnchor).isActive = true
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
    
    private lazy var discussionTopic:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        label.text = room?.currentTopic
        label.textAlignment = .center
        return label
    }()
    
    
    @objc private func goBack() {
        let alert = UIAlertController(title: "Are you sure you want to leave the room?", message: "You won't be able to join this room again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "EXIT", style: .destructive) { alert in
            self.navigationController?.popToRootViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSkeleton()
        
        networkManager?.webSocketTask?.delegate = self
        resumeSocket()
        
        addViews()
        addLayouts()
        
        configureVideoViews()
        createActivityIndicators()
        configureMuteButtons()
        configureVideoStackViews()
        configureButtonsStackViews()
        
        setFramesColors()
        initializeAndJoinChannel()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard let localFrameIndex = self.localFrameIndex else {return}
        updateAvailablePositions(index: localFrameIndex) {_ in}
        closeSocket()
    }
    
    deinit {
        agoraKit?.leaveChannel(nil)
        AgoraRtcEngineKit.destroy()
    }
    
    //MARK: - Utils Setups
    
    private func configureSkeleton() {
        view.backgroundColor = Constants.Colors.primary
        self.navigationItem.hidesBackButton = true
        
        let newBackButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    private func addViews() {
        view.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(topVideoStack)
        mainStackView.addArrangedSubview(UIView.spacer(size: 0, for: .vertical))
        mainStackView.addArrangedSubview(middleQustionsStack)
        mainStackView.addArrangedSubview(middleActionStack)
        mainStackView.addArrangedSubview(middleSkipCounterStack)
        mainStackView.addArrangedSubview(bottomVideoStack)
        
        
        for i in 3...5 {
            topVideoStack.addArrangedSubview(frames[i].container)
        }
        
        
        middleQustionsStack.addArrangedSubview(discussionTopic)
        
        middleActionStack.addArrangedSubview(newRoomButton)
        middleActionStack.addArrangedSubview(newTopicButton)
        middleActionStack.addArrangedSubview(muteAllButton)
        
        middleSkipCounterStack.addArrangedSubview(newTopicVotesLabel)
        
        for i in 0...2 {
            bottomVideoStack.addArrangedSubview(frames[i].container)
        }
        
        
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
    
    //MARK: - Positions Functions
    private func updateAvailablePositions(index:Int?, completionHandler: @escaping (Int?)->() ) {
        guard let room = room else {return}
        guard let networkManager = networkManager else {return}
        
        networkManager.sendData(object: room, url: "\(networkManager.roomsURL)/\(index ?? -1)", httpMethod: Constants.HttpMethods.PUT.rawValue) { data, _ in
            do {
                let ix = try JSONDecoder().decode(Int.self, from: data)
                if ix != -1 {
                    completionHandler(ix)
                } else {
                    completionHandler(nil)
                }
            } catch {
                print("Decoding data failed: \(error)")
            }
        }
    }
    
    
    private func findEmptyPosition() -> Int? {
        guard let room = room else {return nil}
        for (i,isOccupied) in room.availablePositions.enumerated() {
            if isOccupied {
                continue
            }
            return i
        }
        return nil
    }
    
    //MARK: - Agora Funcs
    private func initializeAndJoinChannel() {
        guard let room = room else {return}
        guard let userID = UserModel.shared.id else {return}
        
        updateAvailablePositions(index:nil) { availablePositionIX in
            guard let availablePositionIX = availablePositionIX else {return}
            DispatchQueue.main.async {
                self.agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: KeyCenter.appID, delegate: self)
                self.agoraKit?.enableVideo()
                let videoCanvas = AgoraRtcVideoCanvas()
                
                self.localFrameIndex = availablePositionIX
                
                videoCanvas.uid = self.frames[self.localFrameIndex!].uid
                videoCanvas.renderMode = .hidden
                videoCanvas.view = self.frames[self.localFrameIndex!].videoView
                
                self.agoraKit?.setupLocalVideo(videoCanvas)
                
                self.agoraKit?.joinChannel(byUserAccount: userID, token: UserModel.shared.agoraToken, channelId: room.name, joinSuccess: { (_,_,_) in
                    print("User has successfully joined the channel")
                })
            }
        }
    }
    
}

//MARK: - AgoraRtcEngineDelegate
extension RoomViewController: AgoraRtcEngineDelegate {
    // This callback is triggered when a remote user joins the channel
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        guard let room = self.room else {return}
        
        guard let emptyPositionIX = findEmptyPosition() else {return}
        room.availablePositions[emptyPositionIX] = true
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = frames[emptyPositionIX].videoView
        
        agoraKit?.setupRemoteVideo(videoCanvas)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        print("User left the channel")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didApiCallExecute error: Int, api: String, result: String) {
        if error != 0 {
            print("SDK ERROR: ",error)
        }
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didRegisteredLocalUser userAccount: String, withUid uid: UInt) {
        print("Successfully registered local user")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("Joined Channel!")
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
