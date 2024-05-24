//
//  UserInfoInteractor.swift
//  AnimalPicker
//
//  Created by Sandy on 5/24/24.
//

import Foundation

enum SaveUserInfoResult {
    case success
    case wrongPassword
    case wrongNickname
}

protocol UserInfoInteractor {
    func loadUserInfo() -> UserInfo?
    func saveUserInfo(userInfo: UserInfo) -> SaveUserInfoResult
}

struct RealUserInfoInteractor: UserInfoInteractor {
    let userDBRespository: UserDBRespository
    
    func loadUserInfo() -> UserInfo? {
        let userInfo = userDBRespository.loadUserInfo()
        return (userInfo.nickname.isEmpty || userInfo.password.isEmpty) ? nil : userInfo
    }
    
    func saveUserInfo(userInfo: UserInfo) -> SaveUserInfoResult {
        if userInfo.nickname.isEmpty { return SaveUserInfoResult.wrongNickname }
        if userInfo.password.isEmpty { return SaveUserInfoResult.wrongPassword }
        userDBRespository.saveUserInfo(userInfo: userInfo)
        return SaveUserInfoResult.success
    }
}
