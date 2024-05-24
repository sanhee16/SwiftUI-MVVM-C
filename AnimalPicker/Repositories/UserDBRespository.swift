//
//  UserDBRespository.swift
//  AnimalPicker
//
//  Created by Sandy on 5/24/24.
//

import Foundation

protocol UserDBRespository {
    func loadUserInfo() -> UserInfo
    func saveUserInfo(userInfo: UserInfo)
}

class RealUserDBRespository: UserDBRespository {
    var userDefaultsService: UserDefaultsService
    
    init(userDefaultsService: UserDefaultsService) {
        self.userDefaultsService = userDefaultsService
    }
    
    func loadUserInfo() -> UserInfo {
        return UserInfo(nickname: userDefaultsService.nickname, password: userDefaultsService.password)
    }
    
    func saveUserInfo(userInfo: UserInfo) {
        userDefaultsService.nickname = userInfo.nickname
        userDefaultsService.password = userInfo.password
    }
}