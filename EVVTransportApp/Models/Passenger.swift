// Passenger model placeholder 
import Foundation

struct Passenger: Identifiable, Codable {
    let id = UUID()
    let recid: String
    let name: String
    let pickupLocation: String
    let dropoffLocation: String
    let scheduledPickup: String
    let scheduledDropoff: String
    var status: PassengerStatus
    let medicalNotes: String?
    let contactInfo: String?
    let wheelchairFlag: Bool
    
    enum CodingKeys: String, CodingKey {
        case recid, name, pickupLocation, dropoffLocation
        case scheduledPickup, scheduledDropoff, status
        case medicalNotes, contactInfo, wheelchairFlag
    }
}

enum PassengerStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case pickedUp = "picked up"
    case droppedOff = "dropped off"
}
