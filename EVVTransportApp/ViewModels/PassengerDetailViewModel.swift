import SwiftUI

@MainActor
class PassengerDetailViewModel: ObservableObject {
    @Published var passenger: Passenger
    
    init(passenger: Passenger) {
        self.passenger = passenger
    }
}
