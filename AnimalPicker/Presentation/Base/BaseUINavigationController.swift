//
//  BaseUINavigationController.swift
//  AnimalPicker
//
//  Created by Sandy on 6/21/24.
//

import Foundation
import Combine
import UIKit

class BaseUINavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    var swipeBack: (()->())? = nil
    
    
    override open func viewDidLoad() {
        self.hideNavigationBar()
        super.viewDidLoad()
        self.delegate = self
    }

    func attachSwipeBack(swipeBack: @escaping (()->())) {
        self.swipeBack = swipeBack
    }
    
    private func hideNavigationBar() {
        DispatchQueue.main.async {
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.title = nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let coordinator = navigationController.topViewController?.transitionCoordinator {
            coordinator.notifyWhenInteractionChanges({[weak self] (context) in
                guard let self = self else { return }
                print("Is cancelled: \(context.isCancelled)")
                if !context.isCancelled {
                    // 이 시점이 swipe로 back 한 것.
                    self.swipeBack?()
                }
            })
        }
    }
}
