import Foundation

//: # Protocols
//: Protocols are, as per Apple's definition in the _Swift Programming Language_ book:
//:
//: "... a blueprint of methods, properties, and other requirements that suit a particular task or piece of functionality. The protocol can then be adopted by a class, structure, or enumeration to provide an actual implementation of those requirements. Any type that satisfies the requirements of a protocol is said to conform to that protocol."
//:
//: The below example shows a protocol that requires conforming types have a particular property defined.
protocol FullyNamed {
    var fullName: String { get }
    
}

struct Person: FullyNamed {
    var fullName: String
}

let johnny = Person(fullName: "Johnny Hicks")
let spencer = Person(fullName: "Spencer Curtis")


class Starship: FullyNamed {
    var prefix: String?
    var name: String
    
    init(name: String, prefix: String? = nil) {
        self.name = name
        self.prefix = prefix
    }
    
    // computed property - run a calculation when calling the getter
    var fullName: String {
        return (prefix != nil ? prefix! + " " : "") + name
    }
}

var ncc1701 = Starship(name: "Enterprise", prefix: "USS")
ncc1701.fullName

var firefly = Starship(name: "Serenity")
firefly.fullName

//: Protocols can also require that conforming types implement certain methods.
protocol GeneratesRandomNumbers {
    func random() -> Int
}

//adopt
class OneThroughTen: GeneratesRandomNumbers {
    //conform
    func random() -> Int {
        return Int.random(in: 1...10)
    }
}

let rand = OneThroughTen()
rand.random()

class OneThorughOneHundred: GeneratesRandomNumbers {
    func random() -> Int {
        return Int.random(in: 1...100)
    }
}

let rand2 = OneThorughOneHundred()
rand2.random()

//: Using built-in Protocols
extension Starship: Equatable {
    static func == (lhs: Starship, rhs: Starship) -> Bool {
        return lhs.fullName == rhs.fullName
    }
}

if ncc1701 == firefly {
    print("The ships are the same")
} else {
    print("the ships are different")
}


//: ## Protocols as Types
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

var d6 = Dice(sides: 6, generator: OneThroughTen())
for _ in 1...5 {
    print("Random dice roll is \(d6.roll())")
}

