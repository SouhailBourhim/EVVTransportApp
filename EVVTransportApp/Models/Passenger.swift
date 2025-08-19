import Foundation

struct Passenger: Identifiable, Codable {
    let id = UUID()
    let recid: String
    let name: String
    let address: String // Single address from backend
    var status: PassengerStatus
    let contactInfo: String?
    let gender: Int
    let city: String
    
    // Computed properties for UI
    var pickupLocation: String {
        address // Use the same address for both pickup and dropoff
    }
    
    var dropoffLocation: String {
        address // Use the same address for both pickup and dropoff
    }
    
    var scheduledPickup: String {
        "N/A" // Backend doesn't provide scheduled times
    }
    
    var scheduledDropoff: String {
        "N/A" // Backend doesn't provide scheduled times
    }
    
    var homeAddress: String? {
        address // Use the same address
    }
    
    // Remove fields that don't exist in backend
    // let medicalNotes: String? - REMOVED
    // let wheelchairFlag: Bool - REMOVED
    
    var displayPickupTime: String {
        "N/A" // Backend doesn't provide scheduled times
    }
    
    var displayDropoffTime: String {
        "N/A" // Backend doesn't provide scheduled times
    }
    
    var hasSpecialNeeds: Bool {
        false // Backend doesn't provide special needs information
    }
    
    enum CodingKeys: String, CodingKey {
        case recid, name, address, status, contactInfo, gender, city
    }
    
    // MARK: - Validation Methods
    
    func isValid() -> Bool {
        return !recid.isEmpty && 
               !name.isEmpty && 
               !address.isEmpty
    }
    
    func hasValidContactInfo() -> Bool {
        return contactInfo != nil && !(contactInfo?.isEmpty ?? true)
    }
    
    func hasValidHomeAddress() -> Bool {
        return !address.isEmpty
    }
    
    // Remove validation for fields that don't exist
    // func hasValidMedicalNotes() -> Bool - REMOVED
}

enum PassengerStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case pickedUp = "picked up"
    case droppedOff = "dropped off"
}
