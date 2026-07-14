import SwiftUI
import AppKit

struct RegistrationView: View {
    @Environment(AppStore.self) var store
    @State private var showCountryPicker = false
    @State private var searchText = ""
    @State private var animateIn = false
    
    var filteredCountries: [CountryCode] {
        if searchText.isEmpty { return CountryCode.all }
        return CountryCode.all.filter {
            $0.name.contains(searchText) || $0.code.contains(searchText) || $0.id.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.15),
                    Color(red: 0.05, green: 0.05, blue: 0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo area
                VStack(spacing: 12) {
                    Image(systemName: "message.and.waveform.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .symbolEffect(.bounce, options: .repeat(2), value: animateIn)
                    
                    Text("AI Chat")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("与所有 AI 模型对话")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 48)
                
                // Registration card
                VStack(spacing: 24) {
                    Text("电话号码验证")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                    
                    // Country code picker
                    Button(action: { showCountryPicker = true }) {
                        HStack {
                            Text(store.selectedCountry.flag)
                                .font(.title2)
                            Text(store.selectedCountry.code)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    // Phone number
                    HStack {
                        Text(store.selectedCountry.code)
                            .foregroundColor(.gray)
                            .fontWeight(.medium)
                        TextField("", text: $store.phoneNumber, prompt: Text("手机号码").foregroundColor(.gray.opacity(0.6)))
                            .textFieldStyle(.plain)
                            .foregroundColor(.white)
                            .font(.body)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    
                    if store.sentCode {
                        // Verification code
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(.cyan)
                            TextField("", text: $store.verificationCode, prompt: Text("验证码").foregroundColor(.gray.opacity(0.6)))
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                                .font(.body)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Action button
                    Button(action: {
                        if !store.sentCode {
                            withAnimation(.spring(response: 0.4)) {
                                store.sendVerificationCode()
                            }
                        } else {
                            store.verifyCode()
                        }
                    }) {
                        HStack {
                            if store.isVerifying {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .tint(.white)
                            } else {
                                Image(systemName: store.sentCode ? "checkmark.shield" : "paperplane.fill")
                                Text(store.sentCode ? "验证" : "发送验证码")
                            }
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    .disabled(store.phoneNumber.isEmpty || store.isVerifying)
                    .opacity(store.phoneNumber.isEmpty ? 0.5 : 1)
                    
                    if store.sentCode {
                        Text("验证码已发送至 \(store.selectedCountry.code) \(store.phoneNumber)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 32)
                .offset(y: animateIn ? 0 : 20)
                .opacity(animateIn ? 1 : 0)
                
                Spacer()
                
                // Footer
                Text("注册即表示同意服务条款和隐私政策")
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateIn = true
            }
        }
        .sheet(isPresented: $showCountryPicker) {
            countryPickerSheet
        }
    }
    
    private var countryPickerSheet: some View {
        VStack(spacing: 0) {
            HStack {
                Text("选择国家/地区")
                    .font(.headline)
                Spacer()
                Button("取消") { showCountryPicker = false }
                    .buttonStyle(.plain)
                    .foregroundColor(.cyan)
            }
            .padding()
            
            SearchField(text: $searchText, placeholder: "搜索国家或区号")
                .padding(.horizontal)
                .padding(.bottom, 8)
            
            Divider()
            
            List(filteredCountries) { country in
                Button(action: {
                    store.selectedCountry = country
                    showCountryPicker = false
                }) {
                    HStack {
                        Text(country.flag)
                            .font(.title2)
                        Text(country.name)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(country.code)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                        if country.id == store.selectedCountry.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.cyan)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
        }
        .frame(width: 360, height: 480)
    }
}

struct SearchField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String
    
    func makeNSView(context: Context) -> NSSearchField {
        let searchField = NSSearchField()
        searchField.placeholderString = placeholder
        searchField.delegate = context.coordinator
        searchField.bezelStyle = .roundedBezel
        return searchField
    }
    
    func updateNSView(_ nsView: NSSearchField, context: Context) {
        nsView.stringValue = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSSearchFieldDelegate {
        var parent: SearchField
        init(_ parent: SearchField) { self.parent = parent }
        
        func controlTextDidChange(_ obj: Notification) {
            if let field = obj.object as? NSSearchField {
                parent.text = field.stringValue
            }
        }
    }
}

