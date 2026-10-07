// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?  -> because PowerCell is a shared state. If we had made it a struct, then when passing it to a drone or any other object, we would have received a copy of the battery. As a result, the drone would have used up the charge in its local copy, whilst the original battery would have remained untouched. A class provides reference semantics — all objects refer to the same instance of PowerCell and see its actual, current charge level.

Translated with DeepL.com (free version)
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = min(max(charge, 0), 100)
    }

    func level() -> Int {
        charge
    }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, amount <= charge else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge = min(charge + amount, 100)
    }
}

print("Level 1: PowerCell")
let demoCell = PowerCell(charge: 150)   // clamped to 100
print("demoCell starts at \(demoCell.level())%")
print("spend(30):", demoCell.spend(30), "-> now \(demoCell.level())%")
print("spend(-5):", demoCell.spend(-5), "-> unchanged at \(demoCell.level())%")
demoCell.recharge(by: 1000)
print("recharge(1000) clamps to \(demoCell.level())%")

// Encapsulation proof (leave this commented, with the compiler error):
// demoCell.charge = 100
// error: there is no access to 'charge' due to 'private' protection level



// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  -> The `final` on `runOnce()` prevents subclasses from overriding the method  and provides a micro-optimisation by using static dispatch instead of vtable dispatch.
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    func performTask() -> Int { 0 }

    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}
// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }

    func weldSeam() -> String {
        "\(id) welded a seam shut."
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }

    override var statusLine: String {
        super.statusLine + " [scanner]"
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:        return nil
    }
}

var fleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("Unknown drone kind, skipping record: \(record.kind):\(record.id)")
    }
}

print("Level 2: fleet built with \(fleet.count) drones")


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var totalWork = 0
    for _ in 0..<rounds {
        for drone in fleet {
            totalWork += drone.runOnce()
        }
    }
    return totalWork
}

let A = runShift(fleet, rounds: 3)

print("Level 3: shift complete")
for drone in fleet {
    print(drone.statusLine)
}

var totalChargeLeft = 0
var droneCountReady = 0
for drone in fleet {
    totalChargeLeft += drone.cell.level()
    if drone.cell.level() >= drone.powerCost {
        droneCountReady += 1
    }
}
let B = totalChargeLeft
let C = droneCountReady

print("A (work units) = \(A), B (total charge left) = \(B), C (drones ready for one more task) = \(C)")


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { Drone.statusCode(forLevel: cell.level()) }
    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}
// Why does Drone implement recharge(by:) without `mutating`?  -> because `Drone` is a class. Unlike structures, classes have reference semantics, so their methods can modify their properties without the `mutating` keyword. Swift allows a class to implement protocols with `mutating` methods using a standard method, as these refer to a mutable object by default.

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }
    var statusCode: Int { SensorModule.statusCode(forLevel: chargeLevel) }

    mutating func recharge(by amount: Int) {
        guard amount > 0 else { return }
        chargeLevel = min(chargeLevel + amount, 100)
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(id: record.id, chargeLevel: record.charge))
}

// 4.3
// Why could [Drone] never have held the sensors?  ->  [Drone] array is strictly typed and can only hold instances of Drone and its subclasses. Sensor is a struct that doesn't inherit from the Drone class, so Swift does not allow it to be placed in such an array

func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var lines: [String] = []
    for component in components {
        lines.append(component.diagnose())
    }
    return lines.joined(separator: "\n")
}

// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + the single home of the Health Rule
extension Diagnosable {
    static func statusCode(forLevel level: Int) -> Int {
        if level < 20 { return 2 }
        if level < 50 { return 1 }
        return 0
    }

    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }
}

// 5.2 · the beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { LegacyBeacon.statusCode(forLevel: signalStrength) }

    func diagnose() -> String {
        "LEGACY HARDWARE \(name): signal \(signalStrength)% (code \(statusCode))"
    }
}

var diagnosables: [Diagnosable] = []
for drone in fleet { diagnosables.append(drone) }
for sensor in sensors { diagnosables.append(sensor) }
diagnosables.append(beacon)

print("Level 5: diagnostics report")
print(diagnosticsReport(diagnosables))

var totalStatusCode = 0
for component in diagnosables {
    totalStatusCode += component.statusCode
}
let D = totalStatusCode
print("D (sum of status codes) = \(D)")


// 5.3
extension Int {
    var powerBar: String {
        let clamped = min(max(self, 0), 100)
        let filled = clamped / 10
        var bar = ""
        for _ in 0..<filled { bar += "#" }
        for _ in filled..<10 { bar += "." }
        return bar
    }
}

print("powerBar demo:", 42.powerBar, (-5).powerBar, 250.powerBar)


// MARK: Level 6 · Incident Reports
// Two of these do not compile. Two compile and lie.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
Report 1:
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}

Expected: a new drone subclass that produces 30 work units per task.
Actual:   does NOT compile. `performTask` already exists on Drone, and Swift
          requires the `override` keyword whenever a subclass redeclares a
          member that exists on its superclass — without it, the compiler
          assumes you're trying to declare something brand new, and that
          conflicts with the inherited member, which is a compile error.
Rule:     overriding ANY non-final inherited member (method, computed
          property, subscript) requires the `override` keyword — this isn't
          optional styling, it is the compiler's way of forcing you to say
          "yes, I mean to replace the inherited one", which also prevents
          silent, accidental overrides.
Fix:
    class PatchDrone: Drone {
        override func performTask() -> Int {
            return 30
        }
    }
*/
final class PatchDrone: Drone {
    override func performTask() -> Int {
        return 30
    }
}

/*
Report 2:
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}

Expected: a stronger welder that always produces 999 work units per call,
          regardless of charge.
Actual:   does NOT compile, for two independent reasons, either one of
          which is already fatal on its own:
          1. WelderDrone is declared `final class` — Swift forbids
             inheriting from a final class at all, so
             `class HeavyWelder: WelderDrone` is rejected immediately.
          2. Even if WelderDrone were not final, `runOnce()` is declared
             `final` on Drone, so it could never be overridden by any
             subclass at any depth.
Rule:     `final` on a class blocks subclassing entirely; `final` on a
          member blocks overriding that one member in every subclass, no
          matter how far down the hierarchy. Both are doing their job here
          exactly as intended — WelderDrone and runOnce() were deliberately
          sealed so nobody could special-case the shift ritual.
Fix:      there isn't a "fix" that keeps the original intent — the whole
          point of making these final was to prevent exactly this. If a
          stronger welder were genuinely needed, it would have to change
          performTask()/powerCost on a NEW, non-final WelderDrone design
          from the start, not bypass runOnce() after the fact.
*/

/*
Report 3:
let fleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = fleet[0]
print(first.weldSeam())

Expected: prints a welded-seam message.
Actual:   does NOT compile. `fleet`'s declared element type is `Drone`, so
          the compiler only lets you call members that EVERY Drone has.
          weldSeam() only exists on WelderDrone, a more specific type the
          compiler can't assume `first` still is, just from its static type.
Rule:     static typing — members available on a value are limited to its
          declared (compile-time) type, not whatever it happens to be at
          runtime. To reach a subclass-only member you must downcast first.
Fix:      use a conditional cast, which is why it returns an OPTIONAL — the
          cast can fail at runtime (the actual object might be a
          ScannerDrone or CargoDrone instead), so `as?` hands back
          `WelderDrone?` rather than crashing on a bad guess.
*/
print("Report 3 (fixed)")
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
if let welder = first as? WelderDrone {
    print(welder.weldSeam())
} else {
    print("first is not actually a WelderDrone")
}

/*
Report 4:
protocol Labelled {
    var componentID: String { get }
}
extension Labelled {
    func label() -> String { "generic component" }
}
struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}
let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())

Expected: "thruster T-1" (Thruster's own label()).
Actual:   compiles fine, but prints "generic component" instead.
Rule:     `label()` is NOT part of the Labelled protocol's requirements —
          it only exists in the protocol extension. A method that isn't a
          protocol requirement is resolved by STATIC dispatch: the
          compiler looks at the STATIC type of the array element
          (Labelled, the protocol), finds label() only in the extension,
          and calls that — it never even looks at Thruster's own version.
          If `label()` WERE listed in the protocol's requirements, calls
          would go through the protocol's witness table instead, which
          picks the conforming type's own implementation at runtime
          (dynamic dispatch) — that's the one-line fix.
Fix:      add `func label() -> String` to the protocol itself.
*/
protocol LabelledBroken {
    var componentID: String { get }
}
extension LabelledBroken {
    func label() -> String { "generic component" }
}
struct ThrusterBroken: LabelledBroken {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

protocol LabelledFixed {
    var componentID: String { get }
    func label() -> String     // <- the one line that changes the output
}
extension LabelledFixed {
    func label() -> String { "generic component" }
}
struct ThrusterFixed: LabelledFixed {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let partsBroken: [LabelledBroken] = [ThrusterBroken(componentID: "T-1")]
print("Report 4 (still broken):", partsBroken[0].label())   // "generic component"

let partsFixed: [LabelledFixed] = [ThrusterFixed(componentID: "T-1")]
print("Report 4 (fixed):", partsFixed[0].label())            // "thruster T-1"


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it? -> Classes are reference types. They inherently hold a constant reference to an object in memory and modify the internal state without altering the reference itself, so they simply do not require the `mutating` keyword. Structures are value types; when a property is changed, the entire value changes, which is why Swift requires such methods to be explicitly marked with the `mutating` keyword.
 

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:
 Inheritance is capable of: passing on state  and a ready-made implementation of logic from a parent class to its child classes.
 Protocols are capable of: unifying completely different structures, classes and enumerations into a single type without binding them to a rigid hierarchy (polymorphism via interfaces rather than inheritance).
 
 3. What does `final` prevent, and what did it protect in runOnce()?
 `final` prevents subclasses from overriding the method or inheriting the class in its entirety. And in `runOnce()` the actual algorithm (Template Method pattern) was protected. ensuring that any drone must always consume energy via `cell.spend(powerCost)` strictly before executing the `performTask()` method, and that no one can hack or bypass this logic in subclasses.

 4. In Report 4, why did the protocol extension's method win?
 Methods declared and implemented directly within a protocol extension trigger static dispatch. The compiler takes the variable’s type at the time of the call as its reference, rather than the actual type of the object inside, which is why the implementation from the extension is always called.
 

*/

