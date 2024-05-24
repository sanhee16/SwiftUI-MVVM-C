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
        let foxImageRepository = RealFoxImageRepository(network: BaseNetwork(), baseUrl: "https://randomfox.ca")
        let dogImageRepository = RealDogImageRepository(network: BaseNetwork(), baseUrl: "https://dog.ceo/api")
        let duckImageRepository = RealDuckImageRepository(network: BaseNetwork(), baseUrl: "https://random-d.uk/api/v2")
        let lizardIamgeRepository = RealLizardImageRepository(network: BaseNetwork(), baseUrl: "https://nekos.life/api/v2")
        return .init(
            foxImageRepository: foxImageRepository,
            dogImageRepository: dogImageRepository,
            duckImageRepository: duckImageRepository,
            lizardIamgeRepository: lizardIamgeRepository
        )
    }
    
    private static func configuredDBRepositories() -> DIContainer.DBRepositories {
        let userDBRespository = RealUserDBRespository(userDefaultsService: UserDefaultsService())
        return .init(userDBRespository: userDBRespository)
    }
    
    private static func configuredInteractors(
        dbRepositories: DIContainer.DBRepositories,
        apiRepositories: DIContainer.ApiRepositories
    ) -> DIContainer.Interactors {
        let animalImageInteractor = RealAnimalImageInteractor(
            foxImageRepository: apiRepositories.foxImageRepository,
            dogImageRepository: apiRepositories.dogImageRepository,
            duckImageRepository: apiRepositories.duckImageRepository,
            lizardIamgeRepository: apiRepositories.lizardIamgeRepository
        )
        let userInfoInteractor = RealUserInfoInteractor(userDBRespository: dbRepositories.userDBRespository)
        return .init(animalImageInteractor: animalImageInteractor, userInfoInteractor: userInfoInteractor)
    }
}
