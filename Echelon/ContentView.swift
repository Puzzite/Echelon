//
//  ContentView.swift
//  Echelon
//
//  Created by Jackson Jordan on 5/25/26.
//

import SwiftUI

struct ContentView: View {
    // Root of the app. For now it's just Search; this becomes a
    // TabView (Search / Feed / Profile) once those screens exist.
    var body: some View {
        SearchView()
    }
}

#Preview {
    ContentView()
}
