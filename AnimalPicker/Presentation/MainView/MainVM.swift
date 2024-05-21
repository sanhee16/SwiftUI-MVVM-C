//
//  MainVM.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Combine
import UIKit

class MainVM: BaseViewModel {
    private let interactors: DIContainer.Interactors
    let levels: [Level] = [.easy, .normal, .hard, .hell]
    
    init(_ coordinator: AppCoordinator, interactors: DIContainer.Interactors) {
        self.interactors = interactors
        super.init(coordinator)
    }
    
    func onAppear() {
        
    }
    
    func onDisappear() {
        
    }
    
    func onClickLevel(level: Level) {
        self.coordinator?.pushGameView(level: level)
    }
}
