//
//  BaseViewController.swift
//  AnimalPicker
//
//  Created by Sandy on 5/21/24.
//

import SwiftUI

class BaseViewController<Content>: UIViewController, Dismissible, Nameable, UIGestureRecognizerDelegate where Content: View {
    let rootView: Content
    let controller: UIHostingController<Content>
    var completion: (() -> Void)?
    var onDismiss: (() -> Void)?
    var viewDidLoadCallback: (() -> ())? = nil
    var isSwipePop: Bool = false
    var vm: BaseViewModel? = nil
    
    var name: String {
        get {
            return String(describing: Content.self)
        }
    }
    
    public init(_ rootView: Content, completion: (() -> Void)? = nil, viewDidLoadCallback: (() -> ())? = nil) {
        print("\(type(of: self)): init, \(String(describing: Content.self))")
        self.rootView = rootView
        self.controller = UIHostingController(rootView: rootView)
        self.completion = completion
        self.viewDidLoadCallback = viewDidLoadCallback
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    
    public init(_ rootView: Content, completion: (() -> Void)? = nil) {
        print("\(type(of: self)): init, \(String(describing: Content.self))")
        self.rootView = rootView
        self.controller = UIHostingController(rootView: rootView)
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
        
    required init?(coder: NSCoder) {
        print("\(type(of: self)): init")
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit (\(type(of: self)))")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async { [weak self] in
            self?.controller.navigationController?.isNavigationBarHidden = true
        }
        addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            controller.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            controller.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1),
            controller.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controller.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    public func attachDismissCallback(onDismiss: (() -> Void)?) {
        self.onDismiss = onDismiss
    }
    
    func attachViewModel(_ vm: BaseViewModel) {
        self.vm = vm
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.isSwipePop = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        vm?.viewDidDisappear(isSwipePop)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.isSameView(view: SplashView.self) || self.isSameView(view: MainView.self) {
            isSwipePop = false
            return false
        }
        
        switch gestureRecognizer.state {
        case .possible, .began, .changed:
            isSwipePop = true
        default:
            isSwipePop = false
        }
        return true
    }
}

public protocol Dismissible {
    var completion: (() -> Void)? { get set }
    var onDismiss: (() -> Void)? { get set }
    func attachDismissCallback(onDismiss: (() -> Void)?)
}

public protocol Nameable {
    var name: String { get }
}

extension Nameable {
    func isSameView<Type>(view: Type.Type) -> Bool {
        name == String(describing: Type.self)
    }
}
