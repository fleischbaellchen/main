// Playground - noun: a place where people can play

import UIKit
import XCPlayground
XCPSetExecutionShouldContinueIndefinitely()

let EAN = "7617027097710"

let url = NSURL(string: "http://api.autoidlabs.ch//products/\(EAN)")
let request = NSURLRequest(URL: url)

NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response, data, error) in
    println(NSString(data: data, encoding: NSUTF8StringEncoding))
    
    // Need to handle no network error
    
    // Extract JSON
    
    // Update our products, add to current list
})
