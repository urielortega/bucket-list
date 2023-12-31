//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Uriel Ortega on 21/06/23.
//

import Foundation
import LocalAuthentication
import MapKit

extension ContentView { // Because this is the ViewModel of ContentView.
    @MainActor class ViewModel: ObservableObject {
        @Published var mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25)
        )
        
        @Published private(set) var locations: [Location] // Only the class itself can write locations.
        @Published var selectedPlace: Location?
        @Published var isUnlocked = false
        
        @Published var authenticationError = "Unknown error"
        @Published var isShowingAuthenticationError = false
        
        let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedPlaces")
        
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomic, .completeFileProtection])
            } catch {
                print("Unable to save data.")
            }
        }
        
        func addLocation() {
            let newLocation = Location(
                id: UUID(),
                name: "New location",
                description: "",
                latitude: mapRegion.center.latitude,
                longitude: mapRegion.center.longitude
            )
            
            locations.append(newLocation)
            
            save()
        }
        
        func update(location: Location) {
            guard let selectedPlace = selectedPlace else { return }
            
            // Find where is currently our location...
            if let index = locations.firstIndex(of: selectedPlace) {
                // Write that index with the new location.
                locations[index] = location
                
                save()
            }
        }
        
        func authenticate() {            
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate yourself to unlock your places."
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                    Task { @MainActor in
                        if success {
                            self.isUnlocked = true
                        } else {
                            // Error.
                            self.authenticationError = "There was a problem authenticating you. Try again."
                            self.isShowingAuthenticationError = true
                        }
                    }
                }
            } else {
                // No biometrics.
                authenticationError = "Sorry, your device does not support biometrics."
                isShowingAuthenticationError = true                
            }
        }
    }
}
    
