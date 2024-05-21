//
//  AppEnvironment.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation

struct AppEnvironment {
    let container: DIContainer
}

extension AppEnvironment {
    static func bootstrap() -> AppEnvironment {
        let apiRepositories = configuredApiRepositories()
        let dbRepositories = configuredDBRepositories()
        let interactors = configuredInteractors(
            dbRepositories: dbRepositories,
            apiRepositories: apiRepositories
        )

        let diContainer = DIContainer(interactors: interactors)

        return AppEnvironment(container: diContainer)
    }
    
    private static func configuredApiRepositories() -> DIContainer.ApiRepositories {
        return .init()
    }
    
    private static func configuredDBRepositories() -> DIContainer.DBRepositories {
        return .init()
    }
    
    private static func configuredInteractors(
        dbRepositories: DIContainer.DBRepositories,
        apiRepositories: DIContainer.ApiRepositories
    ) -> DIContainer.Interactors {
        
        return .init()
    }
}
