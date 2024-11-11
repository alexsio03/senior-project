import Foundation

class WorkoutSessionStore: ObservableObject {
    @Published var sessions: [WorkoutSession] = []

    private let sessionsKey = "workoutSessions"

    init() {
        loadSessions()
    }

    func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decodedSessions = try? JSONDecoder().decode([WorkoutSession].self, from: data) {
            self.sessions = decodedSessions.sorted { $0.date > $1.date }
        }
    }

    func saveSessions() {
        if let encodedData = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encodedData, forKey: sessionsKey)
        }
    }

    func addSession(_ session: WorkoutSession) {
        sessions.append(session)
        sessions.sort { $0.date > $1.date } // Ensure descending order
        saveSessions()
    }
    
    func deleteSessions(at offsets: IndexSet) {
        sessions.remove(atOffsets: offsets)
        saveSessions()
    }
}
