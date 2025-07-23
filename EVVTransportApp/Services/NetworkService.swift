// NetworkService placeholder 
import Foundation

class NetworkService: ObservableObject {
    static let shared = NetworkService()
    
    private let baseURL = Constants.API.baseURL
    
    private init() {}
    
    func login(username: String, password: String) async throws -> User {
        // Simulate network delay for realistic feel
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // TODO: Replace with actual API call to your IIS backend
        /*
        let url = URL(string: "\(baseURL)\(Constants.API.loginEndpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginData = ["username": username, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: loginData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidCredentials
        }
        
        let user = try JSONDecoder().decode(User.self, from: data)
        return user
        */
        
        // Mock login validation for development
        if !username.isEmpty && !password.isEmpty {
            return User(username: username, routeId: "ROUTE_\(username.uppercased())")
        } else {
            throw NetworkError.invalidCredentials
        }
    }
    
    func fetchPassengers() async throws -> [Passenger] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // TODO: Replace with actual API call to your IIS backend
        /*
        let url = URL(string: "\(baseURL)\(Constants.API.passengersEndpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Add authentication headers as needed
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.networkFailure
        }
        
        let passengers = try JSONDecoder().decode([Passenger].self, from: data)
        return passengers
        */
        
        // Mock data for development - replace with actual API response
        return [
            Passenger(
                recid: "001",
                name: "Maria Rodriguez",
                pickupLocation: "123 Grand Concourse, Bronx NY 10451",
                dropoffLocation: "456 Fordham Rd, Bronx NY 10458",
                scheduledPickup: "09:30 AM",
                scheduledDropoff: "10:15 AM",
                status: .pending,
                medicalNotes: "Wheelchair accessible required",
                contactInfo: "(555) 123-4567",
                wheelchairFlag: true
            ),
            Passenger(
                recid: "002",
                name: "James Thompson",
                pickupLocation: "789 Webster Ave, Bronx NY 10456",
                dropoffLocation: "321 E 149th St, Bronx NY 10451",
                scheduledPickup: "10:00 AM",
                scheduledDropoff: "10:45 AM",
                status: .pending,
                medicalNotes: "No special requirements",
                contactInfo: "(555) 987-6543",
                wheelchairFlag: false
            ),
            Passenger(
                recid: "003",
                name: "Sarah Johnson",
                pickupLocation: "555 Jerome Ave, Bronx NY 10452",
                dropoffLocation: "888 Third Ave, Bronx NY 10456",
                scheduledPickup: "08:45 AM",
                scheduledDropoff: "09:30 AM",
                status: .pickedUp,
                medicalNotes: "Hearing impaired",
                contactInfo: "(555) 456-7890",
                wheelchairFlag: false
            ),
            Passenger(
                recid: "004",
                name: "Robert Wilson",
                pickupLocation: "999 Melrose Ave, Bronx NY 10451",
                dropoffLocation: "111 East Tremont Ave, Bronx NY 10453",
                scheduledPickup: "11:15 AM",
                scheduledDropoff: "12:00 PM",
                status: .pending,
                medicalNotes: "Uses walker for mobility",
                contactInfo: "(555) 111-2222",
                wheelchairFlag: false
            ),
            Passenger(
                recid: "005",
                name: "Linda Garcia",
                pickupLocation: "777 Southern Blvd, Bronx NY 10454",
                dropoffLocation: "555 East 138th St, Bronx NY 10454",
                scheduledPickup: "10:30 AM",
                scheduledDropoff: "11:15 AM",
                status: .pickedUp,
                medicalNotes: "Diabetic - carries emergency kit",
                contactInfo: "(555) 333-4444",
                wheelchairFlag: false
            )
        ]
    }
    
    func updatePassengerStatus(_ statusUpdate: StatusUpdate) async throws {
        // TODO: Replace with actual API call to your IIS backend
        /*
        let url = URL(string: "\(baseURL)\(Constants.API.statusUpdateEndpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Add authentication headers as needed
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(statusUpdate)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.networkFailure
        }
        */
        
        // Simulate successful API call
        print("📡 Status Update Sent to Backend:")
        print("  Record ID: \(statusUpdate.recid)")
        print("  Status: \(statusUpdate.status)")
        print("  DateTime: \(statusUpdate.datetime)")
        print("  Location: \(statusUpdate.latitude), \(statusUpdate.longitude)")
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
    }
}

enum NetworkError: LocalizedError {
    case invalidCredentials
    case networkFailure
    case invalidResponse
    case unauthorized
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid username or password"
        case .networkFailure:
            return "Network connection failed. Please check your internet connection."
        case .invalidResponse:
            return "Invalid server response"
        case .unauthorized:
            return "Session expired. Please log in again."
        case .serverError:
            return "Server error. Please try again later."
        }
    }
}
