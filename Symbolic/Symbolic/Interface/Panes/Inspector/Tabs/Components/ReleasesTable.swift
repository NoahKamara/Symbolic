//
//  ReleasesTable.swift
//  Symbolic
//
//  Created by Noah Kamara on 27.05.2025.
//

import SwiftUI
import SFSymbolsKit

struct ReleasesTable: View {
    let symbols = try! SFSymbolsRepository()
    
    let introduced: SFRelease
    let layersetAvailability: [SFLayerset: SFRelease]

    
    init(introduced: SFRelease, layersetAvailability: [SFLayersetAvailabilityDetail]) {
        self.introduced = introduced
        self.layersetAvailability = .init(
            uniqueKeysWithValues: layersetAvailability.map({ ($0.layerset, $0.release) })
        )
    }
    
    @State
    var releases: [SFRelease] = []
    
    var symbolReleases: [SFRelease] {
        ([introduced]+Array(layersetAvailability.values))
            .removeDuplicates(by: \.year)
            .sorted(by: { $0.year < $1.year })
    }
    
    var shownReleases: [SFRelease] {
        if !isExpanded {
            return symbolReleases
        }
        
        var releases = self.releases
        
        releases.trimPrefix(while: { $0.year != introduced.year })
        
        if let last = symbolReleases.last {
            releases.reverse()
            releases.trimPrefix(while: { $0.year != last.year })
            releases.reverse()
        }
        
        return releases
    }
    
    @State
    var layersets: [SFLayerset] = []
    
//    var filteredLayers: [SFLayerset] {
//        isExpanded ? layersets : layersets.filter(layersetAvailability.keys.contains)
//    }
    
    @State
    var isExpanded: Bool = false
    
    var divider: some View {
        Divider()
            .gridCellColumns(shownReleases.count+1)
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            Grid(alignment: .leading) {
                ReleaseHeaderRow(releases: shownReleases, isExpanded: $isExpanded)
                
                
                divider
                
                LayersetAvailabilityRow(
                    name: "monochrome",
                    introduced: introduced,
                    releases: shownReleases
                )
                
                ForEach(layersets, id:\.name) { layerset in
                    divider
                    
                    LayersetAvailabilityRow(
                        name: layerset.name,
                        introduced: layersetAvailability[layerset],
                        releases: shownReleases
                    )
                    
                    if layerset.name == "hierarchical" {
                        divider
                        
                        LayersetAvailabilityRow(
                            name: "palette",
                            introduced: layersetAvailability[layerset],
                            releases: shownReleases
                        )
                    }
                }
            }
            .animation(.interactiveSpring, value: isExpanded)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        .imageScale(.small)
        .task(id: "bootstrap") {
            do {
                let releases = try await symbols.releases()
                let layersets = try await symbols
                    .layersets()
                    .sorted(by: { lhs, rhs in
                        if let lhsRelease = layersetAvailability[lhs] {
                            if let rhsRelease = layersetAvailability[rhs] {
                                return lhsRelease.year <= rhsRelease.year
                            } else {
                                return true
                            }
                        } else if layersetAvailability[rhs] != nil {
                            return false
                        } else {
                            return lhs.name <= rhs.name
                        }
                    })
                
                await MainActor.run {
                    self.releases = releases
                    self.layersets = layersets
                }
            } catch {
                print("failed to bootstrap \(error)")
            }
        }
    }
}

fileprivate struct ReleaseHeaderRow: View {
    let releases: [SFRelease]
    
    @Binding
    var isExpanded: Bool
    
    var body: some View {
        GridRow(alignment: .firstTextBaseline) {
            Toggle(isOn: $isExpanded) {
                Text(isExpanded ? "Availability" : "Layersets")
                    .font(.callout)
                    .fixedSize()
            }
            .toggleStyle(.button)
            #if os(macOS)
            .buttonStyle(.link)
            #endif

            ForEach(releases, id:\.year) { release in
                Text(release.year)
                    .font(.caption)
                    .gridCellAnchor(.center)
            }
        }
    }
}

fileprivate struct LayersetAvailabilityRow: View {
    let name: String
    let introduced: SFRelease?
    let releases: [SFRelease]
    
    func isAvailable(for release: SFRelease) -> Bool {
        introduced.map({ $0 <= release }) ?? false
    }
    
    var body: some View {
        GridRow(alignment: .firstTextBaseline) {
            Text(name)
                .font(.caption)
                .strikethrough(introduced == nil)
            
            ForEach(releases, id:\.year) { release in
                Image(systemName: "circle.fill")
                    .opacity(isAvailable(for: release) ? 1 : 0.1)
                    .gridCellAnchor(.center)
            }
        }
    }
}

extension Collection {
    func removeDuplicates() -> [Element] where Element: Hashable {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
    
    func removeDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}
