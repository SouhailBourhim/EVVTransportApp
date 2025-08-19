import SwiftUI

struct PassengerDetailView: View {
    let passenger: Passenger
    @Environment(\.dismiss) private var dismiss
    @State private var showActionSheet = false
    @State private var selectedAction: ActionType?
    @State private var showMap = false
    @EnvironmentObject var routeViewModel: RouteViewModel
    
    enum ActionType: String, Identifiable {
        case call = "Call"
        case message = "Message"
        case email = "Email"
        case cancel = "Cancel"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .call: return "phone.fill"
            case .message: return "message.fill"
            case .email: return "envelope.fill"
            case .cancel: return "xmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .call: return .green
            case .message: return .blue
            case .email: return .purple
            case .cancel: return .red
            }
        }
    }
    
    private var statusColor: Color {
        switch passenger.status {
        case .pickedUp: return .green
        case .droppedOff: return .blue
        case .pending: return .orange
        }
    }
    
    private var statusIcon: String {
        switch passenger.status {
        case .pickedUp: return "checkmark.circle.fill"
        case .droppedOff: return "checkmark.shield.fill"
        case .pending: return "clock.fill"
        }
    }
    
    private var actionButtonTitle: String {
        switch passenger.status {
        case .pickedUp: return "MARK AS DROPPED OFF"
        case .droppedOff: return "MARK AS PENDING"
        case .pending: return "MARK AS PICKED UP"
        }
    }
    
    private var actionButtonColor: Color {
        switch passenger.status {
        case .pickedUp: return .blue
        case .droppedOff: return .gray
        case .pending: return .green
        }
    }
    
    private func handleStatusUpdate() {
        let newStatus: PassengerStatus = {
            switch passenger.status {
            case .pickedUp: return .droppedOff
            case .droppedOff: return .pending
            case .pending: return .pickedUp
            }
        }()
        
        Task {
            await routeViewModel.updatePassengerStatus(passenger, to: newStatus)
            // Only dismiss if the update was successful (no error)
            if routeViewModel.errorMessage.isEmpty {
                dismiss()
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with profile and status
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(maxWidth: .infinity)
                    VStack(spacing: 16) {
                        // Profile image or placeholder
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle()
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                            Text(passenger.name.prefix(1).uppercased())
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 24)
                        // Name and status
                        VStack(spacing: 8) {
                            Text(passenger.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            HStack(spacing: 6) {
                                Image(systemName: statusIcon)
                                    .foregroundColor(statusColor)
                                Text(passenger.status.rawValue.uppercased())
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Capsule().fill(statusColor))
                            }
                            .padding(.bottom, 8)
                        }
                        // Action buttons
                        HStack(spacing: 16) {
                            ActionButton(
                                icon: "phone.fill",
                                label: "Call",
                                color: .green,
                                action: { selectedAction = .call }
                            )
                            ActionButton(
                                icon: "message.fill",
                                label: "Message",
                                color: .blue,
                                action: { selectedAction = .message }
                            )
                            ActionButton(
                                icon: "map.fill",
                                label: "Map",
                                color: .orange,
                                action: { showMap = true }
                            )
                        }
                        .padding(.bottom, 16)
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                
                // Main content
                VStack(spacing: 24) {
                    // Trip Details Card
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "TRIP DETAILS", icon: "map")
                        
                        VStack(spacing: 12) {
                            InfoRow(
                                icon: "mappin.and.ellipse",
                                title: "Pickup Location",
                                value: passenger.pickupLocation,
                                color: .red
                            )
                            
                            Divider()
                                .padding(.leading, 32)
                            
                            InfoRow(
                                icon: "mappin",
                                title: "Drop-off Location",
                                value: passenger.dropoffLocation,
                                color: .blue
                            )
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Schedule Card - Not available from backend
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "SCHEDULE", icon: "clock")
                        
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                    .frame(width: 24, alignment: .center)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("SCHEDULE NOT AVAILABLE")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Scheduled times are not provided by the backend system")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Additional Information
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "ADDITIONAL INFORMATION", icon: "info.circle")
                        
                        VStack(spacing: 12) {
                            InfoRow(
                                icon: "number",
                                title: "Record ID",
                                value: passenger.recid,
                                color: .gray
                            )
                            
                            InfoRow(
                                icon: "building.2",
                                title: "City",
                                value: passenger.city,
                                color: .purple
                            )
                            
                            if let contactInfo = passenger.contactInfo, !contactInfo.isEmpty {
                                Divider()
                                    .padding(.leading, 32)
                                
                                InfoRow(
                                    icon: "phone",
                                    title: "Contact Info",
                                    value: contactInfo,
                                    color: .green
                                )
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    // Main Action Button
                    Button(action: handleStatusUpdate) {
                        HStack {
                            Spacer()
                            if routeViewModel.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Text(actionButtonTitle)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(actionButtonColor)
                        .cornerRadius(12)
                        .shadow(color: actionButtonColor.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .disabled(routeViewModel.isLoading)
                    .padding(.vertical, 24)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Passenger Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: $showMap) {
            // Map view would go here
            Text("Map View")
                .padding()
        }
        .actionSheet(item: $selectedAction) { action in
            ActionSheet(
                title: Text("Contact \(passenger.name.split(separator: " ").first ?? "Passenger")"),
                buttons: [
                    .default(Text(action.rawValue)) {
                        // Handle contact action
                    },
                    .cancel()
                ]
            )
        }
        .alert("Error", isPresented: $routeViewModel.showErrorAlert) {
            Button("OK") {
                routeViewModel.clearError()
            }
            if routeViewModel.showRetryButton {
                Button("Retry") {
                    Task {
                        await routeViewModel.retryLastOperation()
                    }
                }
            }
        } message: {
            Text(routeViewModel.errorMessage)
        }
    }
}

// MARK: - Subviews

private struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Spacer()
        }
    }
}

private struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(label)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

private struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, alignment: .center)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Preview

struct PassengerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PassengerDetailView(passenger: Passenger(
                recid: "12345",
                name: "John Doe",
                address: "123 Main St, Anytown, USA",
                status: .pending,
                contactInfo: "(555) 123-4567",
                gender: 1,
                city: "Anytown"
            ))
            .environmentObject(RouteViewModel())
        }
    }
}
