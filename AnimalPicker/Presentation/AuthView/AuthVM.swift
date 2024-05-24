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
    enum LoginError {
        case nickname
        case password
        case userInfo
    }
    
    
    private let interactors: DIContainer.Interactors
    @Published var status: AuthStatus = .loading
    @Published var loginError: LoginError? = nil
    var userInfo: UserInfo? = nil
    init(_ interactors: DIContainer.Interactors) {
        self.interactors = interactors
        super.init()
    }
    
    func onAppear() {
        self.loadAuthStatus()
    }
    
    func onDisappear() {
        
    }
    
    func onClickLogin(nickname: String, password: String) {
        guard let userInfo = self.userInfo else { 
            loginError = .userInfo
            return
        }
        
        if userInfo.nickname != nickname {
            loginError = .nickname
            return
        } else if userInfo.password != password {
            loginError = .password
            return
        }
        
    }
    
    private func loadAuthStatus() {
        guard let userInfo = self.interactors.userInfoInteractor.loadUserInfo() else {
            self.status = .join
            return
        }
        
        self.userInfo = userInfo
        self.status = .login
    }
}
