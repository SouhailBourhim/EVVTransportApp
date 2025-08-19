import SwiftUI

struct PassengerCardView: View {
    let passenger: Passenger
    let buttonTitle: String
    let buttonColor: Color
    let action: () -> Void
    let onTap: () -> Void
    @EnvironmentObject var routeViewModel: RouteViewModel
    
    private var isPickedUp: Bool {
        passenger.status == .pickedUp
    }
    
    private var location: String {
        isPickedUp ? passenger.dropoffLocation : passenger.pickupLocation
    }
    
    private var time: String {
        "N/A" // Backend doesn't provide scheduled times
    }
    
    private var timeIcon: String {
        "clock" // Generic clock icon since times are not available
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with name and status
            HStack(alignment: .top) {
                // Profile placeholder with initials
                ZStack {
                    Circle()
                        .fill(buttonColor.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Text(passenger.name.prefix(1).uppercased())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(buttonColor)
                }
                .padding(.trailing, 12)
                
                // Passenger info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(passenger.name)
                            .font(.headline)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Status indicator
                        HStack(spacing: 4) {
                            Circle()
                                .fill(isPickedUp ? Color.green : Color.orange)
                                .frame(width: 6, height: 6)
                            Text(isPickedUp ? "On Board" : "Pending")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isPickedUp ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                        .foregroundColor(isPickedUp ? .green : .orange)
                        .clipShape(Capsule())
                    }
                    
                    // Location info
                    HStack(alignment: .center, spacing: 6) {
                        Image(systemName: "mappin")
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(width: 16)
                        
                        Text(location)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.top, 2)
                    
                    // Time info
                    HStack(alignment: .center, spacing: 6) {
                        Image(systemName: timeIcon)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .frame(width: 16)
                        
                        Text(time)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
            
            // Action button
            Button(action: action) {
                HStack {
                    Spacer()
                    if routeViewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.white)
                    } else {
                        Text(buttonTitle.uppercased())
                            .font(.system(size: 14, weight: .semibold))
                            .kerning(0.5)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(buttonColor)
                .cornerRadius(12)
            }
            .disabled(routeViewModel.isLoading)
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            .onTapGesture {
                onTap()
            }
        }
    }
    
    
    // MARK: - Preview
    struct PassengerCardView_Previews: PreviewProvider {
        static var previews: some View {
            let samplePassenger = Passenger(
                recid: "001",
                name: "Maria Rodriguez",
                address: "123 Grand Concourse, Bronx NY 10451",
                status: .pending,
                contactInfo: "(555) 123-4567",
                gender: 1,
                city: "Bronx"
            )
            
            return PassengerCardView(
                passenger: samplePassenger,
                buttonTitle: "Mark as Picked Up",
                buttonColor: .blue,
                action: {},
                onTap: {}
            )
            .padding()
            .previewLayout(.sizeThatFits)
        }
    }
}
