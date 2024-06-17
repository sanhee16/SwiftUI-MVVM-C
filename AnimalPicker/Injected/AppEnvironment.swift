//
//  AppEnvironment.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import CoreData

struct AppEnvironment {
    let container: DIContainer
}

extension AppEnvironment {
    static func bootstrap() -> AppEnvironment {
        let services = configuredServices()
        let apiRepositories = configuredApiRepositories()
        let dbRepositories = configuredDBRepositories()
        let interactors = configuredInteractors(
            dbRepositories: dbRepositories,
            apiRepositories: apiRepositories
        )

        let diContainer = DIContainer(services: services, interactors: interactors)

        return AppEnvironment(container: diContainer)
    }
    
    private static func configuredApiRepositories() -> DIContainer.ApiRepositories{
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
    private static func configuredServices() -> DIContainer.Services {
        let multiGameService = MultiGameService()
        let keychainService = KeychainService()
        return .init(
            multiGameService: multiGameService,
            keychainService: keychainService
        )
    }
    
    private static func configuredDBRepositories() -> DIContainer.DBRepositories {
        let coredataService = CoreDataService()
        let firestoreService = FirestoreService()
        
        let rankingDBRepository = RealRankingDBRepository(
            userDefaultsService: UserDefaultsService(),
            coredataService: coredataService
        )
        let rankingWebRepository = RealRankingWebRepository(
            firestoreServcice: firestoreService
        )
        
        return .init(
            rankingDBRepository: rankingDBRepository,
            rankingWebRepository: rankingWebRepository
        )
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
        let rankingInteractor = RealRankingInteractor(
            rankingDBRepository: dbRepositories.rankingDBRepository,
            rankingWebRepository: dbRepositories.rankingWebRepository
        )
        
        return .init(
            animalImageInteractor: animalImageInteractor,
            rankingInteractor: rankingInteractor
        )
    }
}
