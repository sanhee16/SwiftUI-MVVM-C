//
//  UserDefaultsService.swift
//  AnimalPicker
//
//  Created by Sandy on 5/24/24.
//

import Foundation

enum UserDefaultsKeys: String {
    case nickname
    case password
}

class UserDefaultsService {
    @UserDefault<String>(key: UserDefaultsKeys.nickname.rawValue, defaultValue: "")
    var nickname
    
    @UserDefault<String>(key: UserDefaultsKeys.password.rawValue, defaultValue: "")
    var password
}

@propertyWrapper struct UserDefault<T> {
    private let key: String
    private let defaultValue: T
    
    var wrappedValue: T {
        get { (UserDefaults.standard.object(forKey: self.key) as? T) ?? self.defaultValue }
        set { UserDefaults.standard.setValue(newValue, forKey: key) }
    }
    
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
}
