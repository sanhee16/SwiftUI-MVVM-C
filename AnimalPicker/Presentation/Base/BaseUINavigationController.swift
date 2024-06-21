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
    override open func viewDidLoad() {
        self.hideNavigationBar()
        super.viewDidLoad()
        self.delegate = self
    }
    
    private func hideNavigationBar() {
        DispatchQueue.main.async {
            self.navigationController?.isNavigationBarHidden = true
            self.navigationController?.title = nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let coordinator = navigationController.topViewController?.transitionCoordinator {
            coordinator.notifyWhenInteractionChanges({ (context) in
                print("Is cancelled: \(context.isCancelled)")
            })
        }
    }
}
