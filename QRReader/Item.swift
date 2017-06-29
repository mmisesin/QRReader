//
//  Item.swift
//  QRReader
//
//  Created by Artem Misesin on 5/6/17.
//  Copyright © 2017 Artem Misesin. All rights reserved.
//

import Foundation

class Item {
    var name: String = String()
    var price: Double = Double()
    var quantity: Int = Int()
    
    var total: Double{
        get{
            return price * Double(quantity)
        }
    }
}
