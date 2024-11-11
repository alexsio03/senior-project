# StrainTracker

**StrainTracker** is a SwiftUI-based iOS application developed as a senior project, designed to monitor and analyze workout sessions in real-time. Leveraging Bluetooth connectivity, StrainTracker connects to external sensors to measure strain, count reps and sets, and provide insightful metrics to optimize training performance.

## Features

- **Real-Time Strain Monitoring:** Connects to Bluetooth-enabled strain sensors to capture real-time data during workouts.
- **Automatic Rep and Set Counting:** Accurately counts reps and sets based on sensor data with intelligent delay mechanisms to prevent false counts.
- **Comprehensive Metrics:** Tracks and displays key workout metrics such as strain per set, strain per rep, maximum strain, and recovery time.
- **Interactive Charts:** Visualize workout performance over time with dynamic, real-time updating charts.
- **Session Management:** Start, pause, and end workout sessions with ease, ensuring accurate data collection and storage.
- **User-Friendly Interface:** Intuitive SwiftUI design for seamless navigation and interaction.

## Demo

![StrainTracker Screenshot](path_to_screenshot_image)

*Figure 1: StrainTracker Dashboard showcasing real-time strain data and metrics.*

## Technologies Used

- **Swift 5.7**
- **SwiftUI**
- **CoreBluetooth**
- **Charts**
- **Combine**

## Architecture

StrainTracker follows the MVVM (Model-View-ViewModel) architecture pattern to ensure a clean separation of concerns, making the application scalable and maintainable.

- **Model:** Defines data structures such as `StrainTime` and `WorkoutSession` that represent the strain data and workout sessions respectively.
- **ViewModel:** The `BluetoothService` class acts as the ViewModel, handling Bluetooth connectivity, data processing, and business logic.
- **View:** The `ContentView` utilizes SwiftUI to present the user interface, observing the ViewModel's published properties to reflect real-time data.

## Screenshots

![StrainTracker Dashboard](path_to_dashboard_screenshot)

*Figure 2: Dashboard displaying strain metrics and real-time chart.*

![StrainTracker Chart](path_to_chart_screenshot)

*Figure 3: Interactive chart visualizing strain over time.*

## Conclusion

StrainTracker provides a comprehensive solution for monitoring and analyzing workout performance in real-time. By leveraging Bluetooth connectivity and robust data processing, it delivers valuable insights to help users optimize their training regimens effectively.
