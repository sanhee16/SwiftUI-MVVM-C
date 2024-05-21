//
//  SceneDelegate.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import UIKit
import SwiftUI
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    var subscription = Set<AnyCancellable>()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        guard let window = self.window else { return }
        let environment = AppEnvironment.bootstrap()
        window.overrideUserInterfaceStyle = .light
        // 앱이 background 상태일때가 아닐때는 openURLContexts이 실행안되기 때문에 넣어줌
//        self.scene(scene, openURLContexts: connectionOptions.urlContexts)
        
        print("[LifeCycle] scene 시작!")
        appCoordinator = AppCoordinator(window: window, container: environment.container)
        appCoordinator?.startSplash()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        print("[LifeCycle] sceneDidDisconnect")
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    //MARK: 앱이 일부라도 가려졌다가(시스템 상단바 내림) 돌아올 때 호출
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("[LifeCycle] sceneDidBecomeActive")
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    //MARK: 앱이 일부라도 가려지거나 백그라운드로 갈 때 호출
    func sceneWillResignActive(_ scene: UIScene) {
        print("[LifeCycle] sceneWillResignActive")
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    //MARK: 앱 시작 or 백그라운드->포그라운드 진입시 호출
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("[LifeCycle] sceneWillEnterForeground")
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func changeRootVC(_ vc:UIViewController, animated: Bool) {
        guard let window = self.window else { return }
        window.rootViewController = vc // 전환
        
        UIView.transition(with: window, duration: 0.2, options: [.transitionCrossDissolve], animations: nil, completion: nil)
    }
}

