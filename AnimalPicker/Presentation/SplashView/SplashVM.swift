//
//  SplashVM.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Combine

class SplashVM: BaseViewModel {
    private let interactors: DIContainer.Interactors
    
    init(_ interactors: DIContainer.Interactors) {
        self.interactors = interactors
        super.init()
    }
}
