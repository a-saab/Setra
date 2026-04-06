import Foundation

struct PlateCalculationResult: Hashable {
    var totalWeight: Double
    var barWeight: Double
    var perSideWeight: Double
    var platesPerSide: [PlateInventoryItem]
    var isAchievable: Bool
}

struct PlateCalculator {
    func calculate(
        targetWeight: Double,
        settings: AppSettings
    ) -> PlateCalculationResult {
        let barWeight = settings.defaultBarbellWeight
        let plateTarget = max(0, targetWeight - barWeight)
        let perSide = plateTarget / 2
        var remaining = perSide
        var result: [PlateInventoryItem] = []

        for item in settings.plateInventory.sorted(by: { $0.weight > $1.weight }) {
            let maxCount = item.countPerSide ?? Int.max
            var count = 0
            while count < maxCount && remaining + 0.0001 >= item.weight {
                remaining -= item.weight
                count += 1
                result.append(item)
            }
        }

        return PlateCalculationResult(
            totalWeight: targetWeight,
            barWeight: barWeight,
            perSideWeight: perSide,
            platesPerSide: result,
            isAchievable: remaining < 0.25
        )
    }
}
