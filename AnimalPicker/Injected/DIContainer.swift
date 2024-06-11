//
//  DIContainer.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import SwiftUI
import Combine

// MARK: - DIContainer
struct DIContainer {
    let services: Services
    let interactors: Interactors
    
    init(services: Services, interactors: Interactors) {
        self.services = services
        self.interactors = interactors
    }
}


extension DIContainer {
    struct Services {
        let multiGameService: MultiGameService
//        let realtimeRoomDBService: RealtimeRoomDBService
//        let realtimeMemberDBService: RealtimeMemberDBService
        let keychainService: KeychainService
    }
    
    struct ApiRepositories {
        let foxImageRepository: FoxImageRepository
        let dogImageRepository: DogImageRepository
        let duckImageRepository: DuckImageRepository
        let lizardIamgeRepository: LizardImageRepository
    }
    
    struct DBRepositories {
        let rankingDBRepository: RankingDBRepository
        let rankingWebRepository: RankingWebRepository
    }

    struct Interactors {
        let animalImageInteractor: AnimalImageInteractor
        let rankingInteractor: RankingInteractor
    }
}
