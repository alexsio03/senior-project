import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var selectedTab: Tab = .home
}
