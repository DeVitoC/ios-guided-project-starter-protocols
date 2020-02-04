import Foundation
//: We're building a dice game called _Knock Out!_. It is played using the following rules:
//: 1. Each player chooses a “knock out number” – either 6, 7, 8, or 9. More than one player can choose the same number.
//: 2. Players take turns throwing both dice, once each turn. Add the number of both dice to the player's running score.
//: 3. If a player rolls their own knock out number, they are knocked out of the game.
//: 4. Play ends when either all players have been knocked out, or if a single player scores 100 points or higher.
//:
//: Let's reuse some of the work we defined from the previous page.

protocol GeneratesRandomNumbers {
    func random() -> Int
}

class OneThroughTen: GeneratesRandomNumbers {
    func random() -> Int {
        return Int.random(in: 1...10)
    }
}

class Dice {
    let sides: Int
    let generator: GeneratesRandomNumbers
    
    init(sides: Int, generator: GeneratesRandomNumbers) {
        self.sides = sides
        self.generator = generator
    }
    
    func roll() -> Int {
        return Int(generator.random() % sides) + 1
    }
}

//: Now, let's define a couple protocols for managing a dice-based game.
protocol DiceGame {
    var dice: Dice { get }
    func play()
}

protocol DiceGameDelegate {
    func gameDidStart(_ game: DiceGame)
    func game(_ game: DiceGame, player: Player, didStartNewTurnWithDiceRoll diceRoll: Int)
    func gameDidEnd(_ game: DiceGame)
}


//: Lastly, we'll create a custom class for tracking a player in our dice game.
class Player {
    let id: Int
    let knockOutNumber: Int = Int.random(in: 6...9)
    var score: Int = 0
    var knockedOut: Bool = false
    
    init(id: Int) {
        self.id = id
    }
}



//: With all that configured, let's build our dice game class called _Knock Out!_
class KnockOut: DiceGame {
    var dice: Dice = Dice(sides: 6, generator: OneThroughTen())
    var players: [Player] = []
    var delegate: DiceGameDelegate?
    
    init(numberOfPlayers: Int) {
        for i in 1...numberOfPlayers {
            let aPlayer = Player(id: i)
            players.append(aPlayer)
        }
    }
    
    func play() {
        delegate?.gameDidStart(self)
        var reachedGameEnd = false
        
        // We are going to play until the game is over
        while !reachedGameEnd {
            // Each player who has not been knowcked out gets a turn
            for player in players where player.knockedOut == false {
                //roll 2 6 sided dice and add together
                let diceRollSum = dice.roll() + dice.roll()
                
                delegate?.game(self, player: player, didStartNewTurnWithDiceRoll: diceRollSum)
                
                // did i roll my knockout number?
                if diceRollSum == player.knockOutNumber {
                    // if i rolled my knockout number, this happens
                    print("Player \(player.id) is knocked out by rolling: \(player.knockOutNumber)")
                    // i've been knocked out
                    player.knockedOut = true
                    
                    //if everyone is knocked out, game is over
                    let activePlayers = players.filter( {$0.knockedOut == false })
                    
                    if activePlayers.count == 0 {
                        // no more players - game over
                        reachedGameEnd = true
                        delegate?.gameDidEnd(self)
                        print("All players have been knocked out!")
                    }
                } else {
                    // I didn't get knockedo out, give me a higher score
                    player.score += diceRollSum
                    // Did I win?
                    if player.score >= 100 {
                        // if so, game is over
                        reachedGameEnd = true
                        delegate?.gameDidEnd(self)
                        print("Player \(player.id) has won with a final score of \(player.score)")
                    }
                }
            }
        }
    }
}

//let game = KnockOut(numberOfPlayers: 5)
//game.play()


//: The following class is used to track the status of the above game, and will conform to the `DiceGameDelegate` protocol.
class DiceGameTracker: DiceGameDelegate {
    var numberOfTurns = 0
    
    func gameDidStart(_ game: DiceGame) {
        numberOfTurns = 0
        if game is KnockOut {
            print("Started a new game of Knock Out")
        }
        print("The game is using a \(game.dice.sides)-sided dice")
    }
    
    func game(_ game: DiceGame, player: Player, didStartNewTurnWithDiceRoll diceRoll: Int) {
        numberOfTurns += 1
        print("Player #\(player.id) rolled a \(diceRoll)")
    }
    
    func gameDidEnd(_ game: DiceGame) {
        print("The game lasted for \(numberOfTurns) turns.")
    }
}


//: Finally, we need to test out our game. Let's create a game instance, add a tracker, and instruct the game to play.
let tracker = DiceGameTracker()
let game = KnockOut(numberOfPlayers: 5)

game.delegate = tracker
game.play()

