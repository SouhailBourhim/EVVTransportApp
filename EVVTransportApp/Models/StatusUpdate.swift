import Foundation

struct StatusUpdate: Codable {
    let recid: String
    let status: String
    let datetime: String
    let latitude: Double
    let longitude: Double
    let driverId: String?
    let routeId: String?
    
    init(recid: String, status: String, latitude: Double, longitude: Double, driverId: String? = nil, routeId: String? = nil) {
        self.recid = recid
        self.status = status
        self.datetime = ISO8601DateFormatter().string(from: Date())
        self.latitude = latitude
        self.longitude = longitude
        self.driverId = driverId
        self.routeId = routeId
    }
    
    // MARK: - Validation
    
    var isValid: Bool {
        return !recid.isEmpty &&
               !status.isEmpty &&
               !datetime.isEmpty &&
               latitude >= -90 && latitude <= 90 &&
               longitude >= -180 && longitude <= 180
    }
    
    var isLocationValid: Bool {
        return latitude != 0.0 && longitude != 0.0 &&
               latitude >= -90 && latitude <= 90 &&
               longitude >= -180 && longitude <= 180
    }
}
