//
//  GameState.swift
//  Disperse
//
//  Created by Nicole Anderson, Tim Gegg-Harrison on 11/15/14.
//  Copyright (c) 2014 TiNi Apps. All rights reserved.
//

import UIKit

let TNBoard: String = "Board"

class GameState: NSObject, NSCoding {
    var board: [CardView]
    
    override init() {
        board = [CardView]()
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        board = aDecoder.decodeObjectForKey(TNBoard) as [CardView]
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(board, forKey: TNBoard)
    }
}
