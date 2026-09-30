// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================

// MARK: - =================== YOUR SOLUTION ===================

// MARK: Level 1 · Decoding Telemetry
// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let (left, right) = splitOnce(raw, by: ":"),
          !left.isEmpty,
          let value = Int(right),
          value >= 0 || left == "TEMP" else {
        return nil
    }
    return (sensor: left, value: value)
}
 
print("1.1 parseReading")
print(parseReading("O2:87") as Any)     // (sensor: "O2", value: 87)
print(parseReading("TEMP:-12") as Any)  // (sensor: "TEMP", value: -12)
print(parseReading("RAD:-1") as Any)    // nil
print(parseReading(":55") as Any)       // nil

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    return (valid, invalidCount)
}
 
let logResult = parseLog(rawLog)
let validReadings = logResult.valid
print("1.2 parseLog")
print("Valid readings: \(validReadings.count), invalid: \(logResult.invalidCount)")
 
let A = logResult.invalidCount

// MARK: Level 2 · Analysis
// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}
 
func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}
 
let o2Readings = select(validReadings) { $0.sensor == "O2" }
let o2Values = values(of: o2Readings)
print("2.1 select/values")
print("O2 readings: \(o2Readings)")
print("O2 values: \(o2Values)")

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }
    var minValue = first
    var maxValue = first
    var sum = 0
    for value in values {
        if value < minValue { minValue = value }
        if value > maxValue { maxValue = value }
        sum += value
    }
    let average = Double(sum) / Double(values.count)
    return (minValue, maxValue, average)
}
 
func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}
 
print("2.2 stats")
print(stats(3, 8, 1) as Any)   // (min: 1, max: 8, average: 4.0)
print(stats() as Any)          // nil
 
let B: Int
if let o2Stats = stats(of: o2Values) {
    B = Int(o2Stats.average)
} else {
    B = 0
}
print("B (average O2, as Int) = \(B)")

// 2.3 · The Closure Ladder (5 sorts, then compare results in code)
let sortedLadder1 = validReadings.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})
let sortedLadder2 = validReadings.sorted(by: { (a: Reading, b: Reading) in a.value > b.value })
let sortedLadder3 = validReadings.sorted(by: { a, b in a.value > b.value })
let sortedLadder4 = validReadings.sorted(by: { $0.value > $1.value })
let sortedLadder5 = validReadings.sorted { $0.value > $1.value }
 
let ladderMatches =
    values(of: sortedLadder1) == values(of: sortedLadder2) &&
    values(of: sortedLadder2) == values(of: sortedLadder3) &&
    values(of: sortedLadder3) == values(of: sortedLadder4) &&
    values(of: sortedLadder4) == values(of: sortedLadder5)
 
print("2.3 closure ladder")
print("All five sorts match: \(ladderMatches)")

// MARK: Level 3 · Temperature Stabilization
// 3.1
func heatUp(_ t: Int) -> Int { t + 5 }
func coolDown(_ t: Int) -> Int { t - 3 }
func hold(_ t: Int) -> Int { t }
 
func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    } else {
        return hold
    }
}

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temp = start
    var steps = 0
    while (temp < 18 || temp > 24) && steps < maxSteps {
        let protocolFn = chooseProtocol(for: temp)
        temp = protocolFn(temp)
        steps += 1
    }
    let isStable = temp >= 18 && temp <= 24
    return (temp, steps, isStable)
}
 
print("3.2 runUntilStable")
print(runUntilStable(from: 31))                  // (finalTemp: 22, steps: 3, isStable: true)
print(runUntilStable(from: -100, maxSteps: 5))    // (finalTemp: -75, steps: 5, isStable: false)
 
let tempReadings = select(validReadings) { $0.sensor == "TEMP" }
let tempValues = values(of: tempReadings)
 
let C: Int
if let tempStats = stats(of: tempValues) {
    C = runUntilStable(from: tempStats.min).steps
} else {
    C = 0
}
print("C(steps to stabilize lowest logged temp) = \(C)")

// MARK: Level 4 · The Crew
// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    return member.module?.oxygenTank?.level
}

// 4.2
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let location = member.module?.name ?? "open space"
        return "\(member.name): no data (\(location))"
    }
    let condition = level < 20 ? "CRITICAL" : "OK"
    return "\(member.name): \(level)% \(condition)"
}
 
print("4.2 status")
for member in crew {
    print(status(of: member))
}

// 4.3
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    let available = min(amount, source)
    let capacity = 100 - target
    let actualTransfer = min(available, capacity)
    guard actualTransfer > 0 else { return 0 }
    source -= actualTransfer
    target += actualTransfer
    return actualTransfer
}
 
let D: Int
if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    let transferred = transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
    print("4.3 transferOxygen")
    print("Transferred \(transferred) units from Lab to Hab")
    print("Lab now: \(labTank.level)%, Hab now: \(habTank.level)%")
    D = habTank.level
} else {
    D = 0
}

// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }
    let sortedFound = found.sorted { $0.priority < $1.priority }
    var names: [String] = []
    for member in sortedFound {
        names.append(member.name)
    }
    return names
}
 
print("4.4 evacuationOrder")
print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))

// MARK: Level 5 · The Saboteur's Logbook
/*
func reportOxygen(for member: CrewMember) -> String {
    let tank = member.module!.oxygenTank!
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String {
    var result: String?
    for member in crew {
        if oxygenLevel(of: member)! < 20 {
            result = member.name
        }
    }
    return result!
}
*/
/* Problems found:
1. `member.module!` crashes for any crew member with no module. member.module is nil there, so this force unwrap is a guaranteed crash for that data.

2. `.oxygenTank!` crashes whenever the member's module has no tank. Even if module! survives, this second force unwrap can still blow up.

3. `oxygenLevel(of: member)!` crashes whenever oxygenLevel(of:) returns nil, which happens for exactly the same reasons as above — Nurlan and Dana both crash this line.

4. Logic bug: the loop never stops or "remembers only the first" match. It keeps overwriting `result` every time it finds another crew member under 20%. So despite being named `firstCritical`, the function actually returns the LAST critical crew member in the array, not the first. With the starter data there's only one critical member(Aigerim), so this bug is invisible until you have two or more.

 5. `result!` crashes if nobody in the crew is critical (result stays nil), even though "nobody is critical" is a perfectly normal, expected outcome.
 */

// Fixed version:
func reportOxygen(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data"
    }
    return "\(member.name): \(level)%"
}
 
func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}
 
print("Level 5: Saboteur's Logbook (fixed)")
for member in crew {
    print(reportOxygen(for: member))
}
print(firstCritical(in: crew) ?? "no one is critical")

// Test proving the logic bug is fixed, not just the crashes. With the starter crew only Aigerim is critical, so that alone can't show the "first vs. last" bug. Build a small crew with TWO critical members instead:
let engineBay = Module(name: "EngineBay", oxygenTank: Tank(level: 15)) // critical
let cargoBay  = Module(name: "CargoBay",  oxygenTank: Tank(level: 5))  // also critical
 
let testCrew = [
    CrewMember(name: "Alice", role: "Test", priority: 1, module: engineBay),
    CrewMember(name: "Bob",   role: "Test", priority: 2, module: cargoBay)
]
 
// The buggy original would loop through both, overwrite result each time, and end up returning "Bob" (the LAST critical member) even though it's called firstCritical. Our fixed version returns as soon as it finds the first match, so it must print "Alice".
print("Logic-bug test — firstCritical(testCrew):", firstCritical(in: testCrew) ?? "none")
// Expected output: Alice

// MARK: Finale · Launch Code
let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")

// MARK: Bonus
func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var alarmCount = 0
    return { level in
        if level < threshold {
            alarmCount += 1
            print("Alarm #\(alarmCount)")
            return true
        }
        return false
    }
}
 
print("Bonus task: makeAlarm")
let alarm = makeAlarm(threshold: 20)
print(alarm(12))  // Alarm #1 -> true
print(alarm(40))  // false
print(alarm(5))   // Alarm #2 -> true

/* Where does the alarm counter live after makeAlarm returns?
`alarmCount` is captured by reference by the closure returned from
    makeAlarm. Swift allocates that captured variable on the heap (in a
    small "capture box"), not on makeAlarm's stack frame, precisely because
    the closure needs to keep reading and mutating it after makeAlarm's own
    stack frame is gone. The closure holds a reference to that heap box, so
    the box (and the counter inside it) stays alive for exactly as long as
    the closure itself is alive — each call to makeAlarm(...) creates a
    brand-new, independent box/counter. */

// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
`guard let` requires the else branch to exit the current scope, and the unwrapped value stays available for the REST of the function, at the same indentation level. `if let` only makes the value available inside its own braces, and lets execution continue afterward whether or not the unwrap succeeded. Example where `if let` makes things noticeably worse. Several sequential unwraps needed before doing real work (a "pyramid of doom"):
       func summary(of member: CrewMember) -> String {
           if let module = member.module {
               if let tank = module.oxygenTank {
                   return "\(member.name): \(tank.level)% in \(module.name)"
               } else {
                   return "no tank"
               }
           } else {
               return "no module"
           }
       }

   vs. the flat guard version:
       func summary(of member: CrewMember) -> String {
           guard let module = member.module else { return "no module" }
           guard let tank = module.oxygenTank else { return "no tank" }
           return "\(member.name): \(tank.level)% in \(module.name)"
       }

 2. Why can't you pass [Int] to stats(_ values: Int...)?
A variadic parameter (Int...) is really sugar for "the caller writes any number of comma-separated Int literals/expressions at the call site" — Swift builds the [Int] array for you from those individual arguments. It is NOT the same thing as "accepts an [Int]". There's no automatic splatting/spreading of an existing array into variadic slots, so stats(someArray) where someArray: [Int] doesn't type-check — you'd have to call stats(of: someArray) (the array-taking overload) instead.

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?
Passing the same variable as two different `inout` parameters would give the function two simultaneous, overlapping mutable references to the exact same memory. Swift's exclusivity-of-access rule forbids this, because the function body could read/write through one parameter while the compiler-optimized assumptions about the other parameter's value are silently invalidated — a classic aliasing bug. This prevents exactly that class of "wrote through one alias, read stale data through the other" bugs.

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
oxygenLevel(of:) returns Int?, but "no data" is a String literal.
The `??` operator requires both sides to resolve to the SAME type (the right side must be the non-optional version of the left side's wrapped type, or another optional of it). Int? ?? String is a type mismatch, so it won't compile. You'd need something like: "\(oxygenLevel(of: dana) ?? 0)"  // or map the Int? to a String first

 5. Full type of chooseProtocol and how to read it:
chooseProtocol has type: (Int) -> ((Int) -> Int)
Read it inside-out / right-to-left: it's a function that takes an Int (the temperature) and returns another function; that returned function itself takes an Int and returns an Int (the actual heatUp/coolDown/hold protocol). So chooseProtocol is a "function factory" — you call it once with a temperature to decide WHICH protocol applies, and get back a reusable (Int) -> Int you can then apply to temperatures.
*/
