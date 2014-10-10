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
    var catName: String!
    var catID: String!
    var addedDate: NSDate!
    
    // Init Product from JSON
    init(data: JSON) {
        // set the properties from the json
    
    }
    
}