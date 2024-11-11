import SwiftUI
import Charts

struct SessionDetailView: View {
    var session: WorkoutSession

    var body: some View {
        VStack {
            Text("Workout Session Details")
                .font(.title)
                .padding()

            Text("Date: \(session.date.formatted(date: .abbreviated, time: .shortened))")
                .padding()
            
            Text("Gray figures are averages:")
                .foregroundStyle(.gray)

            // Display other session details
            HStack {
                VStack(alignment: .leading) {
                    Text("Sets: \(session.sets)")
                    Text("Reps: \(session.reps)")
                        .foregroundStyle(.gray)
                    Text("Recovery Time: \(session.recoveryTime) sec")
                        .foregroundStyle(.gray)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("Strain Per Set: \(session.strainPerSet)")
                        .foregroundStyle(.gray)
                    Text("Strain Per Rep: \(session.strainPerRep)")
                        .foregroundStyle(.gray)
                    Text("Max Strain: \(session.maxStrain)")
                }
            }
            .padding()

            // Display the chart
            Chart(session.collectedValues) { dataPoint in
                LineMark(
                    x: .value("Time", Double(dataPoint.time) / 1000),
                    y: .value("Strain", dataPoint.strain)
                )
            }
            .chartYScale(domain: 400 ... 1100)
            .frame(height: 300)
            .chartXAxisLabel("Time Elapsed (seconds)")
            .chartYAxisLabel("Strain")
            .padding()

            Spacer()
        }
    }
}
