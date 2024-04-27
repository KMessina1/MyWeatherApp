/*--------------------------------------------------------------------------------------------------------------------------
    File: ContentView.swift
  Author: Kevin Messina
 Created: 4/21/24
Modified:
 
©2024 Creative App Solutions, LLC. - All Rights Reserved.
----------------------------------------------------------------------------------------------------------------------------
NOTES:
--------------------------------------------------------------------------------------------------------------------------*/

import SwiftUI
import WeatherKit
import CoreLocation

struct ContentView: View {
    @StateObject var weather:WeatherVM = WeatherVM()
    
    @State var showCoordinateInput:Bool = false
    @State var loc:Int = cities[0].id
    var customLoc:Int = cities.count - 1
    
    init(weather: WeatherVM) {
        _weather = StateObject(wrappedValue: weather)
    }
    
    var body: some View {
        ZStack{
            LinearGradient(colors: [.cyan,.blue,.orange], startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                Text("Creative\nApps\nDemo")
                    .rotationEffect(Angle(degrees: -45.0))
                    .padding(.bottom,50)
                
                Text("Creative\nApps\nDemo")
                    .rotationEffect(Angle(degrees: -45.0))
            }
            .foregroundStyle(.red)
            .font(.system(size: 72))
            .multilineTextAlignment(.center)
            .opacity(0.40)

            if weather.isLoading {
                ProgressView {
                    Text("Loading Weather...")
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(.orange)
                        .bold()
                }
            } else {
                VStack {
                    VStack {
                        VStack(spacing: 8) {
                            if (loc < customLoc) {
                                Text(cities[loc].name)
                                    .font(.title)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            } else {
                                Text("Lat: \(weather.latitude), Lon: \(weather.longitude)")
                                    .font(.headline)
                            }
                            
                            HStack(spacing: 0) {
                                Text(weather.asOf, style: .date)
                                Text(" @ ")
                                Text(weather.asOf, style: .time)
                            }
                            .font(.caption)
                            .padding(.top,-5)
                            
                            Text(weather.currentTemperature)
                                .font(.system(size: 72, weight: .light))
                            
                            Text("Currently \(weather.currentCondition)".uppercased())
                                .font(.headline)
                                .italic()
                                .offset(y: -15)
                                .minimumScaleFactor(0.75)
                        }//Title Temp

                        VStack(alignment: .leading) {
                            Label("24-Hour Forecast".uppercased(), systemImage: "clock")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding([.top,.leading], 10)
                            
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(weather.hourlyForecast, id: \.time) { weather in
                                        VStack(spacing: 6) {
                                            Text(weather.time)
                                                .font(.caption)
                                                .fontWeight(.bold)

                                            imgHasAFilledVersionOrNot(weather.symbolName)
                                                .resizable()
                                                .frame(width: 35, height: 30)
                                                .symbolRenderingMode(.multicolor)
                                                .aspectRatio(contentMode: .fit)
                                            
                                            Text(weather.temperature)
                                                .fontWeight(.semibold)
                                        }
                                        .padding(.horizontal,5)
                                        
                                        Divider().frame(height:65)
                                    }
                                }
                                .padding(.all,5)
                            }
                        }//24-Hour
                        .font(.body)
                        .foregroundStyle(.white)
                        .background(.ultraThinMaterial.opacity(0.66), in: RoundedRectangle(cornerRadius: 15.0))

                        Divider()
                            .frame(minHeight: 2)
                            .background(Color.orange)
                        
                        ScrollView {
                            HStack {
                                VStack {
                                    HStack {
                                        Image(systemName: "thermometer.medium")
                                            .font(.largeTitle)

                                        VStack(alignment:.leading){
                                            Text("H: \(weather.currentHighTemp)")
                                            Text("L: \(weather.currentLowTemp)")
                                        }
                                    }
                                    .padding(.bottom,2)

                                    Text("TEMP")
                                        .font(.system(size: 12, weight: .light))
                                }
                                .padding(.vertical,10)
                                .padding(.horizontal,10)
                                .background(.ultraThinMaterial.opacity(0.66), in: RoundedRectangle(cornerRadius: 15.0))

                                Spacer()
                                
                                VStack {
                                    HStack {
                                        Image(systemName: "humidity.fill")
                                            .font(.largeTitle)
                                        
                                        VStack(alignment:.leading){
                                            Text("\(weather.currentHumidity)")
                                            Text("\(weather.currentDewPoint)")
                                        }
                                    }
                                    .padding(.bottom,2)
                                    
                                    Text("HUMIDITY/DEW PT.")
                                        .font(.system(size: 12, weight: .light))
                                }
                                .padding(.vertical,10)
                                .padding(.horizontal,10)
                                .background(.ultraThinMaterial.opacity(0.66), in: RoundedRectangle(cornerRadius: 15.0))
                            }//Temp / Humidity
                            
                            HStack {
                                VStack {
                                    HStack {
                                        Image(systemName: "wind")
                                            .font(.largeTitle)
                                        
                                        VStack(alignment:.leading){
                                            HStack(spacing: 0) {
                                                Text("\( weather.currentWindSpeed )")
                                                if weather.currentWindGust.count > 4 {
                                                    Text(", Gusts ")
                                                }else{
                                                    Text("")
                                                }
                                                Text("\( weather.currentWindGust )")
                                                Spacer()
                                            }

                                            HStack(spacing:0) {
                                                Image(systemName: weather.currentWindDirImg)
                                                Text("\( weather.currentWindDirection )")
                                                    .minimumScaleFactor(0.5)
                                            }
                                        }
                                    }
                                    .padding(.bottom,2)
                                    
                                    Text("WIND / GUSTING SPEEDS / DIRECTION")
                                        .font(.system(size: 12, weight: .light))
                                }
                                .padding(.vertical,10)
                                .padding(.horizontal,10)
                                .background(.ultraThinMaterial.opacity(0.66), in: RoundedRectangle(cornerRadius: 15.0))
                            }//Wind
                            
                            HStack {
                                VStack {
                                    HStack {
                                        Image(systemName: "gauge")
                                            .font(.largeTitle)

                                        VStack(alignment: .leading) {
                                            HStack(spacing:0) {
                                                Text(weather.currentPressureState == "-" ?"" :weather.currentPressureState)
                                                    .foregroundStyle(weather.currentPressureColor)
                                                    .fontWeight(.heavy)
                                                Text("\(weather.currentPressure)")
                                            }

                                            HStack {
                                                if !weather.currentPressureTrendImg.isEmpty {
                                                    Image(systemName: weather.currentPressureTrendImg)
                                                }
                                                Text(weather.currentPressureTrend.capitalized)
                                            }
                                        }
                                    }
                                    .padding(.bottom,2)

                                    Text("PRESSURE")
                                        .font(.system(size: 12, weight: .light))
                                }
                                .padding(.vertical,10)
                                .padding(.horizontal,10)
                                .background(.ultraThinMaterial.opacity(0.66), in: RoundedRectangle(cornerRadius: 15.0))

                                Spacer()
                                
                                VStack {
                                    HStack {
                                        Image(systemName: "thermometer.variable.and.figure")
                                            .font(.largeTitle)
                                        
                                        Text("\(weather.feelsLike)")
                                    }
                                    .padding(.bottom,2)
                                    
                                    Text("FEELS LIKE")
                                        .font(.system(size: 12, weight: .light))
                                }
                                .padding(.vertical,10)
                                .padding(.horizontal,10)
                                .background(.ultraThinMaterial.opacity(0.66), in: RoundedRectangle(cornerRadius: 15.0))

                            }//Pressure / Feels Like

                            Spacer()
                            
                            VStack(alignment: .leading) {
                                Label("10-Day Forecast".uppercased(), systemImage: "clock")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding([.top,.leading], 10)
                                
                                ScrollView() {
                                    VStack {
                                        ForEach(weather.tenDayForecast, id: \.day) { weather in
                                            VStack(alignment: .leading) {
                                                Spacer().frame(height:20)
                                                
                                                HStack(spacing: 10) {
                                                    HStack {
                                                        Spacer()
                                                        Text(weather.day)
                                                            .font(.headline)
                                                            .fontWeight(.bold)
                                                            .minimumScaleFactor(0.75)
                                                    }
                                                    .frame(width: 75)

                                                    imgHasAFilledVersionOrNot(weather.symbolName)
                                                        .resizable()
                                                        .frame(width: 35, height: 30)
                                                        .symbolRenderingMode(.multicolor)
                                                        .aspectRatio(contentMode: .fit)
                                                        .padding(.trailing,5)
    
                                                    HStack {
                                                        let Hi:Double = Double(weather.highTemperature) ?? 0.0
                                                        let Lo:Double = Double(weather.lowTemperature) ?? 0.0
                                                        /* Because ProgressView can't go below 0;
                                                            0 representing -50 degrees
                                                            total 100 representing 125
                                                         
                                                            so adding 50 to current lo and hi gives proper range on 0-175
                                                            versus -50 to 125 scale which is a total of 75 difference.
                                                        */
                                                        let maxProgress = 175.0

                                                        Text("\( weather.lowTemperature )°")
                                                        ProgressView(value: Lo, total: maxProgress)
                                                            .progressViewStyle(BarProgressStyle(color: .red, lo:Lo, hi: Hi))
                                                            .offset(y:-3)
                                                        Text("\( weather.highTemperature )°")
                                                    }//ProgressView
                                                    .fontWeight(.medium)
                                                }
                                                
                                                Spacer()
                                            }
                                            .padding(.horizontal,5)
                                            
                                            Divider()
                                        }
                                    }
                                    .padding(.all,5)
                                }
                            }//10-Day
                            .font(.body)
                            .foregroundStyle(.white)
                            .background(.ultraThinMaterial.opacity(0.66), in: RoundedRectangle(cornerRadius: 15.0))

                            Spacer()
                        }
                    }
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding(.horizontal,20)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Picker("",selection: $loc) {
                            ForEach(cities, id: \.id) { city in
                                Text(city.name).tag(city.id)
                            }
                        }
                        .clipped()
                        .frame(minWidth: 250)
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .tint(.blue)
                        .onChange(of: loc) {
                            if loc == customLoc {
                                showCoordinateInput.toggle()
                                return
                            }

                            guard
                                let city = cities.filter({$0.id == loc}).first
                            else {
                                return
                            }
                            
                            if loc < customLoc {
                                weather.latitude =  city.lat
                                weather.longitude = city.lon
                            }

                            weather.fetchCurrentWeather(lat:weather.latitude, lon: weather.longitude)
                        }
                        
                        Spacer()
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .padding(.horizontal,20)

                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showCoordinateInput) {
            getCoordinatesView(weather: weather, loc: $loc)
                .presentationDetents([.height(250)])
                .presentationBackgroundInteraction(.disabled)
                .presentationBackground(.thinMaterial)
                .presentationCornerRadius(50)
                .interactiveDismissDisabled()
        }
        .environment(\.colorScheme, .dark)
    }
    
    func imgHasAFilledVersionOrNot(_ systemName: String) -> Image {
        if UIImage(systemName: "\(systemName).fill") != nil {
            return Image(systemName: "\(systemName).fill")
        }else{
            return Image(systemName: systemName)
        }
    }
                        
    struct BarProgressStyle: ProgressViewStyle {
        var color: Color = .purple
        var height: Double = 25.0
        var labelFontStyle: Font = .body
        var lo:Double
        var hi:Double
        var minProgressValue:Double = 0.0
        var maxProgressValue:Double = 175.0
        var offsetProgressValue:Double = (75.0 / 3.0) // Calculation below zero not counting max being above 100

        func getTemperaturePosition(_ temperature:Double) -> Double {
            ((temperature / maxProgressValue) * 100) + offsetProgressValue
        }

        func makeBody(configuration: Configuration) -> some View {
            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    configuration.label
                        .font(labelFontStyle)
                    
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(LinearGradient(
                            stops: [
                                Gradient.Stop(color: .blue, location: 0.0),
                                Gradient.Stop(color: .cyan, location: 0.33),
                                Gradient.Stop(color: .green, location: 0.5),
                                Gradient.Stop(color: .orange, location: 0.65),
                                Gradient.Stop(color: .red, location: 1.0),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width, height: height)
                        .overlay {
                            HStack {
                                RoundedRectangle(cornerRadius: 5.0)
                                    .fill(LinearGradient(
                                        colors: [
                                            .clear,
                                            .white.opacity(0.15),
                                            .white.opacity(0.33),
                                            .white.opacity(0.66),
                                            .white.opacity(0.33),
                                            .white.opacity(0.15),
                                            .clear
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .stroke(Color.black, lineWidth: 2.0, antialiased: true)
                                    .stroke(Color.white.opacity(0.33), lineWidth: 1.0, antialiased: true)
                                    .frame(width:(hi - lo), height: (height + 2.0))
                                    .offset(x: getTemperaturePosition(lo))

                                Spacer()
                            }
                        }
//                        .overlay { // Centered text over selection zone
//                            let dailyTempVariance = (hi - lo)
//                            let centerPosition = getTemperaturePosition(hi) - (getTemperaturePosition(dailyTempVariance) / 2.5)
//                            
//                            HStack {
//                                Text("DAILY RANGE OF \( dailyTempVariance.formatted(.number.precision(.fractionLength(0))) )°")
//                                    .offset(x: centerPosition, y: -20)
//                                    .font(.system(size: 10.0, weight: .bold))
//                                
//                                Spacer()
//                            }
//                        }
                        .overlay {
                            let dailyTempVariance = (hi - lo)
                            ZStack {
                                Divider()
                                Text("DAILY RANGE OF \( dailyTempVariance.formatted(.number.precision(.fractionLength(0))) )°")
                                    .font(.system(size: 10.0, weight: .bold))
                                    .padding(.horizontal,10)
                                    .background(Rectangle().fill(.clear))
                            }
                            .offset(y: -20)
                        }
                }
            }
            .offset(y:6)
        }
    }
    
    struct getCoordinatesView: View {
        @Environment(\.dismiss) private var dismiss

        @State var weather: WeatherVM
        @Binding var loc:Int

        @State var lat = ""
        @State var lon = ""
        
        var body: some View {
            VStack {
                Text("Enter Location Coordinates")
                    .foregroundStyle(.black)
                    .font(.title)
                    .padding(.top,50)
                
                VStack(spacing:20) {
                    TextField("Lat:", text: $lat, prompt: Text("Enter Latitude"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Lon:", text: $lon, prompt: Text("Enter Longitude"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .keyboardType(.numbersAndPunctuation)
                .padding(.horizontal,20)
                .padding(.bottom,30)
                
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tint(.red)
                    
                    Spacer()
                    
                    Button("Save") {
                        loc = cities.count - 1
                        DispatchQueue.main.async {
                            let latitude = Double(lat) ?? 0.0
                            let longitude = Double(lon) ?? 0.0
                            print("new lat: \(latitude), new lon: \(longitude)")
                            weather.latitude = latitude
                            weather.longitude = longitude
                            print("WEATHER lat: \(weather.latitude), WEATHER lon: \(weather.longitude)")
                            weather.currentLocation = CLLocation(latitude: latitude, longitude: longitude)
                            weather.fetchCurrentWeather(lat: latitude, lon: longitude)
                            dismiss()
                        }
                    }
                    .tint(.green)
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .padding(.horizontal,20)
                .padding(.bottom,50)
            }
            .onAppear {
                lat = "\(weather.latitude)"
                lon = "\(weather.longitude)"
            }
        }
    }
}

#Preview {
    ContentView(weather: WeatherVM())
}
