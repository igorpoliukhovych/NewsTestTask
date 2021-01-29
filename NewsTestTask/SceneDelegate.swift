//
//  SceneDelegate.swift
//  NewsTestTask
//
//  Created by Igor Poliukhovych on 28.01.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        assembly(windowScene)
        
    }
}

private extension SceneDelegate {
    func assembly(_ windowScene: UIWindowScene ) {
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        let viewController = MainNewsViewController()
        let navigationViewController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navigationViewController
        
        window?.makeKeyAndVisible()
    }
}

