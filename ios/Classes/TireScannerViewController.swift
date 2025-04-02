import UIKit
import Flutter
import AnylineTireTreadSdk

class TireScannerViewController: UIViewController, ScannerViewControllerHolder {
    
    // if config is non-null, jsonConfig would be ignored
    init(config: TireTreadScanViewConfig,defaultTireWidth: Int?) {
        scanViewConfig = config
        if let width = defaultTireWidth {
            tireWidth = KotlinInt(integerLiteral: width)
            }
        super.init(nibName: nil, bundle: nil)
    }
    
    init(configString: String,defaultTireWidth: Int?) {
        scanViewConfigStr = configString
        if let width = defaultTireWidth {
            tireWidth = KotlinInt(integerLiteral: width)
            }

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var dismissViewController: (() -> Void)?
    
    var scannerViewController: UIViewController?
    
    var uuid: String?
    
    var scanViewConfig: TireTreadScanViewConfig!
    
    var tireWidth: KotlinInt!
    
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
            - tire width: \(tireWidth.stringValue)
            """)
            
            TireTreadScanViewKt.TireTreadScanView(
                context: self,
                config: scanViewConfig,
                tireWidth: tireWidth,
                onScanAborted: onScanAborted,
                onScanProcessCompleted: onScanProcessCompleted,
                callback: handleScanEvent,
                onError: onError
            )
            
        } else if let scanViewConfigStr = scanViewConfigStr {
            print("Tire Config: \(scanViewConfigStr)")
            
            TireTreadScanViewKt.TireTreadScanView(
                context: self,
                config: scanViewConfigStr,
                tireWidth: tireWidth,
                onScanAborted: onScanAborted,
                onScanProcessCompleted: onScanProcessCompleted,
                callback: handleScanEvent,
                onError_: onError
            )
            
        }
        
        self.dismissViewController = { print("Dismissing view controller") }
        addScanViewControllerAsChild()
    }
    
    /**
     * Handles the event when an error occurs during the scan process.
     *
     * @param measurementUUID The unique identifier for the measurement that encountered an error.
     */
    private func onError(measurementUUID: String?, exception: KotlinException) {
        print("onUploadFailed")
        TTEventHandler.shared.sendEvent(type: "ScanFailed", uuid: measurementUUID, error: exception.message)
    }
    
    /**
     * Handles the event when a scan is aborted.
     *
     * @param measurementUUID The unique identifier for the measurement that was aborted.
     */
    private func onScanAborted(measurementUUID: String?) {
        print("TireTreadScanViewCallback: onScanAbort")
        removeScanViewControllerAsChild()
        dismiss(animated: true, completion: nil)
        TTEventHandler.shared.sendEvent(type: "ScanAborted", uuid: measurementUUID)
    }
    
    /**
     * Handles the event when the scan process is completed.
     *
     * @param measurementUUID The unique identifier for the completed measurement.
     */
    private func onScanProcessCompleted(measurementUUID: String) {
        print("TireTreadScanViewCallback: onScanProcessCompleted")
        removeScanViewControllerAsChild()
        dismiss(animated: true)
        TTEventHandler.shared.sendEvent(type: "ScanProcessCompleted", uuid: measurementUUID)
    }
    
    /**
     * Handles various scan events and logs appropriate messages.
     *
     * @param event The scan event to handle.
     */
    private func handleScanEvent(event: ScanEvent) {
        switch(event) {
        case let event as OnScanStarted:
            print("TireTreadScanViewCallback: onScanStart")
            break
            
        case let event as OnScanStopped:
            print("TireTreadScanViewCallback: onScanStop")
            break
            
        case let event as OnImageUploaded:
            print("onImageUploaded: \(event.total) images uploaded in total")
            break
            
        case let event as OnDistanceChanged:
            print("TireTreadScanViewCallback: OnDistanceChanged")
            break
            
        default:
            print("ScanEvent: \(event.description)")
            break
        }
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
