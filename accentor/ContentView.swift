//
//  ContentView.swift
//  accentor
//
//  Created by Robbe Van Petegem on 01/11/2022.
//

import SwiftUI
import CoreData

struct ContentView: View {
    let loggedIn = UserDefaults.standard.object(forKey: "userId") != nil

    var body: some View {
        if (loggedIn) {
            AppWrapper()
        } else {
            Login()
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
