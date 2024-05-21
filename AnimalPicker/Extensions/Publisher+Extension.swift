//
//  Publisher+Extension.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import Foundation
import Combine

extension Publisher {
    func run(in set: inout Set<AnyCancellable>, next: ((Self.Output) -> Void)? = nil, err errorListener: ((Error) -> Void)? = nil, complete: (() -> Void)? = nil) {
        self.subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(err) = completion {
                    errorListener?(err)
                }
                complete?()
            } receiveValue: { value in
                next?(value)
            }
            .store(in: &set)
    }
    
    func run(in set: inout Set<AnyCancellable>, next: ((Self.Output) -> Void)? = nil) {
        self.subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .sink { completion in
            } receiveValue: { value in
                next?(value)
            }
            .store(in: &set)
    }
}
