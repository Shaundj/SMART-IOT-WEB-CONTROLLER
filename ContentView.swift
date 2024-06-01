//
//  ContentView.swift
//  Care
//
//  Created by Shaun David Jerome on 16/7/23.
//

import SwiftUI
import Firebase
import FirebaseDatabase
import UserNotifications
import MessageUI

struct ContentView: View {
    @State private var value: Double = 50 // Initial value
    var notification = Notify()
    @State private var showAlert = false
    @State private var hasShownAlertBefore = false
    let dailyQuotes = [
        "No water, no life. No blue, no green. -Sylvia Earle",
        "Life is like a fish tank. You got to keep cleaning the water.",
        "A beautiful plant is like having a friend around the house. — Beth Ditto",
        "Like people, plants respond to extra attention. — H. Peter Loewer",
        
        "I make the air you breathe. You owe me. – Plants",
        "A fish tank is just interactive television for cats.",
        "Fish are adorable and make people happy."
        ]
    var body: some View {
        ZStack {
            Color(.white)
                .ignoresSafeArea()
            
            VStack {
               // Image("Fish")
                 //   .resizable()
                   // .aspectRatio(contentMode: .fit)
                    //.padding()
                Text("Care")
                    .font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.black)
                
                Image("plants")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                   // .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                Text(dailyQuotes.randomElement() ?? "No quote available")
                           .font(.headline)
                           .padding()
                           .multilineTextAlignment(.center)
                           .foregroundColor(Color.black)
                           .padding()
                HStack{
                    Text("Select:").foregroundColor(Color.black)
                    NavigationLink("Plants", destination: PlantView())
                    NavigationLink("Aquarium", destination: FishView())
                }
                
            }.navigationTitle("Home")
            
        }.onAppear {
            if !hasShownAlertBefore {
                            showAlert = true
                            hasShownAlertBefore = true
                        }

        }
        .alert(isPresented: $showAlert) {
            
                    notification.createAlert()
                    //showAlert = false
                }
        
    }
}


struct PlantView: View {
    
    @State private var value: Double = 50 // Initial value
    @Environment(\.presentationMode) var presentationMode
    @State private var data: Int = 0
    @State var result: Int = 0
    @State private var firebaseDataArray: [FirebaseDataModel] = []
    var body: some View {
        
        VStack(spacing: 10) {
           // LineChart(dataPoints: firebaseDataArray.map { //$0.value },lineColor: .blue)
              //              .frame(height: 300)
            GaugeView(value: Double(data), minValue: 0, maxValue: 50, gaugeColor: .blue, backgroundColor: .gray, gaugeWidth: 10)
            Text("Mositure Reading")
                .multilineTextAlignment(.center)
            Spacer(minLength: 10)
            HStack{
                Button(action: {
                    // Add the action you want the button to perform when tapped
                    let Pump = Database.database().reference().child("Arduino/Pump/")
                    Pump.setValue("ON")
                }) {
                    // Customize the button's appearance
                    Text("ON")
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .font(.headline)
                        .cornerRadius(10)
                }
                Spacer(minLength: 10)
                Button(action: {
                    // Add the action you want the button to perform when tapped
                    let Pump = Database.database().reference().child("Arduino/Pump/")
                    Pump.setValue("OFF")
                }) {
                    // Customize the button's appearance
                    Text("OFF")
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .font(.headline)
                        .cornerRadius(10)
                }
            }
            
            Spacer(minLength: 10)
            Button("Go Back") {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding()
        .navigationTitle("Plant Health")
        .task {
            // Reference to your Firebase Realtime Database node
            let Moisture = Database.database().reference().child("Arduino/Moisture/")
            
            //ref.setValue(42)
            // Observe the data
            Moisture.observe(.value) { snapshot in
                if let value = snapshot.value as? Int {
                    self.data = value
                    //result = storemoisturevalue(Value:data)
                    // print(result)
                }
            }
            fetchDataFromFirebase()
        }

        //  func storemoisturevalue(result:Int = result)-> Int {
        //ref.setValue(42)
        // Observe the data
        //result = Value
        //   print(result)
        // return (result)
        //}
    }
    func fetchDataFromFirebase() {
        let Moisture = Database.database().reference().child("Arduino/Moisture/")
        let timestamp = Date()
        Moisture.observe(.value, with: { snapshot in
            if let value = snapshot.value as? [String: Any] ,
               let value1 = value["value"] as? Float{
                let newData = FirebaseDataModel( id: snapshot.key, value: value1, timestamp: timestamp)
                firebaseDataArray.append(newData)
                print("Data fetched: \(newData)")
                
            }
                
        })
        
    }
}

struct LineChart: View {
    let dataPoints: [Float]
    let lineColor: Color
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                for (index, dataPoint) in dataPoints.enumerated() {
                    let x = geometry.size.width / CGFloat(dataPoints.count - 1) * CGFloat(index)
                    let y = (1 - CGFloat(dataPoint)) * geometry.size.height
                    let point = CGPoint(x: x, y: y)

                    if index == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 2)
        }
    }
}

struct FishView: View {

    @State private var value: Double = 50 // Initial value
    @Environment(\.presentationMode) var presentationMode
    @State private var data: Int = 0
    @State private var data1: Int = 0
    @State private var data2: Int = 0
    
    //@State var result: Int = 0
    //@State var result1: Int = 0
    //@State var result2: Int = 0
    var body: some View {
        
            VStack(spacing: 10) {
                GaugeView(value: Double(data1), minValue: 0, maxValue: 100, gaugeColor: .green, backgroundColor: .gray, gaugeWidth: 10)
                Text("Water Level")
                    .multilineTextAlignment(.center)
                BarView(value: Double(data2), minValue: 0, maxValue: 14, backgroundColor: .gray, BarWidth: 200, BarHeight: 40)
                //BarColor: .red
                //GaugeView(value: Double(data2), minValue: 0, maxValue: 100, gaugeColor: .red, backgroundColor: .gray, gaugeWidth: 10)
                Text("pH")
                    .multilineTextAlignment(.center)
                      
                //Spacer(minLength: 10)
                //Text("Fill Water")
                HStack{
                    //Text("Fill Water")
                    Button(action: {
                                    // Add the action you want the button to perform when tapped
                        let Pump = Database.database().reference().child("Arduino/Pump/")
                                    Pump.setValue("ON")
                                }) {
                                    // Customize the button's appearance
                                    Text("Fill Water")
                                        .padding()
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .font(.headline)
                                        .cornerRadius(10)
                                }
                    Spacer(minLength: 10)
                    Button(action: {
                                    // Add the action you want the button to perform when tapped
                        let Pump = Database.database().reference().child("Arduino/Pump/")
                                    Pump.setValue("OFF")
                                }) {
                                    // Customize the button's appearance
                                    Text("OFF")
                                        .padding()
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .font(.headline)
                                        .cornerRadius(10)
                                }
                    
                }
                
                HStack{
                    //Text("Fill Water")
                    Button(action: {
                                    // Add the action you want the button to perform when tapped
                        let Pump = Database.database().reference().child("Arduino/Pump2/")
                                    Pump.setValue("ON")
                                }) {
                                    // Customize the button's appearance
                                    Text("Empty Tank")
                                        .padding()
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .font(.headline)
                                        .cornerRadius(10)
                                }
                    Spacer(minLength: 10)
                    Button(action: {
                                    // Add the action you want the button to perform when tapped
                        let Pump = Database.database().reference().child("Arduino/Pump2/")
                                    Pump.setValue("OFF")
                                }) {
                                    // Customize the button's appearance
                                    Text("OFF")
                                        .padding()
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .font(.headline)
                                        .cornerRadius(10)
                                }
                }
                
                Spacer(minLength: 10)
                
                HStack{
                    
                    Button(action: {
                        // Add the action you want the button to perform when tapped
                        let Servo = Database.database().reference().child("Arduino/Servo/")
                        Servo.setValue("A")
                    }) {
                        // Customize the button's appearance
                        Text("A")
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .font(.headline)
                            .cornerRadius(10)
                    }
                    Spacer(minLength: 10)
                    Button(action: {
                        // Add the action you want the button to perform when tapped
                        let Servo = Database.database().reference().child("Arduino/Servo/")
                        Servo.setValue("B")
                    }) {
                        // Customize the button's appearance
                        Text("B")
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .font(.headline)
                            .cornerRadius(10)
                    }
                }
                Spacer(minLength: 10)
                Button("Go Back") {
                                presentationMode.wrappedValue.dismiss()
                            }
            }
            .padding()
            .navigationTitle("Aquarium Health")
            .task {
                // Reference to your Firebase Realtime Database node
                let WaterLevel = Database.database().reference().child("Arduino/WaterLevel/")
                let pH = Database.database().reference().child("Arduino/pH/")
                let Moisture = Database.database().reference().child("Arduino/Moisture/")
                
                //ref.setValue(42)
                // Observe the data
                Moisture.observe(.value) { snapshot in
                    if let value = snapshot.value as? Int {
                        self.data = value
                        //Val(Value:data)
                        WaterLevel.observe(.value) { snapshot in
                            if let value = snapshot.value as? Int {
                                self.data1 = value
                                pH.observe(.value) { snapshot in
                                    if let value = snapshot.value as? Int {
                                        self.data2 = value
                                        if data1 < 50 || data < 50 || data2 < 7 {
                                            //scheduleLocalNotification(Value:data,Value1:data1,Value2: data2)
                                            print("\(data),\(data1),\(data2)")
                                            
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
        }

    /*func scheduleLocalNotification(Value:Int, Value1:Int, Value2:Int) {
            result = Value
            result1 = Value1
            result2 = Value2
            //print(Value)
        
           // let result = myStructInstance.storemoisturevalue()
            let content = UNMutableNotificationContent()
            content.title = "Care"
            content.body = "Some parameters are not in the desired range, please check your plant/pets health.\n\n Mositure:\(result) (Desired Range : above 50)\nWaterLevel:\(result1) (Desired Range : above 50\npH:\(result2) (Desired Range : between 6-8)"

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                } else {
                    print("Notification scheduled successfully!")
                }
            }
        }*/
        
    
}

struct BarView: View{
    var value: Double
    var minValue: Double
    var maxValue: Double
    //var BarColor: Color
    var backgroundColor: Color
    var BarWidth: CGFloat
    var BarHeight: CGFloat
    //var offset : 100
    
    private var normalizedValue: Double {
        max(min((value - minValue) / (maxValue - minValue), 1.0), 0.0)
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                //.stroke(lineWidth: BarWidth)
                .foregroundColor(backgroundColor)
                .frame(width: BarWidth, height:BarHeight)
            Group {
                if value == 1 { // If the value is >= 80% of maxValue
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: BarWidth*CGFloat(min(normalizedValue, 1.0)),height: BarHeight)
                        //.offset(x:  -95)
                    
                } else if value == 2 { // If the value is >= 50% of maxValue
                    Rectangle()
                        .fill(Color.pink)
                        .frame(width: BarWidth*CGFloat(min(normalizedValue, 1.0)),height: BarHeight)
                        //.offset(x:  -85)
                } else if value == 3 { // If the value is >= 50% of maxValue
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: BarWidth*CGFloat(min(normalizedValue, 1.0)),height: BarHeight)
                        //.offset(x:  -75)
                } else if value == 4 { // If the value is >= 50% of maxValue
                    Rectangle()
                        .fill(Color(red: 245/255, green: 245/255, blue: 220/255))
                        .frame(width: BarWidth*CGFloat(min(normalizedValue, 1.0)),height: BarHeight)
                } else if value == 5 { // If the value is >= 50% of maxValue
                    Rectangle()
                        .fill(Color.yellow)
                        .frame(width: BarWidth*CGFloat(min(normalizedValue, 1.0)),height: BarHeight)
                } else if value == 6 { // If the value is >= 50% of maxValue
                    Rectangle()
                        .fill(Color(red: 50/255, green: 205/255, blue: 50/255))
                        .frame(width: BarWidth*CGFloat(min(normalizedValue, 1.0)),height: BarHeight)
                } else if value == 7 { // If the value is >= 50% of maxValue
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: BarWidth*CGFloat(min(normalizedValue, 1.0)),height: BarHeight)
                } else if value == 8 { // If the value is >= 50% of maxValue
                    Rectangle()
                        .fill(Color(red: 0/255, green: 100/255, blue: 0/255))
                        .frame(width: BarWidth*CGFloat(min(normalizedValue, 1.0)),height: BarHeight)
                } else if value == 9 { // If the value is >= 50% of maxValue
                    Rectangle()
                        .fill(Color.teal)
                        .frame(width: BarWidth*CGFloat(min(normalizedValue, 1.0)),height: BarHeight)
                } else if value == 10 { // If the value is >= 50% of maxValue
                    Rectangle()
                        .fill(Color(red: 173/255, green: 216/255, blue: 230/255))
                        .frame(width: BarWidth*CGFloat(min(normalizedValue, 1.0)),height: BarHeight)
                } else if value == 11 { // If the value is >= 50% of maxValue
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: BarWidth*CGFloat(min(normalizedValue, 1.0)),height: BarHeight)
                } else if value == 12 { // If the value is >= 50% of maxValue
                    Rectangle()
                        .fill(Color(red: 0/255, green: 0/255, blue: 139/255))
                        .frame(width: BarWidth*CGFloat(min(normalizedValue, 1.0)),height: BarHeight)
                } else if value == 13 { // If the value is >= 50% of maxValue
                    Rectangle()
                        .fill(Color.purple)
                        .frame(width: BarWidth*CGFloat(min(normalizedValue, 1.0)),height: BarHeight)
                } else { // If the value is less than 50% of maxValue
                    Rectangle()
                        .fill(Color.purple)
                        .frame(width: BarWidth*CGFloat(min(normalizedValue, 1.0)),height: BarHeight)
                }
            }
            .offset(x:  (BarWidth*CGFloat(min(normalizedValue, 1.0)))/2 - 100)
            
           // Rectangle()
            //    .foregroundColor(BarColor)
           //     .frame(width: BarWidth*CGFloat(min(normalizedValue, 1.0)),height: 40.0)
               // .alignmentGuide(g:HorizontalAlignment, computeValue: 0.0)
               // .trim(from: 0.0, to: CGFloat(normalizedValue))
                //.stroke(BarColor, style: StrokeStyle(lineWidth: BarWidth, lineCap: .square))
            
            Text("\(Int(value))")
                .font(.headline)
                
        }
    }
}

struct GaugeView: View {
    var value: Double
    var minValue: Double
    var maxValue: Double
    var gaugeColor: Color
    var backgroundColor: Color
    var gaugeWidth: CGFloat
    var startAngle: Double = 180
    var endAngle: Double = 0

    private var normalizedValue: Double {
        max(min((value - minValue) / (maxValue - minValue), 1.0), 0.0)
    }

    private var gradient: AngularGradient {
        AngularGradient(gradient: Gradient(colors: [backgroundColor, gaugeColor]), center: .center, startAngle: .degrees(startAngle), endAngle: .degrees(startAngle - (startAngle - endAngle) * normalizedValue))
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: gaugeWidth)
                .foregroundColor(backgroundColor)

            Circle()
                .trim(from: 0.0, to: CGFloat(normalizedValue))
                .stroke(gaugeColor, style: StrokeStyle(lineWidth: gaugeWidth, lineCap: .round))
                .rotationEffect(.degrees(startAngle))

            Text("\(Int(value))")
                .font(.headline)
            
        }
        .padding()
    }
}

class Notificataion: ObservableObject {
    @State private var data: Int = 0
    @State private var data1: Int = 0
    @State private var data2: Int = 0
    func grabdata() {
        let Moisture = Database.database().reference().child("Arduino/Moisture/")
        let WaterLevel = Database.database().reference().child("Arduino/WaterLevel/")
        let pH = Database.database().reference().child("Arduino/pH/")
        
        //ref.setValue(42)
        // Observe the data
        Moisture.observe(.value) { snapshot in
            if let value = snapshot.value as? Int {
                self.data = value
            }
        }
        WaterLevel.observe(.value) { snapshot in
            if let value = snapshot.value as? Int {
                self.data1 = value
            }
        }
        pH.observe(.value) { snapshot in
            if let value = snapshot.value as? Int {
                self.data2 = value
            }
        }
        //     if data < 50 || data1 < 50 || data2 < 6 {
        //  createAlert()
        //   }
       // checkAndDisplayNotification()
    }
    func createAlert() -> Alert {
            return Alert(
                title: Text("Greetings"),
                message: Text("Welcome to Care App"),
                dismissButton: .default(Text("OK")) {
                    // Do something after the alert is dismissed
                }
            )
        }

    func shouldShowAlert() -> Bool {
            return data < 50 || data1 < 50 || data2 < 6
        }
}

struct Notify {
    func createAlert() -> Alert {
            return Alert(
                title: Text("Greetings"),
                message: Text("Welcome to Care App"),
                dismissButton: .default(Text("OK")) {
                    // Do something after the alert is dismissed
                }
            )
        }
    
}

struct Message: View {
    @State private var value: Double = 50 // Initial value
    @Environment(\.presentationMode) var presentationMode
    @State private var data: Int = 0
    @State private var data1: Int = 0
    @State private var data2: Int = 0
    @State var result: Int = 0
    @State var result1: Int = 0
    @State var result2: Int = 0
    var pHreading = Array<Int>()
    var body: some View  {
        ContentView()
        VStack{
            EmptyView()
        }.task {
            let WaterLevel = Database.database().reference().child("Arduino/WaterLevel/")
            let pH = Database.database().reference().child("Arduino/pH/")
            let Moisture = Database.database().reference().child("Arduino/Moisture/")
            
            //ref.setValue(42)
            // Observe the data
            Moisture.observe(.value) { snapshot in
                if let value = snapshot.value as? Int {
                    self.data = value
                    //Val(Value:data)
                    WaterLevel.observe(.value) { snapshot in
                        if let value = snapshot.value as? Int {
                            self.data1 = value
                            pH.observe(.value) { snapshot in
                                if let value = snapshot.value as? Int {
                                    self.data2 = value
                                    if data1 < 50 || data < 50 || data2 < 7 {
                                        scheduleLocalNotification(Value:data,Value1:data1,Value2: data2)
                                        print("\(data),\(data1),\(data2)")
                                    }
                                }
                                
                            }
                        }
                    }
                }
            }
        }
    }
    func scheduleLocalNotification(Value:Int, Value1:Int, Value2:Int) {
            result = Value
            result1 = Value1
            result2 = Value2
            //print(Value)
        
           // let result = myStructInstance.storemoisturevalue()
            let content = UNMutableNotificationContent()
            content.title = "Care"
            content.body = "Some parameters are not in the desired range, please check your plant/pets health.\n\n Mositure:\(result) (Desired Range : above 50)\nWaterLevel:\(result1) (Desired Range : above 50\npH:\(result2) (Desired Range : between 6-8)"

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                } else {
                    print("Notification scheduled successfully!")
                }
            }
        }
}

struct FirebaseDataModel: Identifiable {
    let id: String
    let value: Float
    let timestamp: Date
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

