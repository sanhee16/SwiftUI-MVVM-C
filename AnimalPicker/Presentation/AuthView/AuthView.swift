//
//  AuthView.swift
//  AnimalPicker
//
//  Created by Sandy on 5/24/24.
//


import Foundation
import SwiftUI

struct AuthView: View {
    typealias VM = AuthVM
    public static func vc(_ coordinator: AppCoordinator, interactors: DIContainer.Interactors, completion: (()-> Void)? = nil) -> UIViewController {
        let vm = VM.init(interactors)
        let view = Self.init(vm: vm, coordinator: coordinator)
        let vc = BaseViewController.init(view, completion: completion)
        vc.attachViewModel(vm)
        
        return vc
    }
    
    @ObservedObject var vm: VM
    @ObservedObject var coordinator: AppCoordinator
    
    @State private var nickname: String = ""
    @State private var password: String = ""
    
    private var safeTop: CGFloat { get { Util.safeTop() }}
    private var safeBottom: CGFloat { get { Util.safeBottom() }}
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                switch $vm.status.wrappedValue {
                case .login:
                    loginPage()
                case .join:
                    loginPage()
                default:
                    EmptyView()
                }
            }
            .frame(width: geometry.size.width, alignment: .center)
        }
        .onAppear {
            vm.onAppear()
        }
    }
    
    private func loginPage() -> some View {
        VStack(alignment: .leading, spacing: 8, content: {
            Text("Login")
                .font(.kr20b)
                .foregroundStyle(Color.black)
            
            
            HStack(alignment: .center, spacing: 8, content: {
                Text("Nickname")
                    .font(.kr14b)
                    .foregroundStyle(Color.black.opacity(0.7))
                
                SingleBoxTextField(placeholder: "Nickname", text: $nickname) { _ in
                    
                }
            })
            
            HStack(alignment: .center, spacing: 8, content: {
                Text("Password")
                    .font(.kr14b)
                    .foregroundStyle(Color.black.opacity(0.7))
                
                SingleBoxTextField(placeholder: "Password", text: $password) { _ in
                    
                }
            })
            
        })
    }
}

