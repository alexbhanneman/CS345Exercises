//
//  DisperseViewController.swift
//  Disperse
//
//  Created by Nicole Anderson, Tim Gegg-Harrison on 11/15/14.
//  Copyright (c) 2014 TiNi Apps. All rights reserved.
//

import UIKit

let IS_IPHONE4: Bool = UIScreen.mainScreen().bounds.size.height == 480
let IS_IPHONE5: Bool = UIScreen.mainScreen().bounds.size.height == 568
let IS_IPHONE6: Bool = UIScreen.mainScreen().bounds.size.height == 667
let IS_IPHONE6PLUS: Bool = UIScreen.mainScreen().bounds.size.height == 736
let IS_IPAD: Bool = UIScreen.mainScreen().bounds.size.height == 1024
let CARDWIDTH: CGFloat = 75
let CARDHEIGHT: CGFloat = 107
let BOARDWIDTH: CGFloat = 300
let BOARDHEIGHT: CGFloat = 428
let CARDTHICKNESS: CGFloat = 3
let MAXCARDS: Int = 10

class DisperseViewController: UIViewController, UIAlertViewDelegate {

    private var presentingController: ViewController
    private var BOARDTOPOFFSET: CGFloat
    private var BOARDLEFTOFFSET: CGFloat
    private var blue: UIColor
    private var orange: UIColor
    private var boardView: UIView
    private var playButton: UIButton
    private var blueTurn: Bool
    private var clubsView: UIImageView
    private var diamondView: UIImageView
    private var heartView: UIImageView
    private var spadeView: UIImageView
    
    
    var game: GameState
    var spades: Bool
    var hearts: Bool
    var diamonds: Bool
    var clubs: Bool
    
    init(parent: ViewController) {
        presentingController = parent
        game = GameState()
        
        var CONTROLTOPOFFSET: CGFloat
        var CONTROLLEFTOFFSET: CGFloat
        var CONTROLSIZE: CGFloat
        var CONTROLSPACE: CGFloat
        let CONTROLPAD: CGFloat = 10.0
        var SCORETOPOFFSET: CGFloat
        var SCORESIZE: CGFloat
        var SUITIMAGETOPOFFSET: CGFloat
        let SUITIMAGESIZE: CGFloat = 36.0
        let result: CGSize = UIScreen.mainScreen().bounds.size
        if IS_IPAD {
            CONTROLSIZE = 60
        }
        else {
            if IS_IPHONE6PLUS {
                CONTROLSIZE = 45
            }
            else if IS_IPHONE6 {
                CONTROLSIZE = 40
            }
            else {
                CONTROLSIZE = 30
            }
        }
        CONTROLSPACE = (result.width - (5.0 * CONTROLSIZE)) / 6.0
        CONTROLTOPOFFSET = (UIScreen.mainScreen().bounds.size.height - CONTROLSIZE) - CONTROLPAD
        CONTROLLEFTOFFSET = (2.0 * CONTROLSPACE) + CONTROLSIZE
        SCORESIZE = CONTROLSIZE / 2.0
        SCORETOPOFFSET = CONTROLTOPOFFSET - CONTROLSIZE
        SUITIMAGETOPOFFSET = (UIScreen.mainScreen().bounds.size.height - UIScreen.mainScreen().applicationFrame.size.height)
        BOARDTOPOFFSET = (SCORETOPOFFSET - (IS_IPAD ? 2*BOARDHEIGHT : BOARDHEIGHT)) / 3.0
        BOARDLEFTOFFSET = (result.width - (IS_IPAD ? 2*BOARDWIDTH : BOARDWIDTH)) / 2.0
        CONTROLTOPOFFSET -= BOARDTOPOFFSET
        SCORETOPOFFSET -= BOARDTOPOFFSET
        
        blue = UIColor(red: 0.0, green: 0.0, blue: 0.609375, alpha: 1.0)
        orange = UIColor(red: 0.96484375, green: 0.49609375, blue: 0.0, alpha: 1.0)
        
        blueTurn = true
        spades = true
        hearts = true
        diamonds = true
        clubs = true
        boardView = UIView(frame: CGRectMake(0, BOARDTOPOFFSET, result.width, result.height-BOARDTOPOFFSET))
        playButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton

        //added
        clubsView = UIImageView(image: UIImage(named: "club.png"))
        diamondView = UIImageView(image: UIImage(named: "diamond.png"))
        heartView = UIImageView(image: UIImage(named: "heart.png"))
        spadeView = UIImageView(image: UIImage(named: "spade.png"))
        
        clubsView.frame = CGRectMake(0,  SUITIMAGETOPOFFSET, SUITIMAGESIZE, SUITIMAGESIZE)
        diamondView.frame = CGRectMake(result.width - SUITIMAGESIZE, SUITIMAGETOPOFFSET, SUITIMAGESIZE, SUITIMAGESIZE)
        heartView.frame = CGRectMake(0,  CONTROLTOPOFFSET-(SUITIMAGESIZE + CONTROLPAD), SUITIMAGESIZE, SUITIMAGESIZE)
        spadeView.frame = CGRectMake(result.width - SUITIMAGESIZE, CONTROLTOPOFFSET-(SUITIMAGESIZE + CONTROLPAD), SUITIMAGESIZE, SUITIMAGESIZE)
        
        super.init(nibName: nil, bundle: nil)
        self.view = UIView(frame: UIScreen.mainScreen().bounds)
    
        boardView.clipsToBounds = true
        boardView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(boardView)
        
        playButton.frame = CGRectMake(CONTROLLEFTOFFSET+(CONTROLSPACE+CONTROLSIZE)*1, CONTROLTOPOFFSET, CONTROLSIZE, CONTROLSIZE)
        playButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal) //play.png
        playButton.addTarget(self, action: "playButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        playButton.enabled = false
        
        boardView.addSubview(playButton)
        boardView.addSubview(clubsView)
        boardView.addSubview(diamondView)
        boardView.addSubview(heartView)
        boardView.addSubview(spadeView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // The following 3 methods were "borrowed" from http://stackoverflow.com/questions/15710853/objective-c-check-if-subviews-of-rotated-uiviews-intersect and converted to Swift
    private func projectionOfPolygon(poly: [CGPoint], onto: CGPoint) ->  (min: CGFloat, max: CGFloat) {
        var minproj: CGFloat = CGFloat.max
        var maxproj: CGFloat = -CGFloat.max
        for var i: Int = 0; i < poly.count; ++i {
            let proj: CGFloat = poly[i].x * onto.x + poly[i].y * onto.y
            if proj > maxproj {
                maxproj = proj
            }
            if proj < minproj {
                minproj = proj
            }
        }
        return (minproj, maxproj)
    }
    
    private func convexPolygon(#poly1: [CGPoint], poly2: [CGPoint]) -> Bool {
        for var i: Int = 0; i < poly1.count; ++i {
            // Perpendicular vector for one edge of poly1:
            let p1: CGPoint = poly1[i];
            let p2: CGPoint = poly1[(i+1) % poly1.count];
            let perp: CGPoint = CGPointMake(p1.y - p2.y, p2.x - p1.x)
            
            // Projection intervals of poly1, poly2 onto perpendicular vector:
            var minp1, maxp1, minp2, maxp2: CGFloat;
            (minp1,maxp1) = self.projectionOfPolygon(poly1, onto: perp)
            (minp2,maxp2) = self.projectionOfPolygon(poly2, onto: perp)
            
            // If projections do not overlap then we have a "separating axis"
            // which means that the polygons do not intersect:
            if maxp1 < minp2 || maxp2 < minp1 {
                return false
            }
        }
        // And now the other way around with edges from poly2:
        for var i: Int = 0; i < poly2.count; ++i {
            // Perpendicular vector for one edge of poly2:
            let p1: CGPoint = poly2[i];
            let p2: CGPoint = poly2[(i+1) % poly2.count];
            let perp: CGPoint = CGPointMake(p1.y - p2.y, p2.x - p1.x)
            
            // Projection intervals of poly1, poly2 onto perpendicular vector:
            var minp1, maxp1, minp2, maxp2: CGFloat;
            (minp1,maxp1) = self.projectionOfPolygon(poly1, onto: perp)
            (minp2,maxp2) = self.projectionOfPolygon(poly2, onto: perp)
            
            // If projections do not overlap then we have a "separating axis"
            // which means that the polygons do not intersect:
            if maxp1 < minp2 || maxp2 < minp1 {
                return false
            }
        }
        return true
    }

    private func viewsIntersect(#view1: UIView, view2: UIView) -> Bool {
        return self.convexPolygon(poly1: [view1.convertPoint(view1.bounds.origin, toView: nil), view1.convertPoint(CGPointMake(view1.bounds.origin.x + view1.bounds.size.width, view1.bounds.origin.y), toView: nil), view1.convertPoint(CGPointMake(view1.bounds.origin.x + view1.bounds.size.width, view1.bounds.origin.y + view1.bounds.height), toView: nil), view1.convertPoint(CGPointMake(view1.bounds.origin.x, view1.bounds.origin.y + view1.bounds.height), toView: nil)], poly2: [view2.convertPoint(view1.bounds.origin, toView: nil), view2.convertPoint(CGPointMake(view2.bounds.origin.x + view2.bounds.size.width, view2.bounds.origin.y), toView: nil), view2.convertPoint(CGPointMake(view2.bounds.origin.x + view2.bounds.size.width, view2.bounds.origin.y + view2.bounds.height), toView: nil), view2.convertPoint(CGPointMake(view2.bounds.origin.x, view2.bounds.origin.y + view2.bounds.height), toView: nil)])
    }
    
    private func cardIsOpenAtIndex(i: Int) -> Bool {
        var j: Int = i+1
        while j < game.board.count && (game.board[j].removed || !self.viewsIntersect(view1: game.board[i], view2: game.board[j])) {
            ++j
        }
        return (j >= game.board.count)
    }
    
    private func unhighlightCards() {
        for card in game.board {
            card.highlight("\0")
        }
    }

    private func highlightOpenCards() {
        for var i: Int = 0; i < game.board.count; ++i {
            let card: CardView = game.board[i]
            if (card.suit == "s" && spades) || (card.suit == "h" && hearts) || (card.suit == "d" && diamonds) || (card.suit == "c" && clubs) {
                if !card.removed && self.cardIsOpenAtIndex(i) {
                    card.highlight("g")
                }
            }
        }
    }
    
    private func rehighlightOpenCards() {
        self.unhighlightCards()
        self.highlightOpenCards()
    }
    
    //check
    private func setSuitIndicators() {
        if !spades {
            spadeView.removeFromSuperview()
        }
        if !diamonds {
            diamondView.removeFromSuperview()
        }
        if !hearts {
            heartView.removeFromSuperview()
        }
        if !clubs{
            clubsView.removeFromSuperview()
        }
    }
    
    //new turn or game
    //all boolean flags to true & all suits displayed
    private func resetSuitIndicators() {
        boardView.addSubview(clubsView)
        boardView.addSubview(diamondView)
        boardView.addSubview(heartView)
        boardView.addSubview(spadeView)
        spades = true
        hearts = true
        diamonds = true
        clubs = true
        
    }
    
    func updateSuitIndicatorForCard(card: CardView) {
        if card.suit == "s" {
            spades = false
        }
        else if card.suit == "h" {
            hearts = false
        }
        else if card.suit == "d" {
            diamonds = false
        }
        else {
            clubs = false
        }
        
        //updates screen based on suit
        setSuitIndicators()
    }

    func handlePan(recognizer: UIPanGestureRecognizer) {
        let card: CardView = recognizer.view as CardView
        if card.highlighted() && !card.removed {
            let translation: CGPoint = recognizer.translationInView(boardView)
            recognizer.view?.center = CGPointMake(recognizer.view!.center.x + translation.x, recognizer.view!.center.y + translation.y)
            recognizer.setTranslation(CGPointMake(0, 0), inView: boardView)
            if recognizer.state == UIGestureRecognizerState.Ended {
                self.updateSuitIndicatorForCard(card)
                card.removed = true
                card.removeFromSuperview()
                self.rehighlightOpenCards()
                if !playButton.enabled {
                    playButton.enabled = true
                }
                
                // save current state of game
            }
        }
    }

    private func cleanUpBoard() {
        NSLog("cleaning up board...")
        for card in game.board {
            if !card.removed {
                card.removeFromSuperview()
            }
        }
        game.board = [CardView]()
    }

    private func layoutBoard() {
        for card in game.board {
            if !card.removed {
                boardView.addSubview(card)
            }
        }
    }
    
    private func createCards() {
        let numOfCards: Int = MAXCARDS + Int(arc4random_uniform(UInt32(MAXCARDS/2)))
        var cardValue: Character = "b"
        var cardSuit: Character = "c"
        var card: CardView
        game.board = [CardView]()
        for var i: Int = 0; i < numOfCards; ++i {
            card = CardView(suit: cardSuit, value: cardValue)
            game.board.append(card)
            if cardSuit == "c" {
                cardSuit = "d"
            }
            else if cardSuit == "d" {
                cardSuit = "h"
            }
            else if cardSuit == "h" {
                cardSuit = "s"
            }
            else {
                cardSuit = "c"
                if cardValue == "b" {
                    cardValue = "c"
                }
                else if cardValue == "c" {
                    cardValue = "d"
                }
                else if cardValue == "d" {
                    cardValue = "e"
                }
                else {
                    cardValue = "b"
                }
            }
        }
    }
    
    private func layoutCard(card: CardView) {
        var center: CGPoint = CGPointMake(0, 0)
        let radianConversion: CGFloat = CGFloat(M_PI) / 180
        center.x = BOARDLEFTOFFSET + (IS_IPAD ? (2*card.location.x) : card.location.x)
        center.y = BOARDTOPOFFSET + (IS_IPAD ? (2*card.location.y) : card.location.y)
        card.center = center
        card.transform = CGAffineTransformMakeRotation(card.rotation*radianConversion)
    }
    
    func displayCard(card: CardView, index: Int, rotation: CGFloat, location: CGPoint) {
        card.index = index
        card.rotation = rotation
        card.location = location
        card.removed = false
        card.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "handlePan:"))
        self.layoutCard(card)
    }
    
    func displayCards() {
        var card: CardView
        var x,y,rotation,sign: CGFloat
        x = BOARDWIDTH/2
        y = BOARDHEIGHT/2
        self.displayCard(game.board[0], index: 0, rotation: 0, location: CGPointMake(x, y))
        for var i: Int = 1; i < game.board.count; ++i {
            sign = CGFloat(arc4random_uniform(2))
            if sign == 0 {
                sign = -1
            }
            x = BOARDWIDTH/2 + sign*CGFloat(arc4random_uniform(UInt32(CARDWIDTH)))
            sign = CGFloat(arc4random_uniform(2))
            if sign == 0 {
                sign = -1
            }
            y = BOARDHEIGHT/2 + sign*CGFloat(arc4random_uniform(UInt32(CARDHEIGHT)))
            rotation = CGFloat(arc4random_uniform(45))
            sign = CGFloat(arc4random_uniform(2))
            if sign == 0 {
                rotation *= -1
            }
            self.displayCard(game.board[i], index: i, rotation: rotation, location: CGPointMake(x, y))
        }
    }
    
    func shuffleCards() {
        var card: CardView
        for var i: Int = 0; i < 1000; ++i {
            let j: Int = Int(arc4random_uniform(UInt32(game.board.count)))
            let k: Int = Int(arc4random_uniform(UInt32(game.board.count)))
            card = game.board[j]
            game.board[j] = game.board[k]
            game.board[k] = card
        }
    }
    
    func createBoard() {
        self.createCards()
        self.shuffleCards()
        self.displayCards()
    }
    
    private func buildBoard() {
        self.cleanUpBoard()
        self.createBoard()
        self.layoutBoard()
        self.setSuitIndicators()
        self.highlightOpenCards()
        playButton.enabled = false
    }
    
    private func setBackground() {
        if blueTurn {
            self.view.backgroundColor = blue
        }
        else {
            self.view.backgroundColor = orange
        }
    }
    
    private func enterNewRound() {
        self.buildBoard()
        // save current state of game
    }
    
    func enterNewGame() {
        blueTurn = true
        self.setBackground()
        self.enterNewRound()
    }

    func checkForWin() -> Bool{
        var win = true
        for j in game.board {
            if !j.removed {
                win = false
            }
        }
        
        return win
    }
    
    func playButtonPressed() {
        if checkForWin() {
            var myLabel: UILabel
            
            myLabel = UILabel(frame: CGRectMake(100, 20, 200, 50))
            
            if blueTurn {
                myLabel.text = "Orange is Winner!!!" //add team that won
                myLabel.textAlignment = .Center
                myLabel.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                self.view.backgroundColor = orange
            }else {
                myLabel.text = "Blue is Winner!!!" //add team that won
                myLabel.textAlignment = .Center
                myLabel.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                self.view.backgroundColor = blue
            }
            
            boardView.addSubview(myLabel)
            
        }else {
            playButton.enabled = false
            self.resetSuitIndicators()
            self.unhighlightCards()
            blueTurn = !blueTurn
            self.setBackground()
            self.setSuitIndicators()
            self.highlightOpenCards()
        }
    }
}
