import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)
        (UIApplication.shared.delegate as? AppDelegate)?.window = window
        resolveIncomingURL(URLContexts: connectionOptions.urlContexts)
    }

    override func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        resolveIncomingURL(URLContexts: URLContexts)
    }

    private func resolveIncomingURL(URLContexts: Set<UIOpenURLContext>) {
        guard let context = URLContexts.first else { return }
        (UIApplication.shared.delegate as? AppDelegate)?.resolveIncomingURL(context.url, openInPlace: context.options.openInPlace)
    }
}
