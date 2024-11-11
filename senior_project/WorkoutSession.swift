import Foundation

struct StrainTime: Identifiable, Codable {
    var id = UUID()
    var time: Int
    var strain: Int
}

struct WorkoutSession: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var sets: Int
    var reps: Int
    var recoveryTime: Int
    var strainPerSet: Int
    var strainPerRep: Int
    var maxStrain: Int
    var collectedValues: [StrainTime]
}
