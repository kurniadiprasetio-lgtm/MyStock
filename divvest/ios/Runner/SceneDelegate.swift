import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
          let engine = appDelegate.flutterEngine else {
      super.scene(scene, willConnectTo: session, options: connectionOptions)
      return
    }
    
    guard let windowScene = scene as? UIWindowScene else { return }
    
    window = UIWindow(windowScene: windowScene)
    let flutterViewController = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    window?.rootViewController = flutterViewController
    window?.makeKeyAndVisible()
  }
}
