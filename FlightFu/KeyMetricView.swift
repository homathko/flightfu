//
//  KeyMetricView.swift
//  FlightFu
//
//  Created by Eric Lightfoot on 2021-09-03.
//

import SwiftUI

struct KeyMetricView: View {
    var name: String
    var value: String
    var unit: String
    var debug = false
    
    var body: some View {
        VStack {
        ///
        /// Key metric label
        ///
            HStack {
                Text(name.uppercased())
                    .font(.system(size: 12))
            }
                    .modifier(DebugBorder(enabled: debug))
        
        ///
        /// Value
        ///
            HStack {
                Text(value).font(.system(size: 50))
            }
                    .modifier(DebugBorder(enabled: debug))
        
        ///
        /// Unit descriptor
        ///
            HStack {
                Text(unit).font(.system(size: 12))
            }
                    .modifier(DebugBorder(enabled: debug))
        }
        .frame(width: 150, height: 150, alignment: .center)
                .modifier(DebugBorder(enabled: debug))
    }
}

struct DebugBorder: ViewModifier {
    var enabled: Bool
    
    func body(content: Content) -> some View {
        Group {
            if enabled {
                content.border(Color.red)
            } else {
                content
            }
        }
    }
}

struct KeyMetricView_Previews: PreviewProvider {
    static var previews: some View {
        KeyMetricView(name: "Confidence", value: "99.7777", unit: "%")
            .previewLayout(.fixed(width: 150, height: 150))
    }
}
