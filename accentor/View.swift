//
//  View.swift
//  accentor
//
//  Created by Robbe Van Petegem on 05/02/2024.
//

import SwiftUI

extension View {
    func modify<T: View>(@ViewBuilder _ modifier: (Self) -> T) -> some View {
        return modifier(self)
    }
}
