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

[Watch the Demo Video](youtube_link_here)

## Technologies Used

- **Hardware:**
  - **Arduino MKR WiFi 1010:** Acts as the central microcontroller, managing sensor data collection and Bluetooth communication.
  - **EMG Monitor Chip and Sensors:** Detect muscle activity to measure strain during workouts.
  - **BreadBoard and Wires:** Facilitate connections between the Arduino and sensors for prototyping and testing.

- **Software:**
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

### Hardware Integration

- **Arduino MKR WiFi 1010:** The Arduino serves as the bridge between the EMG sensors and the iOS application. It collects raw sensor data, processes it to determine strain levels, and transmits this information via Bluetooth to the StrainTracker app.
  
- **EMG Monitor Chip and Sensors:** These components detect electrical activity produced by muscles during exercise. The data captured by the sensors is sent to the Arduino for processing.

### Bluetooth Connectivity

- **CoreBluetooth Framework:** StrainTracker utilizes Apple's CoreBluetooth framework to manage Bluetooth Low Energy (BLE) communications. The `BluetoothService` class handles scanning for peripherals, establishing connections, and receiving data from the Arduino.
  
- **Data Transmission:** The Arduino is programmed to send strain data over BLE using a specific service and characteristic UUID. StrainTracker listens to these characteristics, parses the incoming data, and updates the UI accordingly.

## Screenshots

![StrainTracker Dashboard](path_to_dashboard_screenshot)

*Figure 1: Dashboard displaying strain metrics and real-time chart.*

![StrainTracker Chart](path_to_chart_screenshot)

*Figure 2: Interactive chart visualizing strain over time.*

## Conclusion

StrainTracker provides a comprehensive solution for monitoring and analyzing workout performance in real-time. By integrating Arduino-based hardware with robust Bluetooth connectivity and efficient data processing, it delivers valuable insights to help users optimize their training regimens effectively.
