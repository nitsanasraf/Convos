//
//  ViewController.swift
//  Convos
//
//  Created by Nitsan Asraf on 01/07/2022.
//

import UIKit
import AgoraRtcKit
import NVActivityIndicatorView

class RoomViewController: UIViewController {
        
    private weak var agoraKit: AgoraRtcEngineKit? = AgoraModel.shared.agoraKit
  
    private var timer = Timer()
    
    private let userSeconds: UserSecondsModel? = {
        guard let userID = UserModel.shared.id,
              let uuid = UUID(uuidString: userID) else {return nil}
        return UserSecondsModel(userID: uuid, seconds: 0)
    }()
    
    private var isTopicPressed = false
    private var isMutePressed = false
    
    private lazy var networkManager: NetworkManger = {
        guard let userID = UserModel.shared.id,
              let room = self.room else { return NetworkManger() }
        
        var manager = NetworkManger()
        manager.configureWebSocketTask(userID: userID, roomID: room.id.uuidString)
        return manager
    }()
    
    private var localFrameIndex: Int?
    
    var room: RoomModel?
    
    private var frames = [FrameModel(), FrameModel(), FrameModel(), FrameModel(), FrameModel(), FrameModel()]
    
    //MARK: - Web Socket Functions
    private func receiveData() {
        networkManager.webSocketTask?.receive { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let msg):
                switch msg {
                case .data(let data):
                    do {
                        let decodedData = try JSONDecoder().decode([[String:String]].self, from: data)
                        self.room?.currentVotes = decodedData
                        DispatchQueue.main.async {
                            self.renderVoteOrbs()
                        }
                    } catch {
                        print("Error decoding: \(error)")
                    }
                case .string(let str):
                    DispatchQueue.main.async {
                        self.changeTopic(topic: str)
                        self.room?.currentVotes = []
                        self.renderVoteOrbs()
                        self.changeActionButtonUI(isPressed: true, config: &self.newTopicButton.configuration!)
                        self.isTopicPressed = false
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
        networkManager.webSocketTask?.resume()
    }
    
    private func sendData() {
        do {
            let votes = try JSONEncoder().encode(room?.currentVotes)
            networkManager.webSocketTask?.send( URLSessionWebSocketTask.Message.data(votes) ) { error in
                if let error = error {
                    print("Web socket couldn't send message: \(error)")
                }
            }
        } catch {
            print("Error encoding: \(error)")
        }
    }
    
    
    private func ping() {
        networkManager.webSocketTask?.sendPing { error in
            if let error = error {
                print("Ping Error: \(error)")
            }
        }
    }
    
    private func closeSocket() {
        if let userVoteIX = room?.currentVotes.firstIndex(where: { $0["userUID"]! == UserModel.shared.uid }) {
            room?.currentVotes.remove(at: userVoteIX)
            sendData()
        }
        networkManager.webSocketTask?.cancel(with: .goingAway, reason: "User left".data(using: .utf8))
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
        stackView.backgroundColor = .init(white: 0, alpha: 0.2)
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
        stackView.backgroundColor = .init(white: 0, alpha: 0.2)
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
            config.baseBackgroundColor = .init(white: 0, alpha: 0.2)
            config.baseForegroundColor = Constants.Colors.primaryText
        } else {
            config.baseBackgroundColor = Constants.Colors.primaryText
            config.baseForegroundColor = Constants.Colors.primaryGradient
        }
    }
    
    private lazy var newTopicVotesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14,weight: .regular)
        label.text = "New Topic Votes: \(room?.currentVotes.count ?? 0)"
        label.numberOfLines = 0
        label.textColor = Constants.Colors.primaryText
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
        guard let room = room else {return}
        
        for subview in newVoteOrbsStackView.arrangedSubviews {
            newVoteOrbsStackView.removeArrangedSubview(subview)
        }
        
        newVoteOrbsStackView.removeFromSuperview()
        
        for newTopicVote in room.currentVotes {
            if newVoteOrbsStackView.superview == nil {
                middleSkipCounterStack.addArrangedSubview(newVoteOrbsStackView)
            }
            let orb = createNewVoteOrb(color: newTopicVote["color"]!.getColorByName())
            newVoteOrbsStackView.addArrangedSubview(orb)
        }
        newTopicVotesLabel.text = "New Topic Votes: \(room.currentVotes.count)"
    }
    
    private func appendNewTopicVote() {
        guard let localIX = localFrameIndex else {return}
        guard let userUID = UserModel.shared.uid else {return}
        
        let colorName = UIColor(cgColor:frames[localIX].color).accessibilityName
        
        if isTopicPressed {
            if let participantIndex = room?.currentVotes.firstIndex(where: { $0["color"]! == colorName }) {
                room?.currentVotes.remove(at: participantIndex)
            }
        } else {
            room?.currentVotes.append(["userUID": userUID, "color": colorName])
        }
        isTopicPressed.toggle()
    }
    
    private lazy var newRoomButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .init(white: 0, alpha: 0.2)
        config.baseForegroundColor = Constants.Colors.primaryText
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
        modal.backgroundColor = .init(white: 0, alpha: 0.85)
        modal.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = "Looking for a new room..."
        label.textColor = Constants.Colors.primaryText
        label.font = UIFont.systemFont(ofSize: 16)
        
        let indicator = UIActivityIndicatorView()
        indicator.color = Constants.Colors.primaryText
        indicator.startAnimating()
        
        self.view.addSubview(modal)
        modal.addSubview(stackView)
        stackView.addArrangedSubviews(indicator,label)
        
        modal.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        modal.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        stackView.centerXAnchor.constraint(equalTo: modal.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: modal.centerYAnchor).isActive = true
    }
    
    @objc private func newRoomPressed() {
        guard let room = room else { return }
        
        let alert = UIAlertController(title: "Are you sure you want to leave the room?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "EXIT", style: .destructive) { [weak self] alert in
            guard let self = self else {return}
            self.createLoadingModal()
            self.closeSocket()
            RoomModel.findEmptyRoom(fromRoom: room, networkManager: self.networkManager, category: self.title, viewController: self) { room, uid in
                DispatchQueue.main.async {
                    AgoraModel.shared.leaveChannel()
                    self.agoraKit?.joinChannel(byToken: UserModel.shared.agoraToken, channelId: room.name, info: nil, uid: uid, joinSuccess: { [weak self] (channel, uid, elapsed) in
                        guard let self = self else {return}
                        print("User has successfully joined the channel: \(channel)")
                        let roomVC = RoomViewController()
                        roomVC.title = self.title
                        roomVC.room = room
                        guard var vcs = self.navigationController?.viewControllers else {return}
                        vcs = vcs.dropLast()
                        vcs.append(roomVC)
                        self.navigationController?.setViewControllers(vcs, animated: false)
                    })
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private lazy var newTopicButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .init(white: 0, alpha: 0.2)
        config.baseForegroundColor = Constants.Colors.primaryText
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
        changeActionButtonUI(isPressed: isTopicPressed, config: &sender.configuration!)
        appendNewTopicVote()
        sendData()
    }
    
    private lazy var muteAllButton: UIButton = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .init(white: 0, alpha: 0.2)
        config.baseForegroundColor = Constants.Colors.primaryText
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
        changeActionButtonUI(isPressed: isMutePressed, config: &sender.configuration!)
        if isMutePressed {
            for frame in frames {
                mute(with: frame, button: frame.muteButton, unmute: true)
            }
        } else {
            for frame in frames {
                mute(with: frame, button: frame.muteButton, unmute: false)
            }
        }
        isMutePressed.toggle()
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
                    frame.container.addArrangedSubviews(frame.videoView, UIView.spacer(size: 5, for: .vertical))
                } else {
                    frame.container.addArrangedSubview(UIView.spacer(size: 5, for: .vertical))
                    mainStackView.addSubview(frame.buttonContainer)
                    frame.container.addArrangedSubview(frame.videoView)
                }
            case 3,4,5:
                if ix != 4 {
                    frame.container.addArrangedSubviews(UIView.spacer(size: 5, for: .vertical), frame.videoView)
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
    
    private func createSearchingParticipantIndicators() {
        for frame in frames {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 10
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            let topLabel = UILabel()
            topLabel.text = "Searching"
            topLabel.font = .systemFont(ofSize: 11, weight: .bold)
            
            
            let size: CGFloat = 30
            let type = NVActivityIndicatorType.ballSpinFadeLoader
            let indicator = NVActivityIndicatorView(frame: CGRect(origin: .zero, size: CGSize(width: size, height: size)), type: type, color: UIColor(cgColor:frame.color), padding: size)
            let bottomLabel = UILabel()
            bottomLabel.text = "Participant"
            bottomLabel.font = .systemFont(ofSize: 11, weight: .bold)
            
            frame.videoView.addSubview(stackView)
            stackView.addArrangedSubviews(topLabel,indicator,bottomLabel)

            stackView.centerXAnchor.constraint(equalTo: frame.videoView.centerXAnchor).isActive = true
            stackView.centerYAnchor.constraint(equalTo: frame.videoView.centerYAnchor).isActive = true
            
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
        guard let uid = frame.userUID else {return}
        
        if unmute {
            button.setBackgroundImage(UIImage(systemName: "mic.circle"), for: .normal)
            frame.container.alpha = 1
            button.alpha = 1
            if String(uid) == UserModel.shared.uid {
                agoraKit?.adjustRecordingSignalVolume(100)
            } else {
                agoraKit?.adjustUserPlaybackSignalVolume(uid, volume: 100)
                agoraKit?.adjustAudioMixingVolume(100)
            }

        } else {
            button.setBackgroundImage(UIImage(systemName: "mic.slash.circle"), for: .normal)
            frame.container.alpha = 0.5
            button.alpha = 0.5
            if String(uid) == UserModel.shared.uid {
                agoraKit?.adjustRecordingSignalVolume(0)
            } else {
                agoraKit?.adjustUserPlaybackSignalVolume(uid, volume: 0)
                agoraKit?.adjustAudioMixingVolume(0)
            }
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
        label.textColor = Constants.Colors.primaryText
        label.numberOfLines = 0
        label.text = room?.currentTopic
        label.textAlignment = .center
        return label
    }()
    
    
    @objc private func goBack() {
        let alert = UIAlertController(title: "Are you sure you want to leave the room?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "EXIT", style: .destructive) { [weak self] alert in
            guard let self = self else {return}
            let tabVC = self.navigationController!.viewControllers.filter { $0 is TabBarViewController }.first!
            self.navigationController!.popToViewController(tabVC, animated: true)
        })
        alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true) { [weak self] timer in
            guard let self = self else {return}
            guard var userSeconds = self.userSeconds else {return}
            
            userSeconds.seconds = Int(timer.timeInterval)
            self.networkManager.sendData(object: userSeconds, url: self.networkManager.usersURL, httpMethod: Constants.HttpMethods.POST.rawValue) { [weak self] (data, statusCode) in
                guard let self = self else {return}
                self.networkManager.handleErrors(statusCode: statusCode, viewController: self)
                do {
                    let realUserSeconds = try JSONDecoder().decode(Int.self, from: data)
                    UserModel.shared.secondsSpent = realUserSeconds
                    KeyChain.shared[Constants.KeyChain.Keys.userSeconds] = String(UserModel.shared.secondsSpent!)
                    if UserModel.shared.didExceedFreeTierLimit! {
                        DispatchQueue.main.async {
                            let tabVC = self.navigationController!.viewControllers.filter { $0 is TabBarViewController }.first!
                            self.navigationController!.popToViewController(tabVC, animated: true)
                            tabVC.present(PopUpViewController(), animated: true)
                        }
                    }
                } catch {
                    print("Error decoding: ",error)
                }
            }
        }
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        agoraKit?.delegate = self
        networkManager.webSocketTask?.delegate = self
        
        configureSkeleton()
    
        resumeSocket()
        
        addViews()
        addLayouts()
        
        configureVideoViews()
        configureMuteButtons()
        
        setFramesColors()
        createSearchingParticipantIndicators()

        configureVideoStackViews()
        configureButtonsStackViews()
        
        initializeAndJoinChannel()
        
        timer.tolerance = 0.2
        startTimer()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setPosition {_ in}
        closeSocket()
        timer.invalidate()
    }
    
    deinit {
        AgoraModel.shared.leaveChannel()
        print("DEINIT ROOM")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - Utils Setups
    private func configureSkeleton() {
        view.addGradient(colors: [Constants.Colors.primaryGradient, Constants.Colors.secondaryGradient])
        view.addBackgroundImage(with: "main.bg")
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    private func addViews() {
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubviews(topVideoStack, UIView.spacer(size: 0, for: .vertical), middleQustionsStack, middleActionStack, middleSkipCounterStack, bottomVideoStack)
        for i in 3...5 {
            topVideoStack.addArrangedSubview(frames[i].container)
        }
        middleQustionsStack.addArrangedSubview(discussionTopic)
        middleActionStack.addArrangedSubviews(newRoomButton, newTopicButton, muteAllButton)
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
    private func setPosition(completionHandler: @escaping (Int?)->() ) {
        guard let room = room,
              let userUID = UserModel.shared.uid else {return}
        let userRoom = UserRoom(userUID: userUID, roomID: room.id)
        networkManager.sendData(object: userRoom, url: networkManager.roomsURL, httpMethod: Constants.HttpMethods.PUT.rawValue) { [weak self] (data, code) in
            guard let self = self else {return}
            self.networkManager.handleErrors(statusCode: code, viewController: self)
            do {
                let ix = try JSONDecoder().decode(Int.self, from: data)
                if ix > -1 {
                    room.positions[ix] = userUID
                    completionHandler(ix)
                } else if ix == -1 {
                    completionHandler(nil)
                } else {
                    DispatchQueue.main.async {
                        guard let navigationController = self.navigationController else {return}
                        let tabVC = navigationController.viewControllers.filter { $0 is TabBarViewController }.first!
                        self.navigationController!.popToViewController(tabVC, animated: true)
                    }
                }
            } catch {
                print("Decoding data failed: \(error)")
            }
        }
    }
    
    
    private func findEmptyPosition() -> Int? {
        guard let room = room else {return nil}
        
        for (i,position) in room.positions.enumerated() {
            if position.isEmpty {
                return i
            }
        }
        return nil
    }
    
    private func setRecentPositions() {
        guard let room = room else {return}
        guard let userUID = UserModel.shared.uid else {return}
        
        for (ix,position) in room.positions.enumerated() {
            if position != userUID && !position.isEmpty {
                guard let uid = UInt(position) else {return}
                
                let videoCanvas = AgoraRtcVideoCanvas()
                videoCanvas.uid = uid
                videoCanvas.renderMode = .hidden
                videoCanvas.view = frames[ix].videoView
                
                frames[ix].userUID = uid
                agoraKit?.setupRemoteVideo(videoCanvas)
            }
        }
    }
    
    //MARK: - Agora Functionss
    private func initializeAndJoinChannel() {
        guard let userUID = UserModel.shared.uid,
              let uid = UInt(userUID) else {return}
        
        setPosition { availablePositionIX in
            guard let availablePositionIX = availablePositionIX else {return}
            
            DispatchQueue.main.async {
                let agoraConfig = AgoraVideoEncoderConfiguration(size: CGSize(width: 424, height: 240), frameRate: .fps15, bitrate: 220, orientationMode: .fixedPortrait)
                
                self.agoraKit?.setVideoEncoderConfiguration(agoraConfig)
                self.agoraKit?.enableVideo()
                self.agoraKit?.setEnableSpeakerphone(true)
                self.agoraKit?.setDefaultAudioRouteToSpeakerphone(true)
                
                let videoCanvas = AgoraRtcVideoCanvas()
                
                self.localFrameIndex = availablePositionIX
                
                videoCanvas.uid = uid
                videoCanvas.renderMode = .hidden
                videoCanvas.view = self.frames[self.localFrameIndex!].videoView
                
                self.frames[self.localFrameIndex!].userUID  = uid
                
                self.agoraKit?.setupLocalVideo(videoCanvas)
                
                self.setRecentPositions()
                self.renderVoteOrbs()
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
        room.positions[emptyPositionIX] = String(uid)
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = frames[emptyPositionIX].videoView
        
        frames[emptyPositionIX].userUID = uid
        
        agoraKit?.setupRemoteVideo(videoCanvas)
        
        print("A remote user has joined the channel with uid: \(uid)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        print("User has left the channel: \(room?.name ?? "nil")")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("Joined Channel!")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, tokenPrivilegeWillExpire token: String) {
        print("Token will expire in 30 seconds.")
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

struct UserRoom: Codable {
    let userUID: String
    let roomID: UUID
}
