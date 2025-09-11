import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case username, password
    }
    
    // ScrollView reader for keyboard handling
    @Namespace private var scrollSpace
    
    var body: some View {
        ZStack {
            // Enhanced Background Gradient - Dark Mode Compatible
            LinearGradient(
                gradient: Gradient(colors: [
                    Constants.UI.Colors.primaryBlue.opacity(0.3),
                    Constants.UI.Colors.primaryBlue.opacity(0.1),
                    Constants.UI.Colors.background.opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            // Scrollable Content
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                    // Top Spacer for centering when keyboard is hidden
                    Spacer(minLength: 60)
                    
                    // Centered Content Container
                    VStack(spacing: 32) {
                        // Logo and Branding
                        VStack(spacing: 20) {
                            // Enhanced Logo
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Constants.UI.Colors.primaryBlue.opacity(0.2), Constants.UI.Colors.primaryBlue.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .shadow(color: Constants.UI.Colors.primaryBlue.opacity(0.2), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "bus.fill")
                                    .font(.system(size: 45, weight: .medium))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Constants.UI.Colors.primaryBlue, Constants.UI.Colors.primaryBlue.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            
                            // Enhanced Typography
                            VStack(spacing: 8) {
                                Text("EVV Transport")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(Constants.UI.Colors.primaryText)
                                
                                Text("Driver Portal")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Constants.UI.Colors.secondaryText)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(Constants.UI.Colors.primaryBlue.opacity(0.1))
                                    .cornerRadius(20)
                            }
                        }
                        
                        // Form Container
                        VStack(spacing: 24) {
                            // Username Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Constants.UI.Colors.primaryText)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(Constants.UI.Colors.primaryBlue)
                                    
                                    TextField("Enter your username", text: $username)
                                        .font(.system(size: 16))
                                        .textFieldStyle(.plain)
                                        .focused($focusedField, equals: .username)
                                        .submitLabel(.next)
                                        .onSubmit { focusedField = .password }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Constants.UI.Colors.background)
                                        .shadow(color: Constants.UI.Colors.primaryText.opacity(0.08), radius: 8, x: 0, y: 4)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .username ? Constants.UI.Colors.primaryBlue.opacity(0.3) : Color.clear, lineWidth: 2)
                                )
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Constants.UI.Colors.primaryText)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(Constants.UI.Colors.primaryBlue)
                                    
                                    if isPasswordVisible {
                                        TextField("Enter your password", text: $password)
                                            .font(.system(size: 16))
                                    } else {
                                        SecureField("Enter your password", text: $password)
                                            .font(.system(size: 16))
                                    }
                                    
                                    Button(action: { isPasswordVisible.toggle() }) {
                                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Constants.UI.Colors.secondaryText)
                                            .frame(width: 24, height: 24)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Constants.UI.Colors.background)
                                        .shadow(color: Constants.UI.Colors.primaryText.opacity(0.08), radius: 8, x: 0, y: 4)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(focusedField == .password ? Constants.UI.Colors.primaryBlue.opacity(0.3) : Color.clear, lineWidth: 2)
                                )
                                .focused($focusedField, equals: .password)
                            }
                        }
                        
                        // Error Message
                        if !authViewModel.errorMessage.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                                
                                Text(authViewModel.errorMessage)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.red.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.red.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .transition(.opacity.combined(with: .scale))
                        }
                        
                        // Enhanced Login Button
                        Button(action: {
                            // Add haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            login()
                        }) {
                            HStack(spacing: 12) {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Constants.UI.Colors.buttonText))
                                        .scaleEffect(0.9)
                                } else {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 18))
                                }
                                
                                Text(authViewModel.isLoading ? "Signing In..." : "Sign In")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Constants.UI.Colors.primaryBlue,
                                        Constants.UI.Colors.primaryBlue.opacity(0.8)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(Constants.UI.Colors.buttonText)
                            .cornerRadius(14)
                            .shadow(color: Constants.UI.Colors.primaryBlue.opacity(0.4), radius: 12, x: 0, y: 6)
                            .scaleEffect(authViewModel.isLoading ? 0.98 : 1.0)
                            .opacity(authViewModel.isLoading ? 0.8 : 1.0)
                        }
                        .disabled(authViewModel.isLoading || username.isEmpty || password.isEmpty)
                        .opacity((username.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: Constants.UI.Colors.primaryText.opacity(0.1), radius: 20, x: 0, y: 10)
                    )
                    .padding(.horizontal, 20)
                    .id(scrollSpace)
                    
                    // Bottom Spacer for keyboard space
                    Spacer(minLength: keyboardHeight > 0 ? keyboardHeight + 20 : 100)
                }
                .frame(minHeight: UIScreen.main.bounds.height)
                }
                .scrollIndicators(.hidden)
                .onChange(of: focusedField) { oldValue, newValue in
                    if newValue != nil {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(scrollSpace, anchor: .center)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onTapGesture {
            focusedField = nil
        }
        .onAppear {
            setupKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
        }
        .overlay(
            // Success Message Toast
            Group {
                if authViewModel.showSuccessMessage {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            
                            Text(authViewModel.successMessage)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Constants.UI.Colors.cardBackground)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 50)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: authViewModel.showSuccessMessage)
                    }
                }
            }
        )
    }
    
    private func login() {
        if !username.isEmpty && !password.isEmpty {
            Task {
                await authViewModel.login(username: username, password: password)
            }
        }
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            keyboardHeight = 0
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

#Preview("Light Mode") {
    LoginView()
        .environmentObject(AuthViewModel())
}

#Preview("Dark Mode") {
    LoginView()
        .environmentObject(AuthViewModel())
        .preferredColorScheme(.dark)
}
