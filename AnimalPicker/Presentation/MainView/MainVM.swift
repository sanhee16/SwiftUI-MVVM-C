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
    
    init(_ coordinator: AppCoordinator, interactors: DIContainer.Interactors) {
        self.interactors = interactors
        super.init(coordinator)
    }
    
    func onAppear() {
        print("Start Main!")
    }
}
