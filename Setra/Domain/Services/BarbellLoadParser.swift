import Foundation

struct ParsedBarbellLoad: Hashable {
    var totalWeight: Double
    var barWeight: Double
    var perSideWeight: Double
    var mode: BarbellEntryMode
    var summary: String
    var rawInput: String
}

struct BarbellLoadParser {
    func parse(text: String, settings: AppSettings) -> ParsedBarbellLoad? {
        let normalized = normalize(text)
        guard !normalized.isEmpty else { return nil }

        if normalized.contains("p") {
            return parsePlateShorthand(normalized, settings: settings)
        }

        guard let value = Double(normalized) else { return nil }
        let totalWeight: Double
        switch settings.preferredBarbellEntryMode {
        case .shorthandPlatesPerSide:
            totalWeight = value
        case .perSideLoad:
            totalWeight = settings.defaultBarbellWeight + (value * 2)
        case .totalLoadExcludingBar:
            totalWeight = settings.defaultBarbellWeight + value
        case .totalLoadIncludingBar:
            totalWeight = value
        }

        let perSide = max(0, (totalWeight - settings.defaultBarbellWeight) / 2)
        return ParsedBarbellLoad(
            totalWeight: totalWeight,
            barWeight: settings.defaultBarbellWeight,
            perSideWeight: perSide,
            mode: settings.preferredBarbellEntryMode,
            summary: summary(for: settings.preferredBarbellEntryMode, totalWeight: totalWeight, settings: settings),
            rawInput: text
        )
    }

    private func parsePlateShorthand(_ text: String, settings: AppSettings) -> ParsedBarbellLoad? {
        let parts = text.split(separator: "p", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2 else { return nil }

        let topPlate = settings.plateInventory
            .filter { $0.unit == settings.weightUnit }
            .map(\.weight)
            .max() ?? settings.weightUnit.defaultBarbellWeight

        let leading = String(parts[0])
        let stackCount = leading.isEmpty ? 1 : Int(leading)
        guard let stackCount, stackCount >= 0 else { return nil }

        var perSide = Double(stackCount) * topPlate
        let suffix = String(parts[1])
        if !suffix.isEmpty {
            let inventory = settings.plateInventory
                .filter { $0.unit == settings.weightUnit }
                .map(\.weight)
                .sorted(by: >)
            var remaining = suffix
            while !remaining.isEmpty {
                guard let match = inventory.first(where: { remaining.hasPrefix(token(for: $0)) }) else {
                    return nil
                }
                perSide += match
                remaining.removeFirst(token(for: match).count)
            }
        }

        let totalWeight = settings.defaultBarbellWeight + (perSide * 2)
        return ParsedBarbellLoad(
            totalWeight: totalWeight,
            barWeight: settings.defaultBarbellWeight,
            perSideWeight: perSide,
            mode: .shorthandPlatesPerSide,
            summary: "\(text.lowercased()) = \(settings.defaultBarbellWeight.clean) + \(perSide.clean) / side",
            rawInput: text
        )
    }

    private func normalize(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: settingsUnitSuffixPattern, with: "", options: .regularExpression)
    }

    private var settingsUnitSuffixPattern: String {
        "(lbs|lb|kg)$"
    }

    private func token(for weight: Double) -> String {
        weight.clean.replacingOccurrences(of: ".0", with: "")
    }

    private func summary(for mode: BarbellEntryMode, totalWeight: Double, settings: AppSettings) -> String {
        switch mode {
        case .shorthandPlatesPerSide:
            return "Total system weight"
        case .perSideLoad:
            return "One side + bar = \(totalWeight.clean) \(settings.weightUnit.shortLabel)"
        case .totalLoadExcludingBar:
            return "Plates + bar = \(totalWeight.clean) \(settings.weightUnit.shortLabel)"
        case .totalLoadIncludingBar:
            return "Total system weight"
        }
    }
}
