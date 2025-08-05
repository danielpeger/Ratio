//
//  BrewCardView.swift
//  Ratio
//
//  Created by Daniel Péger on 2025. 08. 05..
//

import SwiftUI
import Flow

struct BrewCardView: View {
    var brew: Brew
    var showPills: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack {
                    Text("Dose")
                    Text("\(brew.dose)g")
                        .foregroundColor(.secondary)
                }
                Spacer()
                Divider()
                Spacer()
                VStack {
                    Text("Grind")
                    Text("\(brew.grind)")
                        .foregroundColor(.secondary)
                }
                Spacer()
                Divider()
                Spacer()
                VStack {
                    Text("Yield")
                    Text("\(brew.yield)g")
                        .foregroundColor(.secondary)
                }
                Spacer()
                Divider()
                Spacer()
                VStack {
                    Text("Time")
                    Text("\(brew.time)s")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 4)
            .padding(.bottom, showPills ? 0 : 4)
            .padding(.horizontal, 8)
            if showPills {
                Divider()
                HFlow {
                    ForEach(brew.tasteArray, id: \.self) { taste in
                        PillView(text: taste.rawValue)
                    }
                    ForEach(brew.tipArray, id: \.self) { tip in
                        PillView(text: tip.rawValue)
                    }
                }
                .padding(.bottom, 12)
            }
        }
    }
}

#Preview {
    if let fifthBrew = createMockBrews().dropFirst(4).first {
        List{
            Section {
                BrewCardView(brew: fifthBrew)
            }
            Section {
                BrewCardView(brew: fifthBrew, showPills: false)
                    .listRowBackground(Color.clear)
            }
        }
    }}
