// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each declaration when you start working on it.


// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab:    return 3
        case .engine: return 4
        case .cargo:  return 5
        }
    }
}

print("1.1 Deck")
for deck in Deck.allCases {
    print("\(deck.rawValue): priority \(deck.evacuationPriority)")
}

// 1.2
enum AlarmLevel: Int {
    case green = 0
    case yellow
    case orange
    case red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let step = min(mass / 500, AlarmLevel.red.rawValue)
        return AlarmLevel(rawValue: step) ?? .red
    }
}

print("1.2 AlarmLevel")
print(AlarmLevel.level(forTotalMass: 0))
print(AlarmLevel.level(forTotalMass: 940))
print(AlarmLevel.level(forTotalMass: 4000))



// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    guard let tag = parts.first else { return .unknown(raw: line) }

    switch tag {
    case "crate":
        guard parts.count == 3,
              let id = Int(parts[1]),
              let mass = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .crate(id: id, massKg: mass)

    case "container":
        guard parts.count == 3,
              let mass = Int(parts[2]) else {
            return .unknown(raw: line)
        }
        return .container(code: parts[1], massKg: mass)

    case "livestock":
        guard parts.count == 4,
              let count = Int(parts[2]),
              let massPerUnit = Int(parts[3]) else {
            return .unknown(raw: line)
        }
        return .livestock(species: parts[1], count: count, massPerUnitKg: massPerUnit)

    default:
        return .unknown(raw: line)
    }
}

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let massKg):
        return massKg
    case .container(_, let massKg):
        return massKg
    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

print("2.2 / 2.3 parseEntry + mass")
var parsedEntries: [ManifestEntry] = []
var totalMass = 0
var unknownCount = 0

for line in rawManifest {
    let entry = parseEntry(line)
    parsedEntries.append(entry)
    totalMass += mass(of: entry)
    if case .unknown = entry {
        unknownCount += 1
        print("corrupted line: \"\(line)\"")
    }
}

print("Total mass: \(totalMass), unknown lines: \(unknownCount)")
let A = totalMass

// MARK: Level 3 · Crew Snapshots

// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = max(0, oxygen - amount)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        // whole new value assigned to self, not property-by-property
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

// 3.2
var crewRoster: [CrewSnapshot] = []
for record in crewData {
    guard let deck = Deck(rawValue: record.deck) else {
        print("Unknown deck for \(record.name): \(record.deck)")
        continue
    }
    crewRoster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
}

print("3.2 crewRoster")
for member in crewRoster {
    print("\(member.name) on \(member.deck.rawValue): \(member.oxygen)%")
}

// 3.3 · Value-semantics demonstration (copy / plain parameter / inout)

print("3.3 value semantics demo")

// 1. Copy
let originalSnap = CrewSnapshot.rookie(named: "Zhandos")
var copySnap = originalSnap
copySnap.oxygen = 10
print("1) original before/after: \(originalSnap.oxygen)/\(originalSnap.oxygen)  copy: \(copySnap.oxygen)")

// 2. Plain
func drainNonMutating(_ member: CrewSnapshot) -> CrewSnapshot {
    var local = member
    local.oxygen = 0
    return local
}
let beforePlain = originalSnap.oxygen
_ = drainNonMutating(originalSnap)
print("2) original before: \(beforePlain), after calling plain function: \(originalSnap.oxygen) (unchanged)")

// 3. inout
func drainInout(_ member: inout CrewSnapshot) {
    member.oxygen = 0
}
var mutableSnap = originalSnap
let beforeInout = mutableSnap.oxygen
drainInout(&mutableSnap)
print("3) before: \(beforeInout), after inout call: \(mutableSnap.oxygen) (changed)")

// MARK: Level 4 · The Teleport Pod

// 4.1
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil, chargeLevel >= 20 else { return false }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let passenger = occupant else { return nil }
        chargeLevel -= 20
        occupant = nil
        return passenger
    }

    deinit {
        print("Pod \(id) decommissioned")
    }
}

// helper
func findCrew(named name: String, in roster: [CrewSnapshot]) -> CrewSnapshot? {
    for member in roster {
        if member.name == name { return member }
    }
    return nil
}

// 4.2 · Charge ledger: load+fire three times, then fire an empty pod
print("4.2 charge ledger")
let ledgerPod = TeleportPod(id: "P-1", chargeLevel: 100)

if let timur = findCrew(named: "Timur", in: crewRoster) {
    _ = ledgerPod.load(timur)
}
_ = ledgerPod.fire()
print("after Timur: \(ledgerPod.chargeLevel)")

if let dana = findCrew(named: "Dana", in: crewRoster) {
    _ = ledgerPod.load(dana)
}
_ = ledgerPod.fire()
print("after Dana: \(ledgerPod.chargeLevel)")

if let nurlan = findCrew(named: "Nurlan", in: crewRoster) {
    _ = ledgerPod.load(nurlan)
}
_ = ledgerPod.fire()
print("after Nurlan: \(ledgerPod.chargeLevel)")

_ = ledgerPod.fire() //no charge spent
print("after firing empty pod: \(ledgerPod.chargeLevel)")

let C = ledgerPod.chargeLevel

// 4.3 · Reference-semantics demonstration

print("4.3 reference semantics demo")
let podRefA = TeleportPod(id: "X", chargeLevel: 50)
let podRefB = podRefA
podRefB.chargeLevel = 5
print("podA: \(podRefA.chargeLevel), podB: \(podRefB.chargeLevel)")

// MARK: Level 5 · Station Systems

// 5.1
final class Station {
    let callSign: String

    var oxygenByDeck: [Deck: Int] = [:]

    var hullIntegrity: Int = 100 {
        willSet {
            print("hullIntegrity changing from \(hullIntegrity) to \(newValue)")
        }
        didSet {
            if hullIntegrity > 100 { hullIntegrity = 100 }
            else if hullIntegrity < 0 { hullIntegrity = 0 }
            
        }
    }

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        return "Diagnostics for \(callSign): hull \(hullIntegrity)%, total O2 \(totalOxygen)"
    }()

    var totalOxygen: Int {
        var sum = 0
        for value in oxygenByDeck.values { sum += value }
        return sum
    }

    var averageOxygen: Int {
        get {
            guard !oxygenByDeck.isEmpty else { return 0 }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for key in oxygenByDeck.keys {
                oxygenByDeck[key] = newValue
            }
        }
    }

    init(callSign: String) {
        self.callSign = callSign
        for reading in deckReadings {
            if let deck = Deck(rawValue: reading.deck) {
                oxygenByDeck[deck] = reading.oxygen
            } else {
                print("Unknown deck in readings: \(reading.deck)")
            }
        }
    }
}

print("5.1 Station")
let station = Station(callSign: "ALMA-7")
let B = station.averageOxygen
print("starting averageOxygen (B) = \(B)")

print("touching fullDiagnostics first time:")
print(station.fullDiagnostics)
print("touching fullDiagnostics second time (no scan message expected):")
print(station.fullDiagnostics)

// 5.2 · The clamp trap: 130, then -40, then 55
print("5.2 clamp trap")
station.hullIntegrity = 130
print("after 130 -> \(station.hullIntegrity)")
station.hullIntegrity = -40
print("after -40 -> \(station.hullIntegrity)")
station.hullIntegrity = 55
print("after 55  -> \(station.hullIntegrity)")


// MARK: Level 6 · Incident Reports
// Three of these compile and are wrong. One does not compile.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
var roster = crewRoster
for var member in roster {
    member.oxygen -= 10
}
print(roster[0].oxygen)
 
 
 Expected: The crew members in `roster` running out of oxygen.

 Actual: In modern versions of Swift, the `var`  is no longer allowed in a `for-in` loop

 Rule: Semantics of values when structures are copied during assignment/iteration.

 Fix:
 var roster2 = crewRoster
 for i in roster2.indices {
     roster2[i].oxygen -= 10
 }
 print(roster2[0].oxygen)

func report1Fix() {
    var roster2 = crewRoster
    for i in roster2.indices {
        roster2[i].oxygen -= 10
    }
    print("Report 1 fixed, roster2[0].oxygen =", roster2[0].oxygen)
}

// Report 2
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 0
print(podA.chargeLevel)   // author expected 100

 
Expected: 100

Actual: 0. TeleportPod is a class, so `podB = podA`
 copies the REFERENCE, not the object itself.
 
Rule: Reference semantics `let` only defines which object a
 class variable points to.
 
 Fix, if independent pods were actually wanted:
 let podB2 = TeleportPod(id: podA.id, chargeLevel: podA.chargeLevel)


// Report 3
struct Logbook {
    var entries: [String] = []
    func add(_ entry: String) {
        entries.append(entry)
    }
}

 Expected: The author expected this code to compile and work.
 
 Actual: It doesn't compile at all.
 
 Fix:
 struct LogbookFixed {
     var entries: [String] = []
     mutating func add(_ entry: String) {
         entries.append(entry)
     }
 }
 
// Report 4
let snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10
 
 Expected: the code compiles, and each crew member in `roster` loses 10 oxygen.
 
 Actual:  depends on Swift version. either it doesn't compile at all, or it compiles but roster stays unchanged.
 
 Rule: value semantics it's when structs are copied, mutating a copy never ouches the original array.
*/


// MARK: Level 7 · Sealing the Black Box

// The leaky original:
//
// class FlightRecorder {
//     var entries: [String] = []
//     var isSealed = false
// }
//
// Your sealed version below. One comment per access keyword.

// final class FlightRecorder { }

// A free function elsewhere in the file that uses your fileprivate helper:
// func auditTranscript(of recorder: FlightRecorder) -> String { }


// MARK: Finale · Integrity Code

final class FlightRecorder {
    private var entries: [String] = []
    private(set) var isSealed = false

    var entryCount: Int {
        entries.count
    }

    func transcript() -> String {
        entries.joined(separator: " | ")
    }

    func add(_ entry: String) {
        guard !isSealed else {
            print("Recorder sealed — cannot add: \(entry)")
            return
        }
        entries.append(entry)
    }

    func seal() {
        isSealed = true
    }
    fileprivate func rawEntries() -> [String] {
        entries
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    let lines = recorder.rawEntries()
    return "AUDIT (\(lines.count) entries): " + lines.joined(separator: "; ")
}

print("Level 7 FlightRecorder")
let recorder = FlightRecorder()
recorder.add("engine check ok")
recorder.add("hull integrity nominal")
recorder.seal()
recorder.add("ignored after seal")
print(recorder.transcript())
print(auditTranscript(of: recorder))


// MARK: Bonus

// deinit in TeleportPod, a do-block lifetime experiment, and === identity

//print("Bonus: do-block lifetime")
//print("before do block")
//var keptPodRef: TeleportPod?
//do {
//    let podInDo = TeleportPod(id: "TEMP", chargeLevel: 10)
//    keptPodRef = podInDo
//    print("inside do block — pod still referenced by keptPodRef too")
//}
//print("just left do block — pod is STILL alive because keptPodRef holds it")
//keptPodRef = nil
//print("just released keptPodRef — deinit should print right above this line")
//
//func samePod(_ a: TeleportPod, _ b: TeleportPod) -> Bool {
//    a === b
//}



// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
 
 CrewSnapshot is a struct with no custom init, so Swift auto-generates a memberwise init from its stored properties. Classes never get this, because they support inheritance. Swift don't know in advance what a subclass's initializer requirements will be, so every class must write its own init explicitly.
 
 2. What does `mutating` do to self, and why do classes never need it?
 
 Inside a struct method, `self` is normally a read-only local copy of the value. `mutating` tells the compiler this method is allowed to reassign `self` or its stored properties and write the result back into the original variable the struct lives in. Classes never need it because a class instance is a reference. any method can change the object's properties directly through that reference without ever needing to rebind `self`.

 3. In Report 4 both values are `let`. What exactly does `let` freeze for a
    struct, and what does it freeze for a class?
 
 For a struct, `let` freezes the entire value, all of its properties because the struct IS its data, stored as one unit. For a class, `let` freezes only the reference itself: which object the variable points to cannot change, but the object's own `var` properties remain mutable through that same reference.

 4. Why must a lazy property be var? When does lazy change behaviour, not
    just performance?
 
 `lazy` means the initial value is computed on first access and then stored. That requires writing to the property at least once after the instance exists, which `let` would not allow. It changes behaviour, not just performance,  whenever the initializer has a side effect like here, fullDiagnostics prints "Running full scan..." only if and when it's actually accessed.

 5. private vs fileprivate: where in your FlightRecorder would private be
    too strict?
 
 `rawEntries()` needs to be called by `auditTranscript(of:)`, which is a free function declared in the same file but outside the FlightRecorder type. `private` also would hide it from that function, so the audit function couldn't compile. and `fileprivate` keeps it hidden from other files/modules while still allowing same-file helper functions to use it.

 Bonus. On which line does deinit fire, and why can't === be used on
 CrewSnapshot?

 deinit fires right after `keptPodRef = nil`, because that's the moment the last strong reference to the TEMP pod is released. ARC deallocates the object as soon as its reference count hits zero.  === can't be used on CrewSnapshot because it's a struct and there is only independent copies of data, so only value equality

*/
