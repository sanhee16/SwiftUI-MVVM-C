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
        let keychainService: KeychainService
    }
    
    struct ApiRepositories {
        let foxImageRepository: any ImageRepository
        let dogImageRepository: any ImageRepository
        let duckImageRepository: any ImageRepository
        let lizardIamgeRepository: any ImageRepository
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
