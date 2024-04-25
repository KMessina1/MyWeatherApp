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
                            
                            Text("Currently: \(weather.currentCondition)")
                                .font(.headline)
                        }
                        
                        Divider().frame(minHeight: 1).background(Color.orange)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text(weather.dailyHighLowAbbrev)
                                Spacer()
                                Text("-or-")
                                Spacer()
                                Label(weather.currentHighTemp, systemImage: "thermometer.high")
                                Text("/")
                                Label(weather.currentLowTemp, systemImage: "thermometer.low")
                            }
                            .padding(.horizontal,20)
                            
                            Divider().frame(minHeight: 1).background(Color.orange)
                            
                            HStack {
                                Label("Humidity: \( weather.currentHumidity )", systemImage: "humidity.fill")
                                Text("/")
                                Label("DewPoint: \( weather.currentDewPoint )", systemImage: "drop.degreesign.fill")
                            }
                            
                            Divider().frame(minHeight: 1).background(Color.orange)
                            
                            VStack {
                                HStack(spacing:0) {
                                    Label("\( weather.currentWindSpeed )", systemImage: "wind")
                                    Text(" / ")
                                    Label("\( weather.currentWindDirection )", systemImage: weather.currentWindDirImg)
                                }
                                
                                Text("Gusts: \( weather.currentWindGust )")
                            }
                            
                            Divider().frame(minHeight: 1).background(Color.orange)
                            
                            HStack {
                                Text("\( weather.currentPressureState )")
                                    .foregroundStyle(weather.currentPressureColor)
                                Label("\( weather.currentPressure )", systemImage: "gauge")
                                Image(systemName: weather.currentPressureTrend)
                            }
                        }
                        
                        VStack(spacing: 3) {
                            Divider().frame(minHeight: 2).background(Color.orange)
                                .padding(.top,20)
                            
                            Label("Feels Like \( weather.feelsLike )", systemImage: "thermometer.variable.and.figure")
                        }
                    }
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding()
                    
                    VStack(alignment: .leading) {
                        Label("24-Hour Forecast".uppercased(), systemImage: "clock")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding([.top,.leading])
                        
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(weather.hourlyForecast, id: \.time) { weather in
                                    VStack(spacing: 8) {
                                        Text(weather.time)
                                            .font(.caption)
                                        
                                        Image(systemName: "\( weather.symbolName ).fill")
                                            .resizable()
                                            .frame(width: 35, height: 25)
                                            .symbolRenderingMode(.multicolor)
                                            .aspectRatio(contentMode: .fit)
                                        
                                        Text(weather.temperature)
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.vertical,10)
                                    .padding(.horizontal,5)
                                }
                            }
                        }
                    }
                    .font(.body)
                    .foregroundStyle(.white)
                    .background(.ultraThinMaterial.opacity(0.66), in: RoundedRectangle(cornerRadius: 15.0))
                    .padding()
                    
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
//                    .padding([.horizontal,.bottom],20)

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
