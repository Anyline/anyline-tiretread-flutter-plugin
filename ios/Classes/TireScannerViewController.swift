import UIKit
import Flutter
import AnylineTireTreadSdk

class TireScannerViewController: UIViewController, ScannerViewControllerHolder {
    
    // if config is non-null, jsonConfig would be ignored
    init(config: TireTreadScanViewConfig) {
        scanViewConfig = config
        super.init(nibName: nil, bundle: nil)
    }
    
    init(configString: String) {
        scanViewConfigStr = configString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var dismissViewController: (() -> Void)?
    
    var scannerViewController: UIViewController?
    
    var uuid: String?
    
    var scanViewConfig: TireTreadScanViewConfig!
    
    var scanViewConfigStr: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupScanView()
    }
    
    @objc func dismissButtonTapped(button: UIButton) {
        dismiss(animated: true)
    }
    
    func setupScanView() {
        assert(scanViewConfig != nil || scanViewConfigStr != nil)
        
        if let scanViewConfig = scanViewConfig {
            print("""
            Tire Config:
            - scan speed: \(scanViewConfig.scanSpeed)
            - measurement system: \(scanViewConfig.measurementSystem)
            - countdown: \(scanViewConfig.defaultUiConfig.countdownConfig.visible)
            - scan direction: \(scanViewConfig.defaultUiConfig.scanDirectionConfig.visible)
            - tire overlay: \(scanViewConfig.defaultUiConfig.tireOverlayConfig.visible)
            """)
            TireTreadScanViewKt.TireTreadScanView(context: UIViewController(),
                                                  config: scanViewConfig,
                                                  callback: self) { error in
                print("Initialization failed: \(error)")
                self.dismiss(animated: true)
            }
        } else if let scanViewConfigStr = scanViewConfigStr {
            print("Tire Config: \(scanViewConfigStr)")
            TireTreadScanViewKt.TireTreadScanView(context: UIViewController(), config: scanViewConfigStr, callback: self) { error in
                print("Initialization failed: \(error)")
                self.dismiss(animated: true)
            }
        }
        
        self.dismissViewController = { print("Dismissing view controller") }
        addScanViewControllerAsChild()
    }
    
    private func addScanViewControllerAsChild() {
        guard let scannerViewController = self.scannerViewController else {
            print("Error: scannerViewController is null")
            return
        }
        
        addChild(scannerViewController)
        view.addSubview(scannerViewController.view)
        
        scannerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scannerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scannerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scannerViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scannerViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        scannerViewController.didMove(toParent: self)
    }
    
    private func removeScanViewControllerAsChild() {
        guard let scannerViewController = self.scannerViewController else {
            return
        }
        scannerViewController.willMove(toParent: nil)
        scannerViewController.view.removeFromSuperview()
        scannerViewController.removeFromParent()
    }
}


extension TireScannerViewController: TireTreadScanViewCallback {
    
    func onImageUploaded(uuid: String?, uploaded: Int32, total: Int32) {
        print("TireTreadScanViewCallback: onImageUploaded: \(total) images uploaded in total")
    }
    
    func onScanStart(uuid: String?) {
        print("TireTreadScanViewCallback: onScanStart")
    }
    
    func onScanStop(uuid: String?) {
        print("TireTreadScanViewCallback: onScanStop")
    }
    
    func onScanAbort(uuid: String?) {
        print("TireTreadScanViewCallback: onScanAbort")
        removeScanViewControllerAsChild()
        dismiss(animated: true, completion: nil)
        TTEventHandler.shared.sendEvent(type: "ScanningAborted", uuid: uuid)
    }
    
    func onUploadCompleted(uuid: String?) {
        print("TireTreadScanViewCallback: onUploadCompleted")
        removeScanViewControllerAsChild()
        if let uuid = uuid {
            print("UUID: \(uuid)")
        }
        dismiss(animated: true)
        TTEventHandler.shared.sendEvent(type: "UploadCompleted", uuid: uuid)
    }
    
    func onUploadFailed(uuid: String?, exception: KotlinException) {
        print("TireTreadScanViewCallback: onUploadFailed")
        TTEventHandler.shared.sendEvent(type: "UploadFailedEvent", uuid: uuid)    }
    
    func onUploadAborted(uuid: String?) {
        print("TireTreadScanViewCallback: onUploadAborted")
        TTEventHandler.shared.sendEvent(type: "UploadAbortedEvent", uuid: uuid)
    }
    
    func onFocusFound(uuid: String?) {
        print("TireTreadScanViewCallback: onFocusFound")
    }
    
    func onDistanceChanged(uuid: String?,
                           previousStatus: DistanceStatus,
                           newStatus: DistanceStatus,
                           previousDistance: Float,
                           newDistance: Float) {
    }
}

