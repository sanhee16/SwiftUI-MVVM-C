//
//  BaseCoordinator.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import SwiftUI

class BaseCoordinator {
    var navigationController: BaseUINavigationController
    var childViewController: [UIViewController]
    var presentViewController: UIViewController {
        get {
            return childViewController.last ?? navigationController
        }
    }
    
    init() {
        self.navigationController = BaseUINavigationController()
        self.childViewController = []
        
        self.navigationController.attachSwipeBack {[weak self] in
            self?.swipePop()
        }
    }
    
    //MARK: Present & Dismiss
    func present(_ vc: UIViewController, animated: Bool = true, onDismiss: (() -> Void)? = nil) {
        if let vc = vc as? Dismissible {
            vc.attachDismissCallback(onDismiss: onDismiss)
        }
        
        self.presentViewController.present(vc, animated: animated)
        self.childViewController.append(vc)
    }
    
    func dismiss(_ animated: Bool = true, completion: (() -> Void)? = nil) {
        if self.presentViewController == navigationController {
            completion?()
            return
        }
        
        weak var dismissedVc = self.childViewController.removeLast()
        dismissedVc?.dismiss(animated: animated) {
            if let baseViewController = dismissedVc as? Dismissible, let onDismiss = baseViewController.onDismiss {
                onDismiss()
            }
            completion?()
        }
    }
    
    func showSystemAlert(title: String, message: String) {
        func moveToAppSetting() {
            DispatchQueue.main.async {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let completeAction = UIAlertAction(title: "확인", style: .destructive) {[weak self] action in
                self?.dismiss()
                moveToAppSetting()
            }
            let cancelAction = UIAlertAction(title: "취소", style: .default) {[weak self] action in
                self?.dismiss()
            }
            
            alertVC.addAction(completeAction)
            alertVC.addAction(cancelAction)
            self.present(alertVC)
        }
    }
    
    
    //MARK: Push & Pop
    func push(_ vc: UIViewController, animated: Bool = true, onDismiss: (() -> Void)? = nil) {
        if let vc = vc as? Dismissible {
            vc.attachDismissCallback(onDismiss: onDismiss)
        }
        
        self.navigationController.pushViewController(vc, animated: animated)
        self.childViewController.append(vc)
    }
    
    func popToVC<View>(_ view: View.Type, animated: Bool = true) {
        if self.isHasView(view) {
            for viewController in self.childViewController.reversed() {
                if let vc = viewController as? Nameable, vc.isSameView(view: view) {
                    self.navigationController.popToViewController(viewController, animated: false)
                    if let baseViewController = vc as? Dismissible, let onDismiss = baseViewController.onDismiss {
                        onDismiss()
                    }
                    break
                }
                self.childViewController.removeLast()
            }
        }
    }
    
    func swipePop() {
        weak var dismissedVc = self.childViewController.removeLast()
        if let baseViewController = dismissedVc as? Dismissible, let onDismiss = baseViewController.onDismiss {
            onDismiss()
        }
    }
    
    func pop(_ animated: Bool = true, completion: (() -> Void)? = nil) {
        if self.presentViewController == navigationController {
            completion?()
            return
        }
        
        weak var dismissedVc = self.childViewController.removeLast()
        self.navigationController.popViewController(animated: animated)
        if let baseViewController = dismissedVc as? Dismissible, let onDismiss = baseViewController.onDismiss {
            onDismiss()
        }
        completion?()
    }
    
    func change(_ vc: UIViewController, animated: Bool = false, onDismiss: (() -> Void)? = nil) {
        pop(false) {[weak self] in
            self?.push(vc, animated: animated, onDismiss: onDismiss)
        }
    }
    
    //MARK: HasView
    func isHasView<View>(_ view: View.Type) -> Bool {
        for vc in self.navigationController.viewControllers {
            if let named = vc as? Nameable, named.isSameView(view: view) {
                return true
            }
        }
        return false
    }
    
    func isCurrentVC<View>(_ view: View.Type) -> Bool {
        if let named = self.presentViewController as? Nameable, named.isSameView(view: view) {
            return true
        }
        return false
    }
}
