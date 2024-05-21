//
//  BaseVM.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import SwiftUI
import Combine
import UIKit
import Alamofire

class BaseViewModel: ObservableObject {
    weak var coordinator: AppCoordinator? = nil
    var subscription = Set<AnyCancellable>()
    
    @Published var isFinishLoad: Bool = false
    @Published var isLoading: Bool = false
    
    private var showToastWork: DispatchWorkItem? = nil
    @Published var isShowToast = false { didSet {
        self.showToastWork?.cancel()
        
        if self.isShowToast {
            self.showToastWork = DispatchWorkItem {[weak self] in
                self?.isShowToast = false
            }
            
            if let showToastWork = self.showToastWork {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: showToastWork)
            }
        }
    }}
    @Published var toastMessage: String = ""
    
    init() {
        print("init \(type(of: self))")
        self.coordinator = nil
    }
    
    init(_ coordinator: AppCoordinator) {
        print("init \(type(of: self))")
        self.coordinator = coordinator
    }
    
    deinit {
        subscription.removeAll()
    }
    
    func viewDidDisappear(_ isSwipePop: Bool) {
        if isSwipePop {
            self.coordinator?.swipeBack()
        }
    }
    
    public func present(_ vc: UIViewController, animated: Bool = true) {
        self.coordinator?.present(vc, animated: animated)
    }
    
    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.coordinator?.dismiss(animated, completion: completion)
    }
    
    public func pop(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.coordinator?.pop(animated, completion: completion)
    }
    
    public func push(_ vc: UIViewController, animated: Bool = true) {
        self.coordinator?.push(vc, animated: animated)
    }
    
    public func change(_ vc: UIViewController, animated: Bool = true) {
        self.coordinator?.change(vc, animated: animated)
    }
    
    public func showToast(_ message: String) {
        self.toastMessage = message
        self.isShowToast = true
    }
    
    func failToLoadImage() {
        self.showToast("이미지를 불러오는데 실패했습니다.")
    }
    
    public func showErrorAlert(_ err: Error) {

    }
}
