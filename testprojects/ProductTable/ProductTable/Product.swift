//
//  Product.swift
//  ProductTable
//
//  Created by Zeno Koller on 11.10.14.
//  Copyright (c) 2014 Zeno Koller. All rights reserved.
//

import Foundation

class Product {

    var EAN: String!
    var id: String! // The id we received from the API
    var name: String!
    var catPath: [String]!
    var addedDate: NSDate!
    
    // Init Product from JSON
    init(data: JSON, ean: String) {
        self.catPath = []
        for (index: String, subJson: JSON) in data["catPath"] {
            self.catPath.append(subJson["name"].string!)
        }
        self.EAN = ean
        self.name = catPath[catPath.count - 1] // Product name is last item
        self.addedDate = NSDate()
        
        println("Created product with name \(name)")
    }
    
}