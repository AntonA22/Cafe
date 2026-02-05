import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
//    func scene(
//        _ scene: UIScene,
//        willConnectTo session: UISceneSession,
//        options connectionOptions: UIScene.ConnectionOptions
//    ) {
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//
//        let window = UIWindow(windowScene: windowScene)
//        Task {
//            var startVC : UIViewController;
//            
//            if (AuthService.shared.currentToken() != nil ) {
//                
//                let user = try  await AuthService.shared.fetchMe()
//              //  сделать правильно
//                if(user == nil ) {
//                    startVC = AuthViewController()
//                }
//                //добавить, а что если ничего не получили
//                else {
//                    startVC = MainTabBarController(user: user);
//                }
//                
//            }
//            else { startVC = AuthViewController() }
//                
//           let nav = UINavigationController(rootViewController: startVC)
//                
//            
//            nav.navigationBar.isHidden = true // если хочешь скрыть верхнюю полоску
//            window.rootViewController = nav
//            window.overrideUserInterfaceStyle = .light // белая тема по умолчанию
//            window.makeKeyAndVisible()
//            self.window = window
//        }
//    }
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // СРАЗУ показываем хоть что-то, чтобы не было чёрного экрана
        let splash = SplashViewController()
        let nav = UINavigationController(rootViewController: splash)
        nav.navigationBar.isHidden = true

        window.rootViewController = nav
        window.overrideUserInterfaceStyle = .light
        window.makeKeyAndVisible()

        Task {
            let startVC = await determineStartViewController()

            await MainActor.run {
                nav.setViewControllers([startVC], animated: true)
            }
        }
    }
    
    private func determineStartViewController() async -> UIViewController {
        guard AuthService.shared.currentToken() != nil else {
            return AuthViewController()
        }

        do {
            let user: UserDTO? = try await AuthService.shared.fetchMe()
            if let user {
                return MainTabBarController(user: user)
            } else {
                AuthService.shared.logout()
                return AuthViewController()
            }
        } catch {
            // бэкенд выключен / нет сети / таймаут
            // Вариант 1 (безопасный): отправить на логин
            AuthService.shared.logout()
            return AuthViewController()

            // Вариант 2 (часто лучше UX): показать экран ошибки с кнопкой "Повторить"
            //return BackendDownViewController() // сделай простой экран с Retry
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
