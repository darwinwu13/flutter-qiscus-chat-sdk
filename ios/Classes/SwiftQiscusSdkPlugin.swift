import Flutter
import UIKit

public class SwiftQiscusSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "qiscus_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftQiscusSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
    
    switch call.method {
    case "getQiscusAccount":
        getQiscusAccount(withResult: result)
        break
    default:
        return
    }
  }
//    private void getQiscusAccount(Result result) {
//        try {
//            result.success(QiscusSdkHelper.encodeQiscusAccount(QiscusCore.getQiscusAccount()));
//
//        } catch (Exception e) {
//            e.printStackTrace();
//            result.error("ERR_FAILED_GET_ACCOUNT", e.getMessage(), e);
//        }
//
//    }

    private func getQiscusAccount(withResult result: FlutterResult){
        do {
            try result(QiscusSdkPlugin)
        } catch (e: Error) {
            
        }
    }
}
