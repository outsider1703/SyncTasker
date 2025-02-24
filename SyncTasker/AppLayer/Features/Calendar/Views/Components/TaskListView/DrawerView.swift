//
//  DrawerView.swift
//  SyncTasker
//
//  Created by ingvar on 22.02.2025.
//

import SwiftUI

struct DrawerView: View {
    
    // MARK: - Private Properties
    
    @Binding private var offset: CGFloat
    @Binding private var position: DrawerPosition
    @Binding private var selectedSortOption: TaskSortOption
    @Binding private var selectedFilter: TaskFilterOption
    @Binding private var errorMessage: String?
    private var taskSections: [TaskGroupSection]
    private var navigateToTaskDetail: (TaskItem?) -> Void

    // MARK: - Initialization
    
    init(
        offset: Binding<CGFloat>,
        position: Binding<DrawerPosition>,
        selectedSortOption: Binding<TaskSortOption>,
        selectedFilter: Binding<TaskFilterOption>,
        errorMessage: Binding<String?>,
        taskSections: [TaskGroupSection],
        navigateToTaskDetail: @escaping (TaskItem?) -> Void
    ) {
        self._offset = offset
        self._position = position
        self._selectedSortOption = selectedSortOption
        self._selectedFilter = selectedFilter
        self._errorMessage = errorMessage
        self.taskSections = taskSections
        self.navigateToTaskDetail = navigateToTaskDetail
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            TaskListView(taskSections: taskSections,
                         selectedSortOption: $selectedSortOption,
                         selectedFilter: $selectedFilter,
                         errorMessage: $errorMessage,
                         navigateToTaskDetail: navigateToTaskDetail)
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
    
    // MARK: - Private Methods
    
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
