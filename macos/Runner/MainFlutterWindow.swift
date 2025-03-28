import Cocoa
import FlutterMacOS
import window_plus

class MainFlutterWindow: NSWindow {
    static let kStorageControllerMethodChannelName = "com.alexmercerind.harmonoid/storage_controller"
    
    static let kPickDirectoryMethodName = "pickDirectory"
    static let kPickFileMethodName = "pickFile"
    static let kPreserveAccessMethodName = "preserveAccess"
    static let kInvalidateAccessMethodName = "invalidateAccess"
    static let kGetDefaultMediaLibraryDirectoryMethodName = "getDefaultMediaLibraryDirectory"

    static let kPickFileAllowedFileTypesArg = "allowedFileTypes"
    static let kPreserveAccessPathArg = "path"
    static let kInvalidateAccessPathArg = "path"
    
    private var storageControllerMethodChannel: FlutterMethodChannel?
    
    override public func awakeFromNib() {
        let flutterViewController = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = flutterViewController
        self.setFrame(windowFrame, display: true)
        
        RegisterGeneratedPlugins(registry: flutterViewController)
        
        storageControllerMethodChannel = FlutterMethodChannel(
            name: MainFlutterWindow.kStorageControllerMethodChannelName,
            binaryMessenger: flutterViewController.engine.binaryMessenger
        )
        storageControllerMethodChannel?.setMethodCallHandler({
            (_ call: FlutterMethodCall, _ result: FlutterResult) -> Void in
            if (call.method == MainFlutterWindow.kPickDirectoryMethodName) {
                self.flutterPickDirectory(call: call, result: result)
            } else if (call.method == MainFlutterWindow.kPickFileMethodName) {
                self.flutterPickFile(call: call, result: result)
            } else if (call.method == MainFlutterWindow.kPreserveAccessMethodName) {
                self.flutterPreserveAccess(call: call, result: result)
            } else if (call.method == MainFlutterWindow.kInvalidateAccessMethodName) {
                self.flutterInvalidateAccess(call: call, result: result)
            } else if (call.method == MainFlutterWindow.kGetDefaultMediaLibraryDirectoryMethodName) {
                self.flutterGetDefaultMediaLibraryDirectory(call: call, result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
        
        super.awakeFromNib()
    }
    
    override public func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
        super.order(place, relativeTo: otherWin)
        WindowPlusPlugin.hideUntilReady()
    }
    
    private func flutterPickDirectory(call: FlutterMethodCall, result: FlutterResult) {
        var value: String?
        
        let panel = NSOpenPanel()
        panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory())
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        if (panel.runModal() == NSApplication.ModalResponse.OK) {
            value = panel.urls.first?.path
        }
        
        result(value)
    }
    
    private func flutterPickFile(call: FlutterMethodCall, result: FlutterResult) {
        var value: String?
        
        let arguments = call.arguments as! [String: Any]
        let allowedFileTypes = arguments[MainFlutterWindow.kPickFileAllowedFileTypesArg] as! [String]
        
        let panel = NSOpenPanel()
        panel.directoryURL = URL(fileURLWithPath: NSHomeDirectory())
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = allowedFileTypes
        if (panel.runModal() == NSApplication.ModalResponse.OK) {
            value = panel.urls.first?.path
        }
        
        result(value)
    }
    
    private func flutterPreserveAccess(call: FlutterMethodCall, result: FlutterResult) {
        // https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox
        
        let arguments = call.arguments as! [String: Any]
        let path = arguments[MainFlutterWindow.kPreserveAccessPathArg] as! String
        
        // Return early if bookmark is already saved.
        if let bookmark = UserDefaults.standard.data(forKey: "bookmark_\(path)") {
            // - Create URL from bookmark data.
            // - Invoke startAccessingSecurityScopedResource
            var isStale = false
            let url = try? URL(
                resolvingBookmarkData: bookmark,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            _ = url?.startAccessingSecurityScopedResource()
            result(true)
            return
        }
        
        // - Create URL from path.
        // - Invoke startAccessingSecurityScopedResource
        // - Save bookmark data.
        let url = URL(fileURLWithPath: path)
        _ = url.startAccessingSecurityScopedResource()
        let bookmark = try? url.bookmarkData(
            options: .withSecurityScope,
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )
        UserDefaults.standard.set(bookmark, forKey: "bookmark_\(path)")
        
        result(true)
    }
    
    private func flutterInvalidateAccess(call: FlutterMethodCall, result: FlutterResult) {
        // https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox
        
        let arguments = call.arguments as! [String: Any]
        let path = arguments[MainFlutterWindow.kInvalidateAccessPathArg] as! String
        
        // Return early if bookmark is not saved.
        if UserDefaults.standard.data(forKey: "bookmark_\(path)") == nil {
            result(true)
            return
        }
        
        let url = URL(fileURLWithPath: path)
        url.stopAccessingSecurityScopedResource()
        UserDefaults.standard.removeObject(forKey: "bookmark_\(path)")
        
        result(true)
    }
    
    private func flutterGetDefaultMediaLibraryDirectory(call: FlutterMethodCall, result: FlutterResult) {
        if let directory = NSSearchPathForDirectoriesInDomains(.musicDirectory, .userDomainMask, true).first {
            var url = URL(fileURLWithPath: directory)
            // Resolve the symlink before sending it. It makes the path same as if it has been picked by NSOpenPanel.
            // /Users/alexmercerind/Library/Containers/com.alexmercerind.harmonoid/Data/Music -> /Users/alexmercerind/Music
            url.resolveSymlinksInPath()
            result(url.path)
        } else {
            result(nil)
        }
    }
}
