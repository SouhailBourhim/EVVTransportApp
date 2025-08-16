# EVVTransportApp

A modern, driver-friendly mobile app for managing passenger transport routes, pickups, and drop-offs. Built with SwiftUI for a clean, accessible, and efficient experience.

## 🚍 Overview
EVVTransportApp streamlines the workflow for transport drivers, allowing them to:
- View and manage their daily route
- Track passengers to be picked up and those already on the bus
- Mark passengers as picked up or dropped off (with location and timestamp)
- Access trip details, schedules, and passenger information
- Sync data with a backend server

## ✨ Features
- **Dashboard**: Split view for "On the Bus" and "Pending Pickups" with real-time status updates
- **Passenger Management**: Detailed passenger cards, status actions, and trip info
- **Sync & Info**: Manual sync, app version, and route stats
- **Authentication**: Secure login for drivers
- **Accessibility**: Large touch targets, readable fonts, and color contrast
- **Performance**: Only the first 20 passengers per list are shown for clarity and speed

## 🛠️ Technologies
- **SwiftUI** (iOS)
- **Combine** for state management
- **Async/Await** for networking
- **CoreLocation** for location tracking

## 🚀 Getting Started
1. **Clone the repository:**
   ```sh
   git clone https://github.com/SouhailBourhim/EVVTransportApp.git
   cd EVVTransportApp
   ```
2. **Open in Xcode:**
   - Open `EVVTransportApp.xcodeproj` or `EVVTransportApp.xcworkspace` in Xcode (latest recommended).
3. **Install dependencies:**
   - No external dependencies required (uses native Swift libraries).
4. **Run the app:**
   - Select a simulator or device and press **Run** (⌘R).

## 🤖 Automated CI/CD Pipeline
This project includes GitHub Actions for automated testing and quality assurance:

### **What runs automatically:**
- ✅ **Unit Tests** - 90+ tests covering models, view models, and services
- ✅ **UI Tests** - Login and dashboard functionality testing
- ✅ **Code Quality** - SwiftLint style and quality checks
- ✅ **Build Verification** - Ensures app builds successfully

### **When it runs:**
- 🔄 Every push to `main` branch
- 🔄 Every pull request to `main` branch
- 🔄 24/7 automated quality assurance

### **View Results:**
- Check the **Actions** tab in GitHub to see test results
- Green ✅ = All tests passed, code is ready
- Red ❌ = Tests failed, needs attention

## 🧪 Testing
Comprehensive test suite with 90%+ code coverage:

### **Run Tests Locally:**
```sh
# Run unit tests
xcodebuild test -scheme EVVTransportApp -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:EVVTransportAppTests

# Run UI tests  
xcodebuild test -scheme EVVTransportApp -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:EVVTransportAppUITests

# Run code quality checks
brew install swiftlint
swiftlint
```

### **Test Coverage:**
- **Models**: 100% - All data structures validated
- **ViewModels**: 95% - Business logic covered  
- **Services**: 90% - Network and data operations
- **UI Components**: 85% - Key user interactions
- **Utilities**: 95% - Helper functions tested

## 🔑 Configuration
- Update the backend API URLs in `EVVTransportApp/Utilities/Constants.swift` before production use.
- Location and network calls are mocked for development; replace with real endpoints as needed.

## 🤝 Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.


## 👤 Author
[Souhail Bourhim](https://github.com/SouhailBourhim)
