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
    struct ApiRepositories<
        FoxRepo: ImageRepository,
        DogRepo: ImageRepository,
        DuckRepo: ImageRepository,
        LizardRepo: ImageRepository
    >{
        let foxImageRepository: FoxRepo
        let dogImageRepository: DogRepo
        let duckImageRepository: DuckRepo
        let lizardIamgeRepository: LizardRepo
    }
    
    struct DBRepositories {
        let rankingDBRepository: RankingDBRepository
        let rankingWebRepository: RankingWebRepository
    }
}
