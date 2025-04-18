//
//  CameraButton.swift
// IRealApp
//
//  Created by Nicolas Laurent on 18/04/2025.
//

import SwiftUI


struct RoundLongPressButton: View {
    let actionCourte: () -> Void
    let actionLongueStarted: () -> Void
    let actionLongueFinish: (Double) -> Void

    @State private var pressStartTime: Date?
    @State private var timerProgress: Double = 0
    @State private var timer: Timer?
    @State private var longPressWorkItem: DispatchWorkItem?

    // distinguer clic rapide et long
    private let tapThreshold: TimeInterval = 0.3
    // Durée max
    private let maxLongPressDuration: TimeInterval = 15.0

    var body: some View {
        let drag = DragGesture(minimumDistance: 0)
            .onChanged { _ in
                if pressStartTime == nil {
                    pressStartTime = Date()
                    timerProgress = 0

                    let workItem = DispatchWorkItem {
                        actionLongueStarted()
                        // Démarrer le timer d'avancement
                        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { t in
                            guard let start = pressStartTime else { return }
                            let elapsed = Date().timeIntervalSince(start)
                            timerProgress = min(elapsed / maxLongPressDuration, 1)
                            if elapsed >= maxLongPressDuration {
                                t.invalidate()
                                pressStartTime = nil
                                actionLongueFinish(maxLongPressDuration)
                            }
                        }
                    }
                    longPressWorkItem = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + tapThreshold, execute: workItem)
                }
            }
            .onEnded { _ in
                // Annuler la tâche de long press si pas atteinte
                longPressWorkItem?.cancel()
                timer?.invalidate()

                guard let start = pressStartTime else { return }
                let elapsed = Date().timeIntervalSince(start)

                pressStartTime = nil
                timerProgress = 0

                if elapsed < tapThreshold {
                    actionCourte()
                } else {
                    actionLongueFinish(min(elapsed, maxLongPressDuration))
                }
            }

        ZStack {
            Circle()
                .fill(Color.white.opacity(0.2))
                .stroke(Color.white.opacity(1.0), lineWidth: 3)
            
            
            Circle()
                .trim(from: 0, to: CGFloat(timerProgress))
                .stroke(Color.white.opacity(1.0), lineWidth: 7)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.01), value: timerProgress)
            
            
            Image(systemName: "plus.viewfinder")
                .font(.largeTitle)
                .imageScale(.medium)
                .foregroundColor(.white)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .gesture(drag)
    }
}

// MARK: Preview

struct RoundLongPressButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundLongPressButton(
            actionCourte: { print("Clic rapide") },
            actionLongueStarted: { print("Long press started") },
            actionLongueFinish: { durée in print("Long press terminée après \(durée)s") }
        )
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
}
