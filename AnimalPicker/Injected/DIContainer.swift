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
    struct ApiRepositories {
        let foxImageRepository: FoxImageRepository
        let dogImageRepository: DogImageRepository
    }
    
    struct DBRepositories {
        
    }
}
