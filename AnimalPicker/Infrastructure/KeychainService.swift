//
//  KeychainService.swift
//  AnimalPicker
//
//  Created by Sandy on 6/4/24.
//

import Foundation

enum KeyChainKeys: String {
    case deviceId
}

enum KeychainError: Error {
    case itemNotFound
    case duplicateItem
    case invalidItemFormat
    case unknown(OSStatus)
}

extension KeychainService {
    func loadDeviceId() -> String? {
        do {
            let data = try self.load(key: KeyChainKeys.deviceId)
            return data
        } catch {
            print(error)
            do {
                try self.save(key: KeyChainKeys.deviceId, value: UUID().uuidString)
                return loadDeviceId()
            } catch {
                return nil
            }
        }
    }
}

class KeychainService {
    private let service = Bundle.main.bundleIdentifier
    
    // MARK: - Save
    func save(key: KeyChainKeys, value: String, isForce: Bool = true) throws {
        try saveData(account: key.rawValue, value: value.data(using: .utf8)!, isForce: isForce)
    }
    
    private func saveData(account: String, value: Data, isForce: Bool = false) throws {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: value as AnyObject,
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            if isForce {
                try updateData(account: account, value: value)
                return
            } else {
                throw KeychainError.duplicateItem
            }
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
    
    // MARK: - Update
    func update(key: KeyChainKeys, value: String) throws {
        try updateData(account: key.rawValue, value: value.data(using: .utf8)!)
    }
    
    private func updateData(account: String, value: Data) throws {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: value as AnyObject,
        ]
        
        let attributes: [String: AnyObject] = [
            kSecValueData as String: value as AnyObject
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateItem
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
    
    // MARK: - Load
    func load(key: KeyChainKeys) throws -> String {
        try String(decoding: loadData(account: key.rawValue), as: UTF8.self)
    }
    
    private func loadData(account: String) throws -> Data {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue,
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
        
        guard let password = result as? Data else {
            throw KeychainError.invalidItemFormat
        }
        
        return password
    }
    
    // MARK: - Delete
    func delete(key: KeyChainKeys) throws {
        try deleteData(account: key.rawValue)
    }
    
    private func deleteData(account: String) throws {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
}
