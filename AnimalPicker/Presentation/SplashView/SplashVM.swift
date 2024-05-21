//
//  SplashVM.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Combine
import UIKit

class SplashVM: BaseViewModel {
    private let interactors: DIContainer.Interactors
    
    init(_ coordinator: AppCoordinator, interactors: DIContainer.Interactors) {
        self.interactors = interactors
        super.init(coordinator)
    }
    
    func onAppear() {
        MoveToMain()
    }
    
    private func MoveToMain() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {[weak self] in
            self?.coordinator?.pushMain()
        }
    }
}
