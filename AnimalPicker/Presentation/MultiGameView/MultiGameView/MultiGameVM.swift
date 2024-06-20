//
//  MultiGameVM.swift
//  AnimalPicker
//
//  Created by Sandy on 6/3/24.
//

import Foundation
import Combine

enum MultiGameStatus: String {
    case ready = "ready"
    case loading = "loading"
    case onGaming = "onGaming"
    case loadFinish = "loadFinish"
    case clear = "clear"
    case finish = "finish"
}

class MultiGameVM: BaseViewModel {
    private let interactors: DIContainer.Interactors
    private let services: DIContainer.Services
    let level: Level = .multi
    let deviceId: String
    var items: [GameItem] = []
    var answer: String? = nil
    private var timer: Timer? = nil
    @Published var isManager: Bool = false
    
    @Published var elapsedTime: Float? = nil
    @Published var members: [MultiGameMemberData] = []
    
    @Published var roomData: RoomData
    @Published var isCorrect: Bool = false
    @Published var isGaming: Bool = false
    @Published var myStatus: MultiGameStatus = .ready
    
    @Published var ranking: [RankingData] = []
    
    init(_ interactors: DIContainer.Interactors, services: DIContainer.Services, roomData: RoomData) {
        self.interactors = interactors
        self.services = services
        self.roomData = roomData
        self.deviceId = services.keychainService.loadDeviceId()
        super.init()
        
        if self.roomData.managerId == self.deviceId {
            self.isManager = true
        }
        self.services.multiGameService.startToRoomObserve(roomId: self.roomData.id)
        if self.isManager {
            self.services.multiGameService.allClear(roomId: self.roomData.id)
        }
            
        self.observe()
        self.reset()
    }
    
    func onAppear() {
    }
    
    func onDisappear() {
        
    }
    
    //MARK: Reset
    func reset() {
        self.items.removeAll()
        self.myStatus = .ready
        self.answer = nil
        
        self.services.multiGameService.ready(roomId: self.roomData.id, memberId: self.deviceId)
    }
    
    //MARK: Start (방장)
    func onClickStart() {
        self.services.multiGameService.allReady(roomId: self.roomData.id)
        
        // 방 -> Loading으로 변경
        if !self.isManager { return }
        
        loadImages()
        
        func loadImages() {
            self.items.removeAll()
            self.answer = nil
            
            self.interactors.animalImageInteractor.generateGameItems(level: self.level)
                .run(in: &self.subscription) {[weak self] response in
                    guard let self = self else { return }
                    let newAnswer = response.answer.rawValue
                    let newItems = response.items
                    
                    // 서버에 전송
                    print("[방장] 서버에 전송!")
                    self.services.multiGameService.loadGameItems(
                        roomId: self.roomData.id,
                        answer: newAnswer,
                        items: newItems
                    )
                } err: {[weak self] err in
                    guard let self = self else { return }
                    print(err)
                } complete: {
                    
                }
        }
    }
    
    func onClickQuitRoom() {
        self.services.multiGameService.removeMember(roomId: self.roomData.id, memberId: self.deviceId)
    }
    
    func onClickDeleteRoom() {
        self.services.multiGameService.removeRoom(roomId: self.roomData.id)
    }
    
    func onClickDeleteMember(memberId: String) {
        self.services.multiGameService.removeMember(roomId: self.roomData.id, memberId: memberId)
    }
    
    //MARK: Timer
    private func startTimeCount() {
        print("startTimeCount")
        self.stopTimer()
        self.elapsedTime = 0
        DispatchQueue.global(qos: .background).async {
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerFired), userInfo: nil, repeats: true)
                RunLoop.current.run()
            }
    }
    
    @objc
    func timerFired() {
        if let elapsedTime = self.elapsedTime {
            self.elapsedTime = elapsedTime + 0.1
        }
    }
    
    private func stopTimer() {
        print("stopTimer!")
        self.timer?.invalidate()
        self.timer = nil
    }
    
    
    //MARK: onSelect
    func onSelectItem(item: GameItem) {
        if isCorrect { return }
        guard let _ = self.answer, let idx = self.items.firstIndex(where: { $0.id == item.id }) else { return }
        self.items[idx].isSelected.toggle()
        self.objectWillChange.send()
        
        if self.items.filter({ $0.type == self.answer && !$0.isSelected}).isEmpty && self.items.filter({ $0.type != self.answer && $0.isSelected}).isEmpty {
            if let elapsedTime = self.elapsedTime {
                self.stopTimer()
                self.myStatus = .clear
                self.services.multiGameService.clear(roomId: self.roomData.id, memberId: self.deviceId, time: elapsedTime)
            }
        }
    }
    
    func onLoadSuccess(item: GameItem) {
        if let idx = self.items.firstIndex(of: item) {
            self.items[idx].isLoaded = true
        }
        
        if self.items.filter({ !$0.isLoaded }).isEmpty {
            print("onLoadSuccess!")
            self.myStatus = .loadFinish
            self.services.multiGameService.finishToLoadImages(roomId: self.roomData.id, memberId: self.deviceId)
        }
    }
    
    func observe() {
        self.services.multiGameService.roomListSubject
            .run(in: &self.subscription) {[weak self] response in
                guard let self = self else { return }
                // 방이 사라짐
                if response.first(where: { $0.id == self.roomData.id }) == nil {
                    self.isPop = true
                }
            } err: { err in
                print(err)
            } complete: {
                
            }
        
        //MARK: Member Change
        self.services.multiGameService.roomSubject
            .run(in: &self.subscription) {[weak self] response in
                guard let self = self, let response = response else { return }
                self.roomData = response
                print("response: \(response)")
                
                self.members = self.roomData.members?.compactMap({ $0.value }) ?? []
                
                // 방장일 때
                if self.isManager {
                    if MultiGameStatus(rawValue: self.roomData.status) == .loading, self.members.count == self.members.filter({ MultiGameStatus(rawValue: $0.status) == .loadFinish }).count {
                        print("모두가 로드 완료")
                        self.services.multiGameService.allFinishToLoadImages(roomId: self.roomData.id)
                    } else if MultiGameStatus(rawValue: self.roomData.status) == .onGaming, self.members.count == self.members.filter({ MultiGameStatus(rawValue: $0.status) == .clear }).count {
                        print("모두가 문제 풀이 완료")
                        self.services.multiGameService.allClear(roomId: self.roomData.id)
                    }
                }
                
                // 방에서 퇴출당했을 때
                if self.members.first(where: { $0.id == self.deviceId }) == nil {
                    self.isPop = true
                }
                
                if MultiGameStatus(rawValue: self.roomData.status) == .ready, self.myStatus != .ready {
                    self.reset()
                } else if MultiGameStatus(rawValue: self.roomData.status) == .loading, self.myStatus == .ready {
                    // 이미지 로드중..
                    print("이미지 로드 시작!")
                    self.myStatus = .loading
                    if let responseItem = response.items, !responseItem.isEmpty {
                        self.items = responseItem
                        self.answer = response.answer
                    }
                } else if MultiGameStatus(rawValue: self.roomData.status) == .onGaming, self.myStatus == .loadFinish {
                    // 게임 시작
                    print("게임 시작!")
                    self.myStatus = .onGaming
                    self.startTimeCount()
                } else if MultiGameStatus(rawValue: self.roomData.status) == .clear, self.myStatus == .clear {
                    // 모두 게임 끝!
                    print("게임 끝!")
                    self.myStatus = .finish
                }
            } err: { err in
                print(err)
            } complete: {
                
            }
    }
}

