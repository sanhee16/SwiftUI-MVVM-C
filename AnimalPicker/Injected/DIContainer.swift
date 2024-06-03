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
    let interactors: Interactors
    
    init(interactors: Interactors) {
        self.interactors = interactors
    }
}


extension DIContainer {
    struct ApiRepositories{
        let foxImageRepository: any ImageRepository
        let dogImageRepository: any ImageRepository
        let duckImageRepository: any ImageRepository
        let lizardIamgeRepository: any ImageRepository
    }
    
    struct DBRepositories {
        let rankingDBRepository: RankingDBRepository
        let rankingWebRepository: RankingWebRepository
    }
}
