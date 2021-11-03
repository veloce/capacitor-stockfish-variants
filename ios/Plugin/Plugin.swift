import Foundation
import Capacitor
import MachO

@objc(StockfishVariants)
public class StockfishVariants: CAPPlugin {
    
    private var stockfish: StockfishBridgeMv?
    private var isInit = false
    
    private let template = "{\"output\": \"%@\"}"
    @objc public func sendOutput(_ output: String) {
        bridge?.triggerWindowJSEvent(eventName: "stockfish", data: String(format: template, output))
    }

    @objc override public func load() {
        var onPauseWorkItem: DispatchWorkItem?

        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: OperationQueue.main) { [weak self] (_) in
            if (self!.isInit) {
                onPauseWorkItem = DispatchWorkItem {
                    self?.stockfish?.cmd("stop")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 60 * 3, execute: onPauseWorkItem!)
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: OperationQueue.main) { [weak self] (_) in
            if (self!.isInit) {
                onPauseWorkItem?.cancel()
            }
        }

        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: OperationQueue.main) { [weak self] (_) in
            if (self!.isInit) {
                self?.stockfish?.cmd("stop")
                self?.stockfish?.exit()
                self?.isInit = false
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func getCPUArch(_ call: CAPPluginCall) {
        let info = NXGetLocalArchInfo()
        let arch = NSString(utf8String: (info?.pointee.name)!)
        call.resolve([
            "value": arch ?? "unknown"
        ])
    }

    @objc func getMaxMemory(_ call: CAPPluginCall) {
        // allow max 1/16th of total mem
        let maxMemInMb = (ProcessInfo().physicalMemory / 16) / (1024 * 1024)
        call.resolve([
            "value": maxMemInMb
        ])
    }

    @objc func start(_ call: CAPPluginCall) {
        if (!isInit) {
            stockfish = StockfishBridgeMv(plugin: self)
            stockfish?.start()
            isInit = true
        }
        call.resolve()
    }

    @objc func cmd(_ call: CAPPluginCall) {
        if (isInit) {
            guard let cmd = call.options["cmd"] as? String else {
                call.reject("Must provide a cmd")
                return
            }
            stockfish?.cmd(cmd)
            call.resolve()
        } else {
            call.reject("You must call start before anything else")
        }
    }
    
    @objc func exit(_ call: CAPPluginCall) {
        if (isInit) {
            stockfish?.cmd("quit")
            stockfish?.exit()
            isInit = false
        }
        call.resolve()
    }
}
