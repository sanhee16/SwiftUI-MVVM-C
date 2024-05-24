//
//  AuthVM.swift
//  AnimalPicker
//
//  Created by Sandy on 5/24/24.
//

import Foundation
import Combine

class AuthVM: BaseViewModel {
    enum AuthStatus {
        case join
        case login
        case loading
    }
    private let interactors: DIContainer.Interactors
    @Published var status: AuthStatus = .loading
    
    init(_ interactors: DIContainer.Interactors) {
        self.interactors = interactors
        super.init()
    }
    
    func onAppear() {
        self.loadAuthStatus()
    }
    
    func onDisappear() {
        
    }
    
    private func loadAuthStatus() {
        guard let userInfo = self.interactors.userInfoInteractor.loadUserInfo() else {
            self.status = .join
            return
        }
        self.status = .login
    }
}
