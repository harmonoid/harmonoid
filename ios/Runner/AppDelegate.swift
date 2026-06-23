import Flutter
import MobileCoreServices
import UIKit
import UniformTypeIdentifiers

@main
@objc class AppDelegate: FlutterAppDelegate, UIDocumentPickerDelegate {
    static let kIntentControllerMethodChannelName = "com.alexmercerind.harmonoid/intent_controller"
    static let kStorageControllerMethodChannelName = "com.alexmercerind.harmonoid/storage_controller"
    static let kUtilsMethodChannelName = "com.alexmercerind.harmonoid/utils"
    
    static let kNotifyIntentMethodName = "notifyIntent"
    
    static let kPickDirectoryMethodName = "pickDirectory"
    static let kPickFileMethodName = "pickFile"
    static let kPreserveAccessMethodName = "preserveAccess"
    static let kInvalidateAccessMethodName = "invalidateAccess"
    static let kGetDefaultMediaLibraryDirectoryMethodName = "getDefaultMediaLibraryDirectory"
    static let kGetSystemAccentColorMethodName = "getSystemAccentColor"

    static let kPickFileAllowedFileTypesArg = "allowedFileTypes"
    static let kPreserveAccessPathArg = "path"
    static let kInvalidateAccessPathArg = "path"
    
    private var intentControllerMethodChannel: FlutterMethodChannel?
    private var storageControllerMethodChannel: FlutterMethodChannel?
    private var utilsMethodChannel: FlutterMethodChannel?
    private var documentPickerResult: FlutterResult?
    private var uri: String?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        if let controller = window?.rootViewController as? FlutterViewController {
            intentControllerMethodChannel = FlutterMethodChannel(
                name: AppDelegate.kIntentControllerMethodChannelName,
                binaryMessenger: controller.binaryMessenger
            )
            intentControllerMethodChannel?.setMethodCallHandler({
                (_ call: FlutterMethodCall, _ result: FlutterResult) -> Void in
                result(self.uri)
            })
            
            storageControllerMethodChannel = FlutterMethodChannel(
                name: AppDelegate.kStorageControllerMethodChannelName,
                binaryMessenger: controller.binaryMessenger
            )
            storageControllerMethodChannel?.setMethodCallHandler({
                (_ call: FlutterMethodCall, _ result: @escaping FlutterResult) -> Void in
                if (call.method == AppDelegate.kPickDirectoryMethodName) {
                    self.flutterPickDirectory(call: call, result: result)
                } else if (call.method == AppDelegate.kPickFileMethodName) {
                    self.flutterPickFile(call: call, result: result)
                } else if (call.method == AppDelegate.kPreserveAccessMethodName) {
                    self.flutterPreserveAccess(call: call, result: result)
                } else if (call.method == AppDelegate.kInvalidateAccessMethodName) {
                    self.flutterInvalidateAccess(call: call, result: result)
                } else if (call.method == AppDelegate.kGetDefaultMediaLibraryDirectoryMethodName) {
                    self.flutterGetDefaultMediaLibraryDirectory(call: call, result: result)
                } else {
                    result(FlutterMethodNotImplemented)
                }
            })
            
            utilsMethodChannel = FlutterMethodChannel(
                name: AppDelegate.kUtilsMethodChannelName,
                binaryMessenger: controller.binaryMessenger
            )
            utilsMethodChannel?.setMethodCallHandler({
                (_ call: FlutterMethodCall, _ result: FlutterResult) -> Void in
                if (call.method == AppDelegate.kGetSystemAccentColorMethodName) {
                    result(self.systemAccentColor())
                } else {
                    result(FlutterMethodNotImplemented)
                }
            })
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        if let value = resolveIncomingURL(url) {
            uri = value
            intentControllerMethodChannel?.invokeMethod(AppDelegate.kNotifyIntentMethodName, arguments: uri)
            return true
        }
        return super.application(app, open: url, options: options)
    }
    
    private func flutterPickDirectory(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard beginDocumentPicker(result: result) else { return }
        
        let picker: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
            picker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder], asCopy: false)
        } else {
            picker = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
        }
        picker.delegate = self
        picker.allowsMultipleSelection = false
        window?.rootViewController?.present(picker, animated: true)
    }
    
    private func flutterPickFile(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard beginDocumentPicker(result: result) else { return }
        
        let arguments = call.arguments as? [String: Any]
        let allowedFileTypes = arguments?[AppDelegate.kPickFileAllowedFileTypesArg] as? [String] ?? []
        
        let picker: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
            let contentTypes = allowedFileTypes.compactMap { UTType(filenameExtension: $0.lowercased()) }
            picker = UIDocumentPickerViewController(
                forOpeningContentTypes: contentTypes.isEmpty ? [.item] : contentTypes,
                asCopy: false
            )
        } else {
            picker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .open)
        }
        picker.delegate = self
        picker.allowsMultipleSelection = false
        window?.rootViewController?.present(picker, animated: true)
    }
    
    private func flutterPreserveAccess(call: FlutterMethodCall, result: FlutterResult) {
        // https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox
        
        let arguments = call.arguments as? [String: Any]
        let path = arguments?[AppDelegate.kPreserveAccessPathArg] as? String
        
        result(preserveAccess(path: path))
    }
    
    private func flutterInvalidateAccess(call: FlutterMethodCall, result: FlutterResult) {
        // https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox
        
        let arguments = call.arguments as? [String: Any]
        let path = arguments?[AppDelegate.kInvalidateAccessPathArg] as? String
        
        result(invalidateAccess(path: path))
    }
    
    private func flutterGetDefaultMediaLibraryDirectory(call: FlutterMethodCall, result: FlutterResult) {
        result(defaultMediaLibraryDirectory()?.path)
    }
    
    private func systemAccentColor() -> Int? {
        let traits = window?.rootViewController?.traitCollection ?? UIScreen.main.traitCollection
        let color = (window?.tintColor ?? UIColor.systemBlue).resolvedColor(with: traits)
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        let a = Int(round(alpha * 255.0)) & 0xFF
        let r = Int(round(red * 255.0)) & 0xFF
        let g = Int(round(green * 255.0)) & 0xFF
        let b = Int(round(blue * 255.0)) & 0xFF
        return (a << 24) | (r << 16) | (g << 8) | b
    }
    
    private func beginDocumentPicker(result: @escaping FlutterResult) -> Bool {
        guard documentPickerResult == nil else {
            result(FlutterError(code: "busy", message: "A document picker is already active.", details: nil))
            return false
        }
        documentPickerResult = result
        return true
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let result = documentPickerResult else { return }
        documentPickerResult = nil
        
        guard let url = urls.first else {
            result(nil)
            return
        }
        
        result(url.path)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        documentPickerResult?(nil)
        documentPickerResult = nil
    }
    
    private func preserveAccess(path: String?) -> Bool {
        guard let path else { return false }
        return preserveAccess(url: URL(fileURLWithPath: path))
    }
    
    private func preserveAccess(url: URL) -> Bool {
        do {
            let key = bookmarkKey(url)

            // Return early if bookmark is already saved.
            if let bookmark = UserDefaults.standard.data(forKey: key) {
                // - Create URL from bookmark data.
                // - Invoke startAccessingSecurityScopedResource
                var isStale = false
                let resolvedURL = try URL(
                    resolvingBookmarkData: bookmark,
                    options: [],
                    relativeTo: nil,
                    bookmarkDataIsStale: &isStale
                )
                guard !isStale else {
                    UserDefaults.standard.removeObject(forKey: key)
                    return preserveAccess(url: url)
                }
                _ = resolvedURL.startAccessingSecurityScopedResource()
                return true
            }
            
            // - Create URL from path.
            // - Invoke startAccessingSecurityScopedResource
            // - Save bookmark data.
            guard url.startAccessingSecurityScopedResource() else {
                return false
            }
            let bookmark = try url.bookmarkData(
                options: [],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            UserDefaults.standard.set(bookmark, forKey: key)
            return true
        } catch {
            return false
        }
    }
    
    private func invalidateAccess(path: String?) -> Bool {
        guard let path else { return false }
        
        let url = URL(fileURLWithPath: path)
        let key = bookmarkKey(url)
        // Return early if bookmark is not saved.
        if UserDefaults.standard.data(forKey: key) == nil {
            return true
        }
        
        url.stopAccessingSecurityScopedResource()
        UserDefaults.standard.removeObject(forKey: key)
        return true
    }
    
    private func bookmarkKey(_ url: URL) -> String {
        return bookmarkKey(url.path)
    }

    private func bookmarkKey(_ path: String) -> String {
        return "bookmark_\(path)"
    }
    
    private func defaultMediaLibraryDirectory() -> URL? {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let result = documents.appendingPathComponent("Music", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: result, withIntermediateDirectories: true)
        } catch {
            return documents
        }
        return result
    }
    
    private func resolveIncomingURL(_ url: URL) -> String? {
        guard url.isFileURL else {
            return url.absoluteString
        }
        
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let cache = try FileManager.default.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let directory = cache.appendingPathComponent("IntentController", isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            
            let destination = directory.appendingPathComponent(UUID().uuidString + "-" + url.lastPathComponent)
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.copyItem(at: url, to: destination)
            return destination.absoluteString
        } catch {
            return url.absoluteString
        }
    }
}
