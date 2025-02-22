//
//  ContentView.swift
//  LexiMind
//
//  Created by Cankat Acarer on 15.02.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme
    
    private var backgroundColor: UIColor {
        colorScheme == .dark ? UIColor(red: 23/255, green: 30/255, blue: 37/255, alpha: 1) : .white
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Color(backgroundColor)
                    .ignoresSafeArea()
                
                TabView(selection: $selectedTab) {
                    Text("Home")
                        .tag(0)
                    Text("Dictionary")
                        .tag(1)
                    Text("Practice")
                        .tag(2)
                    Text("Achievements")
                        .tag(3)
                    Text("Profile")
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                CustomTabBar(selectedTab: $selectedTab, backgroundColor: backgroundColor)
                    .frame(height: 90)
            }
        }
    }
}

#Preview {
    ContentView()
}
