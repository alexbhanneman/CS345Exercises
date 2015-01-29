//
//  CardView.swift
//  Disperse
//
//  Created by Nicole Anderson, Tim Gegg-Harrison on 11/15/14.
//  Copyright (c) 2014 TiNi Apps. All rights reserved.
//

import UIKit

class CardView: UIView {

    var suit: Character
    var value: Character
    var imageView: UIImageView
    var index: Int
    var highlightColor: Character
    var rotation: CGFloat
    var location: CGPoint
    var removed: Bool //need that boolean
    
    init(suit: Character, value: Character) {
        self.suit = suit
        self.value = value
        index = 0
        highlightColor = "\0"
        rotation = 0
        location = CGPointMake(0, 0)
        removed = false
        imageView = UIImageView(image: UIImage(named: "\(suit)-\(value)-150.png"))
        super.init(frame: CGRectMake(0, 0, (IS_IPAD ? 2*CARDWIDTH : CARDWIDTH), (IS_IPAD ? 2*CARDHEIGHT : CARDHEIGHT)))
        imageView.frame = self.bounds
        self.addSubview(imageView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func highlight(color: Character) {
        highlightColor = color
        imageView.image = UIImage(named: "\(suit)-\(value)-150\(color).png")
    }
    
    func highlighted() -> Bool {
        return highlightColor != "\0"
    }
    
    //func check for win
}
