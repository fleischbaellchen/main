//
//  ViewController.swift
//  ProductTable
//
//  Created by Zeno Koller on 11.10.14.
//  Copyright (c) 2014 Zeno Koller. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var products: [Product]! = []
    
    @IBAction func getProduct() {
        let EAN = "7617027097710"
        let url = NSURL(string: "http://api.autoidlabs.ch//products/\(EAN)")
        let request = NSURLRequest(URL: url)
    
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response, data, error) in
    
                //println(NSString(data: data, encoding: NSUTF8StringEncoding))
    
                // Handle no network error
                if data == nil {
                    var alertController = UIAlertController(title: "Oops!", message: "Please check your network connection.", preferredStyle: .Alert)
                    var okAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    return
                }
    
                // Extract JSON and create Product
                let json = JSON(data: data)
                self.products.append(Product(data: json, ean: EAN))
    
                // Update table view
                if let tableView = self.tableView {
                    tableView.reloadData()
                } else {
                    println("No table view")
                }
        })
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let array = products {
            return array.count
        }
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("productCell", forIndexPath: indexPath) as UITableViewCell
        
        let product: Product = self.products[indexPath.row]
        let nameLabel = cell.viewWithTag(1) as UILabel
        nameLabel.text = product.name

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

