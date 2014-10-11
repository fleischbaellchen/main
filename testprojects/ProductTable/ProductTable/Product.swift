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
        self.EAN = ean
        self.addedDate = NSDate()
        
        self.catPath = []
        for (index: String, subJson: JSON) in data["catPath"] {
            self.catPath.append(subJson["name"].string!)
        }
        
        if let name = data["name"].string {
            // There's a name property
            self.name = name;
        } else {
            // No name, take it from catPath
            self.name = catPath[catPath.count - 1]
        }
        
        println("Created product with name \(name)")
    }
    
}