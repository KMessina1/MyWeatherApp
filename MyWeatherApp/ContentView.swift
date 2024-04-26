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
                                            
                                            imgHasAFilledVersionOrNot(weather.symbolName)
                                                .resizable()
                                                .frame(width: 30, height: 20)
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
//                                                Text(" (\( weather.currentWindDirectionAbbrev ))")
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
