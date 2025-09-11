# EVVTransportApp - Deployment Guide

## 🚀 **Pre-Deployment Checklist**

### **Critical Requirements**
- [ ] **Bundle Identifier**: Update to client's domain
- [ ] **API Security**: Change HTTP to HTTPS
- [ ] **App Name**: Update to client's branding
- [ ] **Signing**: Configure with client's Apple Developer account
- [ ] **Testing**: Test on physical device

## 🔧 **Step-by-Step Deployment**

### **Step 1: Configure Project Settings**

1. **Open Xcode Project**
   ```bash
   open EVVTransportApp.xcodeproj
   ```

2. **Update Bundle Identifier**
   - Select project in navigator
   - Go to "Signing & Capabilities" tab
   - Change Bundle Identifier to: `com.clientcompany.EVVTransportApp`

3. **Update Display Name**
   - In project settings, change "Display Name" to client's preferred name

### **Step 2: Configure API Security**

1. **Open Constants.swift**
   ```swift
   // Change this line:
   static let baseURL = "http://advantecis-csmwebservicebus.com"
   
   // To this:
   static let baseURL = "https://advantecis-csmwebservicebus.com"
   ```

2. **Verify API Endpoints**
   - Ensure all endpoints support HTTPS
   - Test API connectivity

### **Step 3: Configure Signing**

1. **Select Development Team**
   - Go to "Signing & Capabilities"
   - Select client's Apple Developer team
   - Ensure "Automatically manage signing" is checked

2. **Verify Certificates**
   - Xcode will automatically generate certificates
   - Ensure no errors in signing section

### **Step 4: Build and Test**

1. **Clean Build**
   ```bash
   Product → Clean Build Folder
   ```

2. **Test on Device**
   - Connect physical iPhone
   - Select device as target
   - Build and run (`Cmd + R`)

3. **Test All Features**
   - Login functionality
   - Network connectivity
   - Location services
   - Status updates

### **Step 5: Archive for App Store**

1. **Select "Any iOS Device"**
   - In Xcode, select "Any iOS Device" as target

2. **Create Archive**
   - Product → Archive
   - Wait for build to complete

3. **Upload to App Store Connect**
   - Click "Distribute App"
   - Select "App Store Connect"
   - Follow upload wizard

### **Step 6: App Store Connect Configuration**

1. **App Information**
   - App Name: Client's preferred name
   - Bundle ID: `com.clientcompany.EVVTransportApp`
   - SKU: Unique identifier

2. **App Store Information**
   - Description: Transportation management app
   - Keywords: transportation, EVV, driver, route
   - Category: Business

3. **Screenshots**
   - iPhone screenshots required
   - TestFlight for testing

## 🔐 **Security Configuration**

### **Required Security Updates**

1. **HTTPS Implementation**
   ```swift
   // In Constants.swift
   static let baseURL = "https://advantecis-csmwebservicebus.com"
   ```

2. **App Transport Security**
   - Add to Info.plist if needed:
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <false/>
   </dict>
   ```

3. **Location Privacy**
   - Ensure location usage description is present
   - Test location permissions

## 📱 **Device Testing**

### **Test Devices Required**
- iPhone 15 Pro (latest)
- iPhone 14 (previous generation)
- iPhone SE (smaller screen)

### **Test Scenarios**
1. **Fresh Install**
   - Download from App Store
   - First launch experience
   - Permission requests

2. **Network Conditions**
   - WiFi connection
   - Cellular connection
   - No connection (offline mode)

3. **Location Services**
   - GPS enabled
   - GPS disabled
   - Location permission denied

## 🐛 **Common Issues and Solutions**

### **Build Issues**

**Error: "No matching provisioning profiles found"**
- Solution: Check Apple Developer account access
- Ensure team is selected correctly

**Error: "Code signing error"**
- Solution: Clean build folder and rebuild
- Check certificate validity

**Error: "Bundle identifier already exists"**
- Solution: Use unique bundle identifier
- Check App Store Connect for conflicts

### **Runtime Issues**

**App crashes on launch**
- Check device compatibility (iOS 17.0+)
- Review crash logs in Xcode

**Network requests fail**
- Verify API endpoints are accessible
- Check HTTPS configuration

**Location not working**
- Test on physical device
- Check location permissions

## 📊 **Performance Optimization**

### **Build Settings**
- **Optimization Level**: Release builds use `-O` optimization
- **Debug Information**: Strip debug symbols for release
- **Bitcode**: Enable for App Store compatibility

### **Memory Management**
- App uses SwiftUI's automatic memory management
- No manual memory management required
- Monitor for retain cycles in ViewModels

## 🔄 **Update Process**

### **For Future Updates**
1. **Version Number**: Increment in project settings
2. **Build Number**: Increment for each build
3. **Changelog**: Document changes
4. **Testing**: Test all functionality
5. **Archive**: Create new archive
6. **Upload**: Upload to App Store Connect

## 📞 **Support Contacts**

- **Technical Issues**: [Developer Contact]
- **Apple Developer Support**: [Apple Support]
- **App Store Review**: [App Store Connect]

---

**Last Updated**: December 2024
**Version**: 1.0
**Compatibility**: iOS 17.0+
