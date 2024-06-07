//
//  MultiGameVM.swift
//  AnimalPicker
//
//  Created by Sandy on 6/3/24.
//

import Foundation
import Combine

enum MultiGameStatus: String {
    case none = "none"
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
    let types: [ImageType] = [.dog, .fox, .duck, .lizard]
    var countWithType: [ImageType: Int] = [:]
    let deviceId: String
    var items: [GameItem] = []
    var answer: ImageType? = nil
    private var timer: Timer? = nil
    
    @Published var elapsedTime: Float? = nil
    @Published var members: [MultiGameMemberData] = []
    
    @Published var roomData: RoomData
    @Published var isCorrect: Bool = false
    @Published var isGaming: Bool = false
    @Published var myStatus: MultiGameStatus = .none
    
    @Published var ranking: [RankingData] = []
    
    
    init(_ interactors: DIContainer.Interactors, services: DIContainer.Services, roomData: RoomData) {
        self.interactors = interactors
        self.services = services
        self.roomData = roomData
        self.deviceId = services.keychainService.loadDeviceId()
        super.init()
        
        self.services.realtimeMemberDBService.updateRoomId(roomId: self.roomData.id)
        self.services.realtimeRoomDBService.updateRoomId(roomId: self.roomData.id)
        self.observe()
    }
    
    func onAppear() {
        
    }
    
    func onDisappear() {
        
    }
    
    func reset() {
        self.myStatus = .none
        self.services.realtimeMemberDBService.changeStatus(memberId: self.deviceId, status: self.myStatus)
    }
    
    func onClickStart() {
        if MultiGameStatus(rawValue: self.roomData.status) != .ready { return }
        self.services.realtimeRoomDBService.changeStatus(status: MultiGameStatus.loading)
        self.loadData()
    }
    
    func onClickReady() {
        self.myStatus = self.myStatus == .none ? .ready : .none
        self.services.realtimeMemberDBService.changeStatus(memberId: self.deviceId, status: self.myStatus)
    }
    
    func loadData() {
        print("loadData")
        if MultiGameStatus(rawValue: self.roomData.status) != .loading { return }
        self.loadImages(level: .multi)
    }
    
    private func onGameStop() {
        self.services.realtimeMemberDBService.changeStatus(memberId: self.deviceId, status: self.myStatus)
    }
    
    func onSelectItem(item: GameItem) {
        if isCorrect { return }
        guard let _ = self.answer, let idx = self.items.firstIndex(where: { $0.id == item.id }) else { return }
        self.items[idx].isSelected.toggle()
        self.objectWillChange.send()
        
        if self.items.filter({ $0.type == self.answer && !$0.isSelected}).isEmpty && self.items.filter({ $0.type != self.answer && $0.isSelected}).isEmpty {
            self.stopTimer()
            
            self.myStatus = .clear
            if let elapsedTime = self.elapsedTime {
                self.services.realtimeMemberDBService.clear(memberId: self.deviceId, time: elapsedTime)
            }
        }
    }
    
    func onLoadSuccess(item: GameItem) {
        if let idx = self.items.firstIndex(of: item) {
            self.items[idx].isLoaded = true
        }
        
        if self.items.filter({ !$0.isLoaded }).isEmpty {
            self.myStatus = .loadFinish
            self.services.realtimeMemberDBService.changeStatus(memberId: self.deviceId, status: self.myStatus)
        }
    }
    
    private func startTimeCount() {
        self.stopTimer()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }

    @objc
    func timerFired() {
        if let elapsedTime = self.elapsedTime {
            self.elapsedTime = elapsedTime + 0.1
        }
    }

    private func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    private func loadImages(level: Level) {
        self.items.removeAll()
        self.countWithType.removeAll()
        self.myStatus = .loading
        self.answer = nil
        
        let totalCount = level.cell.row * level.cell.column
        let distributeTotalCount = distributeTotalCount(totalCount: totalCount, into: self.types.count)

        self.types.indices.forEach({
            countWithType.updateValue(distributeTotalCount[$0], forKey: self.types[$0])
        })
        if countWithType.isEmpty { return }
        
        Publishers.Zip4(
            self.interactors.animalImageInteractor.getDogImages(countWithType[.dog]),
            self.interactors.animalImageInteractor.getFoxImages(countWithType[.fox]),
            self.interactors.animalImageInteractor.getDuckImages(countWithType[.duck]),
            self.interactors.animalImageInteractor.getLizardImages(countWithType[.lizard])
        )
        .run(in: &self.subscription) {[weak self] (dogs, foxes, ducks, lizards) in
            guard let self = self else { return }
            var idx: Int = 0
            self.items.removeAll()
            
            dogs.forEach {
                self.items.append(GameItem(id: idx, type: .dog, url: $0.imageUrl))
                idx += 1
            }
            foxes.forEach {
                self.items.append(GameItem(id: idx, type: .fox, url: $0.imageUrl))
                idx += 1
            }
            ducks.forEach {
                self.items.append(GameItem(id: idx, type: .duck, url: $0.imageUrl))
                idx += 1
            }
            lizards.forEach {
                self.items.append(GameItem(id: idx, type: .lizard, url: $0.imageUrl))
                idx += 1
            }
            print("self.items: \(self.items)")
            self.items.shuffle()
            self.elapsedTime = 0
            self.answer = self.types.randomElement()
            self.services.realtimeRoomDBService.saveImages(imageUrls: self.items.map({ $0.url }))
        }
    }
    
    private func distributeTotalCount(totalCount: Int, into n: Int) -> [Int] {
        guard n > 0, totalCount >= n else { return [] }
        
        var result: [Int] = []
        var remainingCount = totalCount - self.types.count
        
        for _ in 1..<n {
            let maxPossibleValue = remainingCount - (n - result.count)
            let randomValue = Int.random(in: 1...maxPossibleValue)
            result.append(randomValue + 1)
            remainingCount -= randomValue
        }
        
        // 마지막 남은 수를 결과 배열에 추가하여 totalCount와 동일하게 만듦
        result.append(remainingCount + 1)
        
        return result
    }
    
    func observe() {
        self.services.realtimeMemberDBService.memberChangedSubject
            .run(in: &self.subscription) {[weak self] response in
                guard let self = self else { return }
                self.members = response
                if self.members.filter({ MultiGameStatus(rawValue: $0.status) != MultiGameStatus.none }).isEmpty {
                    self.services.realtimeRoomDBService.changeStatus(status: MultiGameStatus.none)
                } else if self.members.filter({ MultiGameStatus(rawValue: $0.status) != MultiGameStatus.ready }).isEmpty {
                    self.services.realtimeRoomDBService.changeStatus(status: MultiGameStatus.ready)
                } else if MultiGameStatus(rawValue: self.roomData.status) == .loadFinish {
                    if self.members.filter({ MultiGameStatus(rawValue: $0.status) != MultiGameStatus.loadFinish }).isEmpty {
                        self.services.realtimeRoomDBService.changeStatus(status: MultiGameStatus.onGaming)
                    }
                } else if MultiGameStatus(rawValue: self.roomData.status) == .clear {
                    if self.members.filter({ MultiGameStatus(rawValue: $0.status) != MultiGameStatus.clear }).isEmpty {
                        self.services.realtimeRoomDBService.changeStatus(status: MultiGameStatus.clear)
                        self.onGameStop()
                    }
                }
                
            } err: {[weak self] err in
                guard let self = self else { return }
                print(err)
            } complete: {
                
            }
        
        self.services.realtimeRoomDBService.roomChangedSubject
            .run(in: &self.subscription) {[weak self] response in
                guard let self = self, let response = response else { return }
                self.roomData = response
                if MultiGameStatus(rawValue: self.roomData.status) == .onGaming {
                    self.myStatus = .onGaming
                    self.startTimeCount()
                } else if MultiGameStatus(rawValue: self.roomData.status) == .ready, let items = response.items, !items.isEmpty {
                    //TODO: create Game Items
                    self.items = items.map({ GameItem(id: <#T##Int#>, type: <#T##ImageType#>, url: <#T##String#>) })
                }
            } err: {[weak self] err in
                guard let self = self else { return }
                print(err)
            } complete: {
                
            }
    }
}

