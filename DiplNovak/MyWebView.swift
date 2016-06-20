//
//  MyWebView.swift
//  DiplNovak
//
//  Created by Novak Second on 30/04/2016.
//  Copyright © 2016 Novak Second. All rights reserved.
//

import Foundation
import ObjectiveC
import WebKit

extension WKWebView {
    // Synchronized evaluateJavaScript
    // It returns nil if script is a statement or its result is undefined.
    // So, Swift cannot map the throwing method to Objective-C method.
    public func evaluateJavaScript(script: String) throws -> AnyObject? {
        var result: AnyObject?
        var error: NSError?
        var done = false
        let timeout = 3.0
        if NSThread.isMainThread() {
            evaluateJavaScript(script) {
                (obj: AnyObject?, err: NSError?)->Void in
                result = obj
                error = err
                done = true
            }
            while !done {
                let reason = CFRunLoopRunInMode(kCFRunLoopDefaultMode, timeout, true)
                if reason != CFRunLoopRunResult.HandledSource {
                    break
                }
            }
        } else {
            let condition: NSCondition = NSCondition()
            dispatch_async(dispatch_get_main_queue()) {
                [weak self] in
                self?.evaluateJavaScript(script) {
                    (obj: AnyObject?, err: NSError?)->Void in
                    condition.lock()
                    result = obj
                    error = err
                    done = true
                    condition.signal()
                    condition.unlock()
                }
            }
            condition.lock()
            while !done {
                if !condition.waitUntilDate(NSDate(timeIntervalSinceNow: timeout)) {
                    break
                }
            }
            condition.unlock()
        }
        if error != nil { throw error! }
        if !done {
            print("!Timeout to evaluate script: \(script)")
        }
        print(result)
        return result
    }

}