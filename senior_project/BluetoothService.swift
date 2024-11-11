import Foundation
import CoreBluetooth

enum ConnectionStatus: String {
    case connected
    case disconnected
    case scanning
    case connecting
    case error
}

let sensorService: CBUUID = CBUUID(string: "180A")
let sensorCharacteristic: CBUUID = CBUUID(string: "2A57")

class BluetoothService: NSObject, ObservableObject {
    private var centralManager: CBCentralManager!
    
    var startCheck: Bool = false
    var repLock: Bool = true
    var timerLock: Bool = true
    var sensorPeripheral: CBPeripheral?
    @Published var currentTime: Int = 0
    @Published var peripheralStatus: ConnectionStatus = .disconnected
    @Published var sensorValue: Int = 0
    @Published var collectedValues: [StrainTime] = []
    
    // Dynamic Variables
    @Published var sets: Int = 0
    @Published var reps: Int = 0
    @Published var recoveryTime: Int = 0
    @Published var strainPerSet: Int = 0
    @Published var strainPerRep: Int = 0
    @Published var maxStrain: Int = 0
    
    // Pause Control
    @Published var isPaused: Bool = true
    
    @Published var currentSession: WorkoutSession?
    
    // Temporary Variables for Calculation
    private var currentSetStrain: Int = 0
    private var currentRepStrain: Int = 0
    private var repCount: Int = 0
    private var setCount: Int = 0
    private var lastResetTime: Int = 0
    private var pauseTimer: Timer?
    private var repTimer: Timer?
    private var repTimeCount: Int = 0
    private var totalReps: Int = 0
    private var totalRepStrain: Int = 0
    private var totalRecovTime: Int = 0
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scanForPeripherals() {
        sensorPeripheral = nil
        peripheralStatus = .scanning
        centralManager.scanForPeripherals(withServices: [sensorService])
        print("Started scanning for peripherals with service UUID: \(sensorService.uuidString)")
    }
    
    func resetAll() {
        DispatchQueue.main.async {
            self.sets = 0
            self.reps = 0
            self.recoveryTime = 0
            self.strainPerRep = 0
            self.maxStrain = 0
            self.collectedValues.removeAll()
            self.currentTime = 0
            self.currentSetStrain = 0
            self.currentRepStrain = 0
            self.repCount = 0
            self.setCount = 0
            self.lastResetTime = 0
            self.stopPauseTimer() // Ensure timer is stopped
            print("All dynamic variables have been reset.")
        }
    }
    
    private func startPauseTimer() {
        pauseTimer?.invalidate()
        
        pauseTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.recoveryTime += 1
        }
        
        print("Pause timer started.")
    }

    private func stopPauseTimer() {
        pauseTimer?.invalidate()
        pauseTimer = nil
        self.totalRecovTime += self.recoveryTime
        self.recoveryTime = 0
        print("Pause timer stopped.")
    }
    
    // Toggle Pause State
    func togglePause() {
        DispatchQueue.main.async {
                self.isPaused.toggle()
                self.startCheck = !self.startCheck
                
                if self.isPaused {
                    self.startPauseTimer()
                } else {
                    self.stopPauseTimer()
                    self.setCount += 1
                    self.sets = self.setCount
                    self.collectedValues.removeAll()
                    self.currentTime = 0
                    self.repCount = 0
                    self.reps = 0
                    self.strainPerRep = 0
                    self.currentRepStrain = 0
                    print("Data collection is now resumed.")
                }
                
                print("Data collection is now \(self.isPaused ? "paused" : "resumed").")
            }
    }
    
    func endSession() {
        // Create a WorkoutSession from the current data
        let session = WorkoutSession(
            date: Date(),
            sets: self.sets,
            reps: self.totalReps / self.sets,
            recoveryTime: self.totalRecovTime / self.sets,
            strainPerSet: self.strainPerSet,
            strainPerRep: self.strainPerRep,
            maxStrain: self.maxStrain,
            collectedValues: self.collectedValues
        )
        
        self.startCheck = false
        
        self.currentSession = session
        print("Session ended and saved.")
        
        // Reset all variables for the next session
        resetAll()
    }
}

extension BluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Central Manager state: Powered On")
            scanForPeripherals()
        case .unsupported:
            peripheralStatus = .error
            print("Central Manager state: Unsupported")
        case .unauthorized:
            peripheralStatus = .error
            print("Central Manager state: Unauthorized")
        case .poweredOff:
            peripheralStatus = .error
            print("Central Manager state: Powered Off")
        case .resetting:
            peripheralStatus = .error
            print("Central Manager state: Resetting")
        case .unknown:
            peripheralStatus = .error
            print("Central Manager state: Unknown")
        @unknown default:
            peripheralStatus = .error
            print("Central Manager state: A new state is available that is not handled")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Discovered peripheral: \(peripheral.name ?? "No Name") at RSSI: \(RSSI)")
        
        // Prevent multiple connections
        if sensorPeripheral != peripheral {
            sensorPeripheral = peripheral
            centralManager.connect(sensorPeripheral!, options: nil)
            peripheralStatus = .connecting
            print("Attempting to connect to peripheral: \(peripheral.name ?? "No Name")")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheralStatus = .connected
        print("Successfully connected to peripheral: \(peripheral.name ?? "No Name")")
        peripheral.delegate = self
        peripheral.discoverServices([sensorService])
        centralManager.stopScan()
        print("Stopped scanning for peripherals.")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        peripheralStatus = .disconnected
        print("Disconnected from peripheral: \(peripheral.name ?? "No Name")")
        // Optionally, attempt to reconnect
        // scanForPeripherals()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        peripheralStatus = .error
        print("Failed to connect to peripheral: \(peripheral.name ?? "No Name"). Error: \(error?.localizedDescription ?? "No error information")")
    }
}

extension BluetoothService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            peripheralStatus = .error
            return
        }
        
        guard let services = peripheral.services else {
            print("No services found on peripheral: \(peripheral.name ?? "No Name")")
            return
        }
        
        for service in services {
            if service.uuid == sensorService {
                print("Found service with UUID: \(service.uuid.uuidString)")
                peripheral.discoverCharacteristics([sensorCharacteristic], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            peripheralStatus = .error
            return
        }
        
        guard let characteristics = service.characteristics else {
            print("No characteristics found for service: \(service.uuid.uuidString)")
            return
        }
        
        for characteristic in characteristics {
            if characteristic.uuid == sensorCharacteristic {
                print("Found characteristic with UUID: \(characteristic.uuid.uuidString)")
                peripheral.setNotifyValue(true, for: characteristic)
                print("Subscribed to characteristic: \(characteristic.uuid.uuidString)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error = error {
            print("Error changing notification state for characteristic \(characteristic.uuid.uuidString): \(error.localizedDescription)")
            peripheralStatus = .error
            return
        }
        
        if characteristic.isNotifying {
            print("Notification began on characteristic: \(characteristic.uuid.uuidString)")
        } else {
            print("Notification stopped on characteristic: \(characteristic.uuid.uuidString)")
            peripheralStatus = .disconnected
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if (characteristic.uuid == sensorCharacteristic && startCheck == true) {
            guard let data = characteristic.value else {
                print("No data received for characteristic: \(characteristic.uuid.uuidString)")
                return
            }
            
            // Ensure that the data length is a multiple of 2 bytes (size of UInt16)
            guard data.count % 2 == 0 else {
                print("Received data length (\(data.count) bytes) is not a multiple of 2 bytes.")
                return
            }
            
            // Parse the data as an array of UInt16
            let sampleCount = data.count / 2
            var samples = [UInt16]()
            for i in 0..<sampleCount {
                let sampleData = data.subdata(in: i*2..<(i+1)*2)
                let sample = sampleData.withUnsafeBytes { $0.load(as: UInt16.self) }.littleEndian
                samples.append(sample)
            }
            
            DispatchQueue.main.async {
                for sample in samples {
                    if (sample != 0) {
                        let sensorValue = Int(sample)
                        //print("Parsed sensor value: \(sensorValue)")
                        self.sensorValue = sensorValue
                        if self.sensorValue > self.maxStrain {
                            self.maxStrain = self.sensorValue
                        }
                        
                        if !self.isPaused {
                            // Update collectedValues every 100ms
                            if (self.currentTime % 100 == 0) {
                                let newStrain = self.sensorValue
                                let newStrainTime = StrainTime(time: self.currentTime, strain: newStrain)
                                if self.sensorValue >= 400 {
                                    self.collectedValues.append(newStrainTime)
                                } else {
                                    self.collectedValues.append(StrainTime(time: self.currentTime, strain: 400))
                                }
                            }
                            self.currentTime += 50
                            
                            // Increment reps based on sensor value threshold
                            if (self.sensorValue >= 625 && self.repLock) { // Threshold for a "rep"
                                self.repLock = false
                                self.repCount += 1
                                self.totalReps += 1
                                self.reps = self.repCount
                                self.currentRepStrain += self.sensorValue
                                self.strainPerRep = self.currentRepStrain / self.repCount
                                self.totalRepStrain = self.totalRepStrain + self.sensorValue
                                self.strainPerSet = (self.totalRepStrain / self.totalReps)
                                print("Incremented reps: \(self.reps), Strain per rep: \(self.strainPerRep)")
                            }
                            
                            if (!self.repLock && self.timerLock) {
                                self.timerLock = false
                                self.repTimer?.invalidate()
                                self.repTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                                    guard let self = self else { return }
                                    self.repLock = true
                                    self.timerLock = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
