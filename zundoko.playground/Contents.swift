import Foundation
import Combine

let ずんどこ水源 =
    Timer.publish(every: 0.1, on: .main, in: .default)
        .autoconnect()
        .map { _ in Int.random(in:0..<2) == 0 ? "ずん" : "どこ" }
        .share()

let センサー付き水門 =
    ずんどこ水源
        .scan([], { (reservoir: [String], element: String) -> [String] in
            // 溜池
            var newReservoir = Array(reservoir + [element])
            if newReservoir.count > 5 {
                newReservoir.removeFirst()
            }
            return newReservoir.prefix(5).map { $0 }
        })
        .allSatisfy { $0 != ["ずん", "ずん", "ずん", "ずん", "どこ"] }
        .map { _ in  }
        .share()

let スピーカー = センサー付き水門.map { _ in "き・よ・し！" }
                            .handleEvents(receiveOutput: { _ in
                                print("（せーの...!）")
                            })
                            .delay(for: .seconds(1.0), scheduler: RunLoop.main)

let cancellable =
    ずんどこ水源
    .prefix(untilOutputFrom: センサー付き水門) // センサーが検知するまで、ずんどこを流す
    .merge(with: スピーカー) // 検知したら、き・よ・し！を流す
    .sink(receiveCompletion: { _ in
        print("===完===")
    }, receiveValue: {
        print("input: \($0)")
    })
