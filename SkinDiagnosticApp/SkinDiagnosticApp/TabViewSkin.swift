//
//  TabViewSkin.swift
//  SkinDiagnosticApp
//
//  Created by Rathang Pandit on 11/16/24.
//

//
//  TabView.swift
//  SkinDiagnosticApp
//
//  Created by Rathang Pandit on 11/16/24.
//

import SwiftUI

struct TabViewSkin: View {
    var body: some View
    {
        TabView
        {
            HomeView()
                .tabItem
            {
                Label("Home", systemImage: "house.fill")
            }
            ContentView()
                .tabItem
            {
                Label("Diagnose", systemImage: "person.crop.square.badge.camera.fill")
            }
            LogsView(selectedImage: nil, comment: "")
                .tabItem
            {
        
                Label("Logs", systemImage: "list.dash")
            }
        }
        .accentColor(.green) // Change the selected tab icon color
    }
}

#Preview {
    TabViewSkin()
}
