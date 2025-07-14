import UIKit
import Flutter
import AnylineTireTreadSdk

class TireScannerViewController: UIViewController {
    
    // if config is non-null, jsonConfig would be ignored
    init(config: TireTreadConfig) {
        scanViewConfig = config
        super.init(nibName: nil, bundle: nil)
    }
    
    init(configString: String) {
        scanViewConfigStr = configString
        super.init(nibName: nil, bundle: nil)
    }
    
    init(tireTreadConfigJson: String) {
        super.init(nibName: nil, bundle: nil)
        scanViewConfigStr = tireTreadConfigJson
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var scannerViewController: UIViewController?

    var scanViewConfig: TireTreadConfig!
        
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
            self.scannerViewController = TireTreadScanViewKt.TireTreadScanView(
                config: scanViewConfig,
                onScanAborted: onScanAborted,
                onScanProcessCompleted: onScanProcessCompleted,
                callback: handleScanEvent,
                onError: onError
            )
            
        } else if let scanViewConfigStr = scanViewConfigStr {
            self.scannerViewController = TireTreadScanViewKt.TireTreadScanView(
                config: scanViewConfigStr,
                onScanAborted: onScanAborted,
                onScanProcessCompleted: onScanProcessCompleted,
                callback: handleScanEvent,
                onError_: onError
            )
        }
        
        addScanViewControllerAsChild()
    }
    
    /**
     * Handles the event when an error occurs during the scan process.
     *
     * @param measurementUUID The unique identifier for the measurement that encountered an error.
     */
    private func onError(measurementUUID: String?, exception: KotlinException) {
        removeScanViewControllerAsChild()
        dismiss(animated: true, completion: nil)
        TTEventHandler.shared.sendEvent(type: "ScanFailed", uuid: measurementUUID, error: exception.message ?? "Unknown error")
    }
    
    /**
     * Handles the event when a scan is aborted.
     *
     * @param measurementUUID The unique identifier for the measurement that was aborted.
     */
    private func onScanAborted(measurementUUID: String?) {
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
            TTEventHandler.shared.sendEvent(type: "ScanStarted", uuid: event.measurementUUID)
            break
            
        case let event as OnScanStopped:
            break
            
        case let event as OnImageUploaded:
            break
            
        case let event as OnDistanceChanged:
            break
            
        default:
            break
        }
    }
    
    private func addScanViewControllerAsChild() {
        guard let scannerViewController = self.scannerViewController else {
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
