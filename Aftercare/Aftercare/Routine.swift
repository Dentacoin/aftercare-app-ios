////
//// Aftercare
//// Created by Dimitar Grudev on 7.11.17.
//// Copyright © 2017 Stichting Administratiekantoor Dentacoin.
////
//
//import Foundation
//
//struct Routine {
//    
//    fileprivate static let Morning = RoutineType.MORNING(2, 11, [
//        Action.BRUSH_READY,
//        Action.BRUSH,
//        Action.BRUSH_DONE,
//        Action.RINSE_READY,
//        Action.RINSE,
//        Action.RINSE_DONE
//        ]
//    )//Morning routine from 2am to 11am
//    
//    fileprivate static let Evening = RoutineType.EVENING(17, 24, [
//        Action.FLOSS_READY,
//        Action.FLOSS,
//        Action.FLOSS_DONE,
//        Action.BRUSH_READY,
//        Action.BRUSH,
//        Action.BRUSH_DONE,
//        Action.RINSE_READY,
//        Action.RINSE,
//        Action.RINSE_DONE
//        ]
//    )//Evening routine from 17pm to 24pm
//    
////    private var fromHourOfDay: Int = 0
////    private var toHourOfDay: Int = 0
////    private var actions: [Action] = []
//    
//    static let all = [Morning, Evening]
//    
//}
//
////MARK: - Delegate
//
//protocol RoutineDelegate {
//    func onRoutineStart(routine: Routine)
//    func onRoutineStep(routine: Routine, action: Action)
//    func onRoutineEnd(routine: Routine)
//}
//
////MARK: - Enums
//
//enum RoutineType {
//    
//    case MORNING(Int, Int, [Action])
//    case EVENING(Int, Int, [Action])
//    
////    init(_ fromHourOfDay: Int, _ toHourOfDay: Int, _ actions: [Action]) {
////        self.fromHourOfDay = fromHourOfDay
////        self.toHourOfDay = toHourOfDay
////        self.actions = actions
////    }
//    
////    public func inTimeFrame(hour: Int) -> Bool {
////        .case RoutineType
////        return //hour >= fromHourOfDay && hour <= toHourOfDay
////    }
//
////    public func getActions() -> [Action] {
////        return actions
////    }
//}
//
//public enum Action {
//    case BRUSH_READY, BRUSH, BRUSH_DONE
//    case RINSE_READY, RINSE, RINSE_DONE
//    case FLOSS_READY, FLOSS, FLOSS_DONE
//}

