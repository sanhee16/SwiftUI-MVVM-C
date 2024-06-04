//
//  BaseVM.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Combine
import Alamofire

class BaseViewModel: ObservableObject {
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
    @Published var isPop: Bool = false
    
    init() {
        print("init \(type(of: self))")
    }
    
    deinit {
        subscription.removeAll()
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
