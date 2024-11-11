import SwiftUI

struct HomeView: View {
    @ObservedObject var sessionStore: WorkoutSessionStore
    @Binding var selectedTab: Tab
    
    @State private var showingDeleteConfirmation = false
    @State private var indexSetToDelete: IndexSet?
    
    var body: some View {
        NavigationView {
            VStack {
                if sessionStore.sessions.isEmpty {
                    VStack {
                        Spacer()
                        Text("No past sessions found.")
                            .foregroundColor(.secondary)
                            .font(.headline)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(sessionStore.sessions) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                VStack(alignment: .leading) {
                                    Text("Session on \(session.date.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.headline)
                                    Text("Sets: \(session.sets), Reps: \(session.reps)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        // Enable swipe-to-delete
                        .onDelete { offsets in
                            indexSetToDelete = offsets
                            showingDeleteConfirmation = true
                        }
                    }
                    .listStyle(PlainListStyle())
                }

                Spacer()

                Button(action: {
                    // Switch to the New Session tab
                    selectedTab = .newSession
                }) {
                    Text("Start New Session")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .bold()
                }
                .padding()
            }
            .navigationTitle("Past Sessions")
            .navigationBarItems(trailing: EditButton()) // Add Edit Button for batch deletion
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("Delete Session"),
                    message: Text("Are you sure you want to delete this session?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let offsets = indexSetToDelete {
                            sessionStore.deleteSessions(at: offsets)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}
