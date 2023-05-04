//
//  ContentView.swift
//  BetterRest
//
//  Created by Boris R on 03/05/23.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State  private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State  private var alertMessage = ""
    @State private var showingAlert = false
    
    @State private var showingNewView = false
    
    
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        
        NavigationView{
            Form{
                Section {
                    //                    Text("")
                    //                        .font(.headline)
                    DatePicker("Place enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    
                    // .labelsHidden()
                } header: {
                    Text("When do you want to wake up?")
                }
                Section {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 1)
                } header: {
                    Text("Desired amount of sleep")
                }
                Section{
                    Stepper(coffeeAmount == 1 ? "☕️ 1 cup" : "☕️ \(coffeeAmount) cups ", value: $coffeeAmount, in: 1...20)
                } header: {
                    Text("Daly coffee intake")
                    
                }
                
            }
            
                .navigationTitle("BetterRest")
                .toolbar{
                    Button("Calcular", action: calculateBedtime)
//                    Button("New VIew"){
//                        calculateBedtime()
//                        showingNewView = true
//                    }
                    .bold()
                }
                
                .alert(alertTitle, isPresented: $showingAlert) {
                    Button("OK") { }
                } message: {
                    Text(alertMessage)
                }
//                .sheet(isPresented: $showingNewView){
//                    Result(Texto: $alertMessage)
//                }
        }

    }
    
    func calculateBedtime (){
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0 ) * 60 * 60
            let minute = (components.minute ?? 0 ) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is.."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Erro"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        showingAlert = true
    }
    func back () {
        showingAlert = false
    }
}

struct Result: View {
    @Binding var Texto: String
    
    var body: some View{
        
        
        VStack{
            Text("Your ideal bedtime is..\(Texto)")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
