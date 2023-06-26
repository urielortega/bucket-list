//
//  EditView-ViewModel.swift
//  BucketList
//
//  Created by Uriel Ortega on 23/06/23.
//

import SwiftUI

extension EditView {
    @MainActor class ViewModel: ObservableObject {
        enum LoadingState {
            case loading, loaded, failed
        }
        
        @Published var location: Location
        
        @Published var name: String
        @Published var description: String
        
        @Published var loadingState = LoadingState.loading
        
        @Published var pages = [Page]()
        
        init(location: Location) {
            name = location.name
            description = location.description
            self.location = location
        }
        
        func fetchNearbyPlaces() async {
            let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.coordinate.latitude)%7C\(location.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
            
            // Creating the URL we want to read.
            guard let url = URL(string: urlString) else {
                print("Bad URL: \(urlString)")
                return
            }
            
            do {
                print("Starting fetching with \(urlString)")
                
                // Fetching the data for the URL.
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // Decoding the result of the data into a Result.
                let items = try JSONDecoder().decode(Result.self, from: data)
                
                print("Succesfull fetching.")
                
                // Sorting alphabetically.
                pages = items.query.pages.values.sorted()
                loadingState = .loaded
            } catch { // If something went wrong...
                // ...then loading failed.
                print("Fetching failed.")

                loadingState = .failed
            }
            
        }
        
        func createNewLocation() -> Location {
            var newLocation = location
            
            newLocation.id = UUID()
            newLocation.name = name
            newLocation.description = description
            
            return newLocation
        }
    }
}
