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
    @Published var isMoveToMain: Bool = false
    
    
    init(_ interactors: DIContainer.Interactors) {
        self.interactors = interactors
        super.init()
    }
    
    func onAppear() {
        self.saveUnsyncedData()
    }
    
    private func saveUnsyncedData() {
        print("uploadUnsyncedData")
        self.interactors.rankingInteractor.uploadUnsyncedData()
            .run(in: &self.subscription) { isSuccess in
                
            } err: { err in
                
            } complete: {[weak self] in
                self?.isMoveToMain = true
            }
    }
}
