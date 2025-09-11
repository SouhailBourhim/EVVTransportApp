# EVVTransportApp - iOS Transportation Management App

## 📱 **App Overview**

EVVTransportApp is a comprehensive iOS application designed for transportation management, specifically for drivers to manage passenger pickups and drop-offs. The app provides real-time route management, GPS tracking, and seamless backend integration.

## 🏗️ **Technical Specifications**

- **Platform**: iOS 17.0+
- **Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Language**: Swift 5.9+
- **Xcode Version**: 15.0+
- **Deployment Target**: iOS 17.0

## 🚀 **Features**

### **Core Functionality**
- **User Authentication**: Secure login with backend validation
- **Route Management**: Real-time route overview and passenger management
- **GPS Integration**: Automatic location detection for status updates
- **Status Tracking**: Pick up and drop off passenger status management
- **Network Monitoring**: Real-time connectivity status
- **Offline Support**: Graceful handling of network interruptions

### **User Interface**
- **Modern Design**: Clean, intuitive SwiftUI interface
- **Dark Mode Support**: Full dark mode compatibility
- **Accessibility**: Large touch targets and readable fonts
- **Responsive Layout**: Optimized for all iPhone sizes
- **Status Indicators**: Color-coded passenger status (Green: Picked up, Blue: On bus, Red: Pending)

## 🔧 **Setup Instructions**

### **Prerequisites**
1. **Xcode 15.0+** installed on macOS
2. **Apple Developer Account** (for deployment)
3. **iOS 17.0+** device or simulator for testing

### **Installation Steps**

1. **Clone the Repository**
   ```bash
   git clone [repository-url]
   cd EVVTransportApp
   ```

2. **Open in Xcode**
   ```bash
   open EVVTransportApp.xcodeproj
   ```

3. **Configure Signing**
   - Select your development team in Xcode
   - Ensure "Automatically manage signing" is enabled
   - Update Bundle Identifier if needed

4. **Build and Run**
   - Select target device (iPhone or Simulator)
   - Press `Cmd + R` to build and run

## ⚙️ **Configuration**

### **API Configuration**
The app connects to the backend API. Update the following in `Constants.swift`:

```swift
struct API {
    static let baseURL = "https://advantecis-csmwebservicebus.com"  // ⚠️ CHANGE TO HTTPS
    static let loginEndpoint = "/business/login"
    static let passengersEndpoint = "/business/passengers"
    static let updateStatusEndpoint = "/business/updatestatus"
}
```

### **Bundle Configuration**
Update the following in Xcode project settings:
- **Bundle Identifier**: `com.yourcompany.EVVTransportApp`
- **Display Name**: Your preferred app name
- **Version**: 1.0 (1)

## 🔐 **Security Considerations**

### **Current Security Issues**
- ⚠️ **CRITICAL**: API uses HTTP instead of HTTPS
- **Action Required**: Update `baseURL` to use HTTPS before App Store submission

### **Security Features**
- **Keychain Storage**: Secure token storage
- **Network Security**: HTTPS communication (after configuration)
- **Data Validation**: Input sanitization and validation
- **Session Management**: Secure session handling

## 📱 **App Structure**

```
EVVTransportApp/
├── App/
│   ├── EVVTransportAppApp.swift          # Main app entry point
│   └── Assets.xcassets/                  # App icons and images
├── Models/
│   ├── User.swift                        # User data model
│   ├── Passenger.swift                   # Passenger data model
│   └── APIModels.swift                   # API request/response models
├── ViewModels/
│   ├── AuthViewModel.swift               # Authentication logic
│   └── RouteViewModel.swift              # Route management logic
├── Views/
│   ├── Authentication/
│   │   └── LoginView.swift               # Login screen
│   ├── Dashboard/
│   │   ├── DashboardView.swift           # Main route overview
│   │   ├── OnBusSectionView.swift        # On-bus passengers
│   │   ├── PendingPickupSectionView.swift # Pending pickups
│   │   └── PassengerCardView.swift       # Individual passenger card
│   └── PassengerDetail/
│       └── PassengerDetailView.swift     # Passenger details modal
├── Services/
│   ├── NetworkService.swift              # API communication
│   └── LocationService.swift             # GPS location handling
└── Utilities/
    ├── Constants.swift                   # App constants and configuration
    └── Extensions.swift                  # Utility extensions
```

## 🧪 **Testing**

### **Testing Checklist**
- [ ] **Login Flow**: Test with valid/invalid credentials
- [ ] **Network Scenarios**: Test with/without internet connection
- [ ] **Location Services**: Test GPS permission and location updates
- [ ] **Status Updates**: Test pickup/dropoff functionality
- [ ] **UI Elements**: Test all buttons, cards, and interactions
- [ ] **Dark Mode**: Test in both light and dark modes
- [ ] **Device Rotation**: Test in all orientations

### **Test Data**
The app uses mock data for development. Update `NetworkService.swift` to connect to your backend API.

## 🚀 **Deployment**

### **App Store Preparation**
1. **Update Bundle Identifier** to your company's domain
2. **Change API URL** to HTTPS
3. **Test on Physical Device** before submission
4. **Update App Icon** if needed
5. **Review App Store Guidelines** compliance

### **Build for App Store**
1. Select "Any iOS Device" as target
2. Product → Archive
3. Upload to App Store Connect
4. Submit for review

## 🐛 **Troubleshooting**

### **Common Issues**

**Build Errors:**
- Ensure Xcode 15.0+ is installed
- Clean build folder: `Product → Clean Build Folder`
- Check signing configuration

**Network Issues:**
- Verify API endpoints are accessible
- Check network connectivity
- Review API response format

**Location Issues:**
- Ensure location permissions are granted
- Test on physical device (simulator has limited GPS)

## 📞 **Support**

For technical support or questions:
- **Developer**: Souhail Bourhim & Badreddine Hamid
- **Email**: bourhimsouhail@gmail.com & badrhamid33@gmail.com
- **Repository**: https://github.com/SouhailBourhim/EVVTransportApp.git

---

**Last Updated**: December 2024
**Version**: 1.0
**iOS Compatibility**: 17.0+