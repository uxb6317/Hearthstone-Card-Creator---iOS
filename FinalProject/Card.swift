//
//  Card.swift
//  FinalProject
//
//  Created by Student on 12/13/18.
//  Copyright © 2018 Student. All rights reserved.
//

import Foundation
import RealmSwift

class Card: Object {
    @objc dynamic public private(set) var id = UUID().uuidString
    @objc dynamic var cardClass: String = "neutral"
    @objc dynamic var rarity: String = "collectable"
    @objc dynamic var attack: String = ""
    @objc dynamic var cost: String = ""
    @objc dynamic var health: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var cardDescription: String = ""
    @objc dynamic var race: String = ""
    @objc dynamic var durability: String = ""
    @objc dynamic var type: String = "minion"
    @objc dynamic var image: String = "neutral_collectable_minion"
    
    override class func primaryKey() -> String {
        return "id"
    }
}
