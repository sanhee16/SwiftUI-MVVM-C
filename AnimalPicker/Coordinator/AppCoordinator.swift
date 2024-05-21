//
//  AppCoordinator.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import SwiftUI

class AppCoordinator: BaseCoordinator, Terminatable {
    // UIWindow = 화면에 나타나는 View를 묶고, UI의 배경을 제공하고, 이벤트 처리행동을 제공하는 객체 = View들을 담는 컨테이너
    let window: UIWindow
    let container: DIContainer
    /*
     SceneDelegate에서 window rootViewController 설정해줘야 하는데 window 여기로 가지고와서 여기서 설정해줌
     */
    init(window: UIWindow, container: DIContainer) { // SceneDelegate에서 호출
        self.window = window
        self.container = container
        
        super.init() // Coordinator init
        let navigationController = UINavigationController()
        self.navigationController = navigationController // Coordinator의 navigationController
        
        // rootViewController 지정 + makeKeyAndVisible 호출 = 지정한 rootViewController가 상호작용을 받는 현재 화면으로 세팅 완료
        self.window.rootViewController = navigationController // window의 rootViewController
        window.makeKeyAndVisible()
    }
    
    // Terminatable
    func appTerminate() {
        print("app Terminate")
//        for vc in self.childViewControllers {
//            print("terminate : \(type(of: vc))")
//            (vc as? Terminatable)?.appTerminate()
//        }
        for vc in self.navigationController.viewControllers {
            print("terminate : \(type(of: vc))")
            (vc as? Terminatable)?.appTerminate()
        }
        print("terminate : \(type(of: self.navigationController))")
        (self.navigationController as? Terminatable)?.appTerminate()
    }
    
    func popToRoot(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.navigationController.popToRootViewController(animated: animated)
        self.childViewController.removeAll()
        completion?()
    }
    
    //MARK: Start
    func startSplash() {
        let vc = SplashView.vc(self, interactors: self.container.interactors)
        self.push(vc, animated: true)
    }
    
    //MARK: Main
    func startMain() {
        let vc = MainView.vc(self, interactors: self.container.interactors)
        self.push(vc, animated: false)
    }
}
