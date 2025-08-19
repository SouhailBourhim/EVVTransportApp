import Foundation

struct User: Codable {
    let username: String
    let routeId: String
    let driverName: String?
    let sessionId: String?

    init(username: String, routeId: String, driverName: String? = nil, sessionId: String? = nil) {
        self.username = username
        self.routeId = routeId
        self.driverName = driverName
        self.sessionId = sessionId
    }
}
