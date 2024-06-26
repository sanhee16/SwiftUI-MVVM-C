//
//  MainVM.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Combine

class MainVM: BaseViewModel {
    private let interactors: DIContainer.Interactors
    let levels: [Level] = [.easy, .normal, .hard, .hell]
    
    init(_ interactors: DIContainer.Interactors) {
        self.interactors = interactors
        super.init()
    }
}
