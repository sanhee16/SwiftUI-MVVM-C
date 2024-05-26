//
//  UserInfoInteractor.swift
//  AnimalPicker
//
//  Created by Sandy on 5/24/24.
//

import Foundation

protocol RankingInteractor {
    func loadRankings() -> UserInfo?
    func saveRanking(userInfo: UserInfo) -> SaveUserInfoResult
}

struct RealRankingInteractor: RankingInteractor {
    let rankingDBRespository: RankingDBRespository
    
//    func loadUserInfo() -> UserInfo? {
//        let userInfo = userDBRespository.loadUserInfo()
//        return (userInfo.nickname.isEmpty || userInfo.password.isEmpty) ? nil : userInfo
//    }
//    
//    func saveUserInfo(userInfo: UserInfo) -> SaveUserInfoResult {
//        if userInfo.nickname.isEmpty { return SaveUserInfoResult.wrongNickname }
//        if userInfo.password.isEmpty { return SaveUserInfoResult.wrongPassword }
//        userDBRespository.saveUserInfo(userInfo: userInfo)
//        return SaveUserInfoResult.success
//    }
}
