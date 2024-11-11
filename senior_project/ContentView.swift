import SwiftUI
import Charts

struct ContentView: View {
    @StateObject var service = BluetoothService()
    @ObservedObject var sessionStore: WorkoutSessionStore
    @EnvironmentObject var appState: AppState

    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            VStack {
                Button(action: startScan) {
                                    Text(service.peripheralStatus.rawValue.capitalized)
                                        .font(.title)
                                        .padding(.top)
                                }

                Text("\(service.sensorValue)")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .padding(.bottom)

                Spacer()

                // Real-Time Strain Chart
                Chart(service.collectedValues) { dataPoint in
                    LineMark(
                        x: .value("Time", Double(dataPoint.time) / 1000), // Convert to seconds
                        y: .value("Strain", dataPoint.strain)
                    )
                }
                .chartYScale(domain: 400 ... 1100) // Adjust domain as needed
                .frame(height: 300)
                .chartXAxisLabel("Time Elapsed (seconds)")
                .chartYAxisLabel("Strain")
                .padding()

                Spacer()

                // Dynamic Metrics Display
                HStack(spacing: 50) {
                    VStack(spacing: 25) {
                        VStack {
                            Text("Sets")
                                .bold()
                            Text("\(service.sets)")
                        }
                        VStack {
                            Text("Reps")
                                .bold()
                            Text("\(service.reps)")
                        }
                        VStack {
                            Text("Recovery Time")
                                .bold()
                            Text("\(service.recoveryTime) sec")
                        }
                    }
                    VStack(spacing: 25) {
                        VStack {
                            Text("Strain Per Set")
                                .bold()
                            Text("\(service.strainPerSet)")
                        }
                        VStack {
                            Text("Strain Per Rep")
                                .bold()
                            Text("\(service.strainPerRep)")
                        }
                        VStack {
                            Text("Max Strain")
                                .bold()
                            Text("\(service.maxStrain)")
                        }
                    }
                }
                .padding()

                Spacer()

                // Action Buttons
                HStack(spacing: 60) {
                    Button(action: endSession) {
                        Text("End Session")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .bold()

                    Button(action: service.togglePause) {
                        Text(service.isPaused ? "Start Set" : "End Set")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(service.isPaused ? Color.green.opacity(0.7) : Color.orange.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .bold()
                }
                .padding([.leading, .trailing, .bottom])
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Session Ended"),
                message: Text("Your workout session has been saved."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // **End Session Function**
    func endSession() {
        // End the session
        service.endSession()
        
        // Save the session if available
        if let session = service.currentSession {
            sessionStore.addSession(session)
        }
        
        // Reset all data
        service.resetAll()
        
        // Navigate back to Home tab
        appState.selectedTab = .home
        
        // Show confirmation alert
        showingAlert = true
    }
    
    func startScan() {
        service.scanForPeripherals()
    }
}

