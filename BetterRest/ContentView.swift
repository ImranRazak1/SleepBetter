//
//  ContentView.swift
//  BetterRest
//
//  Created by Imran razak on 09/12/2021.
//
import CoreML
import SwiftUI


struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeIntake = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    
    
    var body: some View {
        NavigationView {
            Form {
                Section{
                Text("When do you want to wake up?")
                    .font(.headline)
                
                DatePicker("Please Enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute )
                    .labelsHidden()
                }
                Section{
                Text("How long do you want to sleep?")
                    .font(.headline)
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Text("How much coffee have you had?")
                    .font(.headline)
                
                Stepper(coffeeIntake == 1 ? "1 Cup" : "\(coffeeIntake) cups", value: $coffeeIntake, in: 1...20 )
            }
            .navigationTitle("Sleep Better")
            .toolbar{
                Button("Caluclate Sleep", action: calculateBedtime )
            .alert(alertTitle, isPresented: $showingAlert) {
                        Button("OK") { }
                    } message: {
                        Text(alertMessage)
                    }
            }
        }
    }
    
    func calculateBedtime() {
        
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalulcator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeIntake))
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "We reccomend you go to bed at..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry,soemthing has gone wrong in calculating your bedtime."
        }
        
        showingAlert = true
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
