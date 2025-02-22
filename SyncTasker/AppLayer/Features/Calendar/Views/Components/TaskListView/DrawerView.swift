//
//  DrawerView.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct DrawerView: View {
    
    // MARK: - Properties
    
    @Binding var offset: CGFloat
    @Binding var position: DrawerPosition
    @State private var lastDragValue: CGFloat = 0
    var taskSections: [TaskGroupSection]
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            TaskListView(taskSections: taskSections)
                .frame(width: UIScreen.main.bounds.width)
                .frame(maxHeight: .infinity)
                .ignoresSafeArea()
                .background(Color.white)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = min(DrawerPosition.closed.offset, max(DrawerPosition.open.offset, getStartOffset() + value.translation.width))
                        }
                        .onEnded { value in
                            let velocity = value.predictedEndTranslation.width
                            let nextPosition = calculateNextPosition(velocity: velocity)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                position = nextPosition
                                offset = nextPosition.offset
                            }
                        }
                )
        }
    }
    
    // MARK: - Helper Functions
    
    private func getStartOffset() -> CGFloat {
        position.offset
    }
    
    private func calculateNextPosition(velocity: CGFloat) -> DrawerPosition {
        let currentOffset = offset
        
        // Учитываем скорость свайпа
        if abs(velocity) > 500 {
            return velocity > 0 ? .closed : .open
        }
        
        // Определяем ближайшую позицию
        let positions = [DrawerPosition.closed, .mid, .open]
        return positions.min(by: { abs($0.offset - currentOffset) < abs($1.offset - currentOffset) }) ?? .closed
    }
}
