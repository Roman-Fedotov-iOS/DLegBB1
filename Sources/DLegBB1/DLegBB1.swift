import SwiftUI
import UIKit
import StoreKit
import CoreHaptics
import AVFoundation
import CoreData
import MediaPlayer
import ApphudSDK
import Combine

public enum Tab: String {
    case Home = "homeTabIcon"
    case Search = "searchTabIcon"
    case MySongs = "mySongsTabIcon"
}

public enum LinksConstants {
    public static let privacy = "https://sites.google.com/view/bassbooster-privacy-policy"
    public static let terms = "https://sites.google.com/view/bassbooster-terms-of-use"
    public static let share = "https://itunes.apple.com/app/id6738697391"
    public static let support = "nancycastillo56789@outlook.com"
}

public enum OnboardingState {
    case step1, step2, step3, paywall
}

public struct OnBoardingStep {
    public let image, title, description: String

    public init(image: String, title: String, description: String) {
        self.image = image
        self.title = title
        self.description = description
    }
}

public struct SplashView: View {
    public var image: String

    public init(image: String) {
        self.image = image
    }

    public var body: some View {
        ZStack {
            if #available(iOS 14.0, *) {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#1c0d00") ?? .black, Color(hex: "#000000") ?? .black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
            VStack {
                Spacer()
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                Text("BASS BOOSTER")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .multilineTextAlignment(.center)
                Spacer()
                CircleLoader()
                    .frame(width: 40, height: 40)
            }
            .padding(.bottom, 56)
        }
    }
}

public struct CircleLoader: View {
    public let trackerRotation: Double = 2
    public let animationDuration: Double = 0.75

    @State public var isAnimating: Bool = false
    @State public var circleStart: CGFloat = 0.17
    @State public var circleEnd: CGFloat = 0.6

    @State public var rotationDegree: Angle = Angle.degrees(0)

    public var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .trim(from: circleStart, to: circleEnd)
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#A63103") ?? .black,
                                                    Color(hex: "#FF6504") ?? .black,
                                                    Color(hex: "#FFFF0C") ?? .black]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .rotationEffect(self.rotationDegree)
            }.frame(width: 40, height: 40)
                .onAppear() {
                    self.animateLoader()
                    Timer.scheduledTimer(withTimeInterval: 1.4, repeats: true) { (mainTimer) in
                        self.animateLoader()
                    }
                }
        }
    }

    public func getRotationAngle() -> Angle {
        return .degrees(360 * self.trackerRotation) + .degrees(120)
    }

    public func animateLoader() {
        withAnimation(Animation.easeInOut(duration: self.trackerRotation * self.animationDuration)) {
            self.rotationDegree += self.getRotationAngle()
        }
    }
}

public extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}

public extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexValue = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexValue.hasPrefix("#") {
            hexValue.remove(at: hexValue.startIndex)
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexValue).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}


public struct OnboardingStepView: View {
    @State private var isAnimating = false
    let step: OnBoardingStep
    let action: () -> Void
    let stepIndex: Int
    @State var showTabBar: Bool
    
    public var body: some View {
        if #available(iOS 14.0, *) {
            ZStack {
                if #available(iOS 14.0, *) {
                    Image(step.image)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                } else {
                    // Fallback on earlier versions
                }
                
                VStack(spacing: UIScreen.main.bounds.height <= 667 ? 10:25) {
                    
                    Spacer()
                    
                    VStack(spacing: 5) {
                        if #available(iOS 15.0, *) {
                            Text(step.title)
                                .font(.system(size: 30, weight: .bold))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)
                        } else {
                            // Fallback on earlier versions
                        }
                        Text(step.description)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .opacity(0.7)
                    }
                    Button(action: {
                        let impactMed = UIImpactFeedbackGenerator(style: .light)
                        impactMed.impactOccurred()
                        action()
                    }) {
                        ZStack {
                            Text("Continue")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                            
                            HStack {
                                Spacer()
                                Image(systemName: "arrow.forward")
                                    .foregroundColor(.white)
                                    .padding(.trailing, 20)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        
                        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#A63103") ?? .black,
                                                                               Color(hex: "#FF6504") ?? .black,
                                                                               Color(hex: "#FFFF0C") ?? .black]),
                                                   
                                                   startPoint: .top,
                                                   endPoint: .bottom))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .scaleEffect(isAnimating ? 1 : 0.9)
                        .animation(
                            Animation.easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                    }
                    .onAppear { isAnimating = true }
                }
                .padding(.bottom, UIScreen.main.bounds.height <= 667 ? 140:90)
            }
            .fullScreenCover(isPresented: $showTabBar) {
                TabBarView()
            }
        } else {
            // Fallback on earlier versions
        }
    }
}


public struct OnboardingView: View {
    @State private var showTabBar = false
    @State private var currentStep: OnboardingState = .step1

    private let onBoardingSteps = [
        OnBoardingStep(image: "onboardingImage1", title: "Enhance your music\nexperience", description: "Feel the depth of your track with\nthe bass booster application"),
        OnBoardingStep(image: "onboardingImage2", title: "Boost bass\nwith no limits", description: "Boost the bass and experience\nextremely new level of sound!"),
        OnBoardingStep(image: "onboardingImage3", title: "Personalize your\nfavorite track", description: "Customize the sound and discover\ndifferent vibes of your song!")
    ]

    // Public initializer
    public init() {}

    public var body: some View {
        VStack {
            switch currentStep {
            case .step1:
                OnboardingStepView(step: onBoardingSteps[0], action: { currentStep = .step2 }, stepIndex: 0, showTabBar: false)
            case .step2:
                OnboardingStepView(step: onBoardingSteps[1], action: { currentStep = .step3 }, stepIndex: 1, showTabBar: false)
            case .step3:
                OnboardingStepView(step: onBoardingSteps[2], action: { currentStep = .paywall }, stepIndex: 2, showTabBar: false)
            case .paywall:
                PaywallView(showTabBar: false)
            }
        }
    }
}

public struct PaywallView: View {
    @State private var isAnimating = false
    @Environment(\.dismiss) var dismiss
    @State var showTabBar: Bool
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var apphudProducts: [ApphudProduct] = []
    @State private var hasShownTabbar: Bool = UserDefaults.standard.bool(forKey: "HasShownTabbar")
    
    public init(showTabBar: Bool) {
        self._showTabBar = State(initialValue: showTabBar)
    }
    
    public var body: some View {
        ZStack {
            Image("premiumImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: UIScreen.main.bounds.height <= 667 ? 10:25) {
                HStack {
                    Button(action: {
                        if hasShownTabbar {
                            dismiss()
                        } else {
                            showTabBar = true
                        }
                    }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15, height: 15)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(25)
                .padding(.top, 40)
                .opacity(0.8)
                Spacer()
                
                VStack(spacing: 5) {
                    Text("Unlock Full Access to all the features")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    if apphudProducts.isEmpty {
                        Text("loading products...")
                            .font(.system(size: 17, weight: .light))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .opacity(0.7)
                    } else {
                        Text(apphudProducts[0].productId.contains("trial") ?
                             "Start to continue App \nwith a 3-day trial and \(String(format: "$%.02f", apphudProducts[0].skProduct!.price.doubleValue)) per week" :
                                "Start to continue App \nfor \(String(format: "$%.02f", apphudProducts[0].skProduct!.price.doubleValue)) per week"
                        )
                        .font(.system(size: 16, weight: .regular))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 13)
                        .foregroundColor(Color(hex: "777979"))
                        .lineLimit(2)
                        .frame(width: UIScreen.main.bounds.width / 1.5)
                        .minimumScaleFactor(0.7)
                    }
                }
                
                Button(action: {
                    if !apphudProducts.isEmpty {
                        Apphud.purchase(apphudProducts[0]) { result in
                            if result.success {
                                UserDefaults.standard.set(true, forKey: "HasShownTabbar")
                                showTabBar.toggle()
                            }
                        }
                }
                }) {
                    ZStack {
                        Text("Continue")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                        
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.forward")
                                .foregroundColor(.white)
                                .padding(.trailing, 20)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    
                    .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#A63103") ?? .black,
                                                                           Color(hex: "#FF6504") ?? .black,
                                                                           Color(hex: "#FFFF0C") ?? .black]),
                                               
                                               startPoint: .top,
                                               endPoint: .bottom))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .scaleEffect(isAnimating ? 1 : 0.9)
                    .animation(
                        Animation.easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                }
                .onAppear { isAnimating = true }
                
                HStack {
                    HStack(spacing: 40) {
                        Link("Terms", destination: URL(string: LinksConstants.terms)!)
                            .foregroundColor(Color.white)
                            .font(.system(size: 12))
                        Link("Privacy", destination: URL(string: LinksConstants.privacy)!)
                            .foregroundColor(Color.white)
                            .font(.system(size: 12))
                        Button {
                            Apphud.restorePurchases { result1, result2, error in
                                if error != nil {
                                    DispatchQueue.main.async {
                                        showAlert(title: "Error", message: error!.localizedDescription)
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        showAlert(title: "Restored", message: "Purchases restored successfully.")
                                    }
                                }
                            }
                        } label: {
                            Text("Restore")
                                .foregroundColor(Color.white)
                                .font(.system(size: 12))
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showTabBar, content: {
                TabBarView()
            })
            .onChange(of: showTabBar) { newValue in
                if newValue {
                    UserDefaults.standard.set(true, forKey: "HasShownTabbar")
                }
            }
//            .onAppear {
//                Apphud.paywallsDidLoadCallback { paywalls in
//                    if let paywall = paywalls.first(where: { $0.identifier == (UserDefaults.standard.bool(forKey: "HasShownTabbar") ? "inapp_paywall" : "onboarding_paywall") }) {
//                        apphudProducts = paywall.products
//                    }
//                }
//            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .padding(.bottom, UIScreen.main.bounds.height <= 667 ? 100:50)
        }
    }
    private func showAlert(title: String, message: String) {
        self.alertTitle = title
        self.alertMessage = message
        self.showAlert = true
    }
}
    
public struct SettingsView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#1c0d00") ?? .black, Color(hex: "#000000") ?? .black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack {
                HStack {
                    CustomBackButton(dismiss: self.dismiss)
                    Spacer()
                    Text("Settings")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                    CustomBackButton(dismiss: self.dismiss)
                        .opacity(0)
                        .disabled(true)
                }
                .background(Color(hex: "#292929").ignoresSafeArea(.container, edges: .top))
 
                VStack(spacing: 12) {
                    Button(action: {
                        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                            DispatchQueue.main.async {
                                SKStoreReviewController.requestReview(in: scene)
                            }
                        }
                    }) {
                        HStack {
                            Image("rateUsIcon")
                                .frame(width: 25, height: 25)
                                .padding(.leading, 10)
                            Text("Rate Our App")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            Spacer()
                            Image("arrowBlueIcon")
                                .padding(.horizontal)
                        }
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                        .background(.white.opacity(0.2))
                    
                    Button(action: {
                        SupportEmailService().send(toAddress: LinksConstants.support)
                    }) {
                        HStack {
                            Image("contactUsIcon")
                                .frame(width: 25, height: 25)
                                .padding(.leading, 10)
                            Text("Contact Us")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            Spacer()
                            Image("arrowBlueIcon")
                                .padding(.horizontal)
                        }
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                        .background(.white.opacity(0.2))
                    
                    Button(action: {
                        if let privacyURL = URL(string: LinksConstants.privacy) {
                            if UIApplication.shared.canOpenURL(privacyURL) {
                                UIApplication.shared.open(privacyURL, options: [:], completionHandler: nil)
                            }
                        }
                    }) {
                        HStack {
                            Image("privacyIcon")
                                .frame(width: 25, height: 25)
                                .padding(.leading, 10)
                            Text("Privacy Policy")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            Spacer()
                            Image("arrowBlueIcon")
                                .padding(.horizontal)
                        }
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)

                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Divider()
                        .background(.white.opacity(0.2))
                    
                    Button(action: {
                        if let termsURL = URL(string: LinksConstants.terms) {
                            if UIApplication.shared.canOpenURL(termsURL) {
                                UIApplication.shared.open(termsURL, options: [:], completionHandler: nil)
                            }
                        }
                    }) {
                        HStack {
                            Image("termsIcon")
                                .frame(width: 25, height: 25)
                                .padding(.leading, 10)
                            Text("Terms Of Use")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            Spacer()
                            Image("arrowBlueIcon")
                                .padding(.horizontal)
                        }
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
     
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                   
                    Spacer()
                }
                .onAppear {
                    purchaseManager.checkSubscriptionStatus()
                }
                .padding(.horizontal)
                .padding(.top)
            }
        }
    }
}

fileprivate struct SupportEmailService {
    let subject: String = "App Feedback"
    let messageHeader: String = "Please describe your problem!"
    var body: String = ""
    
    func send(toAddress: String) {
        let urlString = "mailto:\(toAddress)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
    }
}
 
public struct CustomBackButton: View {
    let dismiss: DismissAction
    
    public init(dismiss: DismissAction) {
        self.dismiss = dismiss
    }
    
    public var body: some View {
        Button {
            dismiss()
        } label: {
            HStack {
                Image("backButtonIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
                Text("Back")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
}

@MainActor
public class PurchaseManager: NSObject, ObservableObject {
    @Published var isPremium: Bool = false
    
    public override init() {
        super.init()
        checkSubscriptionStatus()
    }
    
    func checkSubscriptionStatus() {
        Task {
            if let productID = await fetchCurrentEntitlement() {
                isPremium = true
            } else {
                isPremium = false
            }
        }
    }
    
    func fetchCurrentEntitlement() async -> String? {
        do {
            for try await result in Transaction.currentEntitlements {
                guard case .verified(let transaction) = result else {
                    continue
                }
                return transaction.productID
            }
        }
        return nil
    }
}

public extension Double {
    func formatTime() -> String {
        // Check if the Double value is finite
        guard self.isFinite else {
            return "0:00"  // or any other appropriate error handling
        }
        
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func asTimeString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = style
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: self) ?? ""
    }
}

public extension BinaryFloatingPoint {
    func asTimeString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = style
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(self)) ?? "" //formatter.string(from: self) ?? ""
    }
}

public extension FileManager {
    static var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}

public extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

public extension View {
    @available(iOS 14, *)
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor ]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor ]
        return self
    }
    
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}

public extension UIDevice {
    var hasNotch: Bool {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        return keyWindow?.safeAreaInsets.bottom ?? 0 > 0
    }
}

public class FileHandler {
    public static let shared = FileHandler()
    
    func saveFile(data: Data, fileID: String) {
        let fileURL = FileManager.documentsDirectory.appendingPathComponent(fileID)
        
        do {
            try data.write(to: fileURL)
        } catch {
            print("Error saving file: \(error)")
        }
    }
    
    func loadFile(from fileID: String) -> Data? {
        let url = FileManager.documentsDirectory.appendingPathComponent(fileID)
        do {
            return try Data(contentsOf: url)
        } catch {
            print("Error loading file: \(error)")
            return nil
        }
    }
    
    func deleteFile(fileID: String) {
        let fileURL = FileManager.documentsDirectory.appendingPathComponent(fileID)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Error deleting file: \(error)")
        }
    }
}

public class VibrationManager {
    public static let shared = VibrationManager()

    public var engine: CHHapticEngine?

    public init() {
        setupHapticEngine()
    }

    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            return
        }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Error starting haptic engine: \(error.localizedDescription)")
        }
    }

    func vibrate(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func vibrateCustom(pattern: [Double], style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard pattern.count > 0 else { return }

        if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            do {
                var events: [CHHapticEvent] = []

                for (index, duration) in pattern.enumerated() {
                    let eventType: CHHapticEvent.EventType = (index % 2 == 0) ? .hapticContinuous : .hapticTransient

                    let event = CHHapticEvent(eventType: eventType, parameters: [
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5),
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
                    ], relativeTime: duration)

                    events.append(event)
                }

                let customPattern = try CHHapticPattern(events: events, parameters: [])
                let player = try engine?.makePlayer(with: customPattern)
                try player?.start(atTime: 0)
            } catch {
                print("Error playing custom haptic feedback: \(error.localizedDescription)")
            }
        } else {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
}

public struct ConvertManager {
    public static let shared = ConvertManager()

    func getFileMetadata(from url: URL, isOnboarding: Bool = false) -> SongModel? {
        let asset = AVURLAsset(url: url)
        let metadata = asset.metadata
        
        var trackName = url.lastPathComponent
        var artistName = "Unknown"
        var albumArtwork = UIImage()
        
        for item in metadata {
            guard let key = item.commonKey, let value = item.value else {
                continue
            }
            
            switch key {
            case .commonKeyTitle:
                trackName = value as? String ?? url.lastPathComponent
            case .commonKeyArtist:
                artistName = value as? String ?? "Unknown"
            case .commonKeyArtwork:
                if let data = value as? Data {
                    albumArtwork = UIImage(data: data) ?? UIImage()
                }
            default:
                break
            }
        }
        
        let bookmarkData = try? url.bookmarkData()
        var newImageID: UUID?
        if let imageData = albumArtwork.jpegData(compressionQuality: 1.0) {
            let imageID = UUID()
            let _ = FileHandler.shared.saveFile(data: imageData, fileID: imageID.uuidString)
            newImageID = imageID
        }
        let track = SongModel(id: UUID(),
                              imageID: newImageID,
                              name: trackName,
                              artist: artistName,
                              totalDuration: asset.duration.seconds,
                              isFavorite: false,
                              bookmarkData: bookmarkData,
                              isOnboarding: isOnboarding)
        return track
    }
}

public struct SongModel: Identifiable {
    public let id: UUID
    let imageID: UUID?
    let name: String
    let artist: String
    let totalDuration: Double
    let isFavorite: Bool
    let bookmarkData: Data?
    let isOnboarding: Bool
}

public struct EffectModel: Identifiable {
    public var id: UUID = UUID()
    var name: String
    var imageName: String
}

public let allEffects = [EffectModel(name: "Jazz", imageName: "jazzEffectIcon"),
                  EffectModel(name: "Loud", imageName: "loudEffectIcon"),
                  EffectModel(name: "Music", imageName: "musicEffectIcon"),
                  EffectModel(name: "Party", imageName: "partyEffectIcon"),
                  EffectModel(name: "Pop", imageName: "popEffectIcon"),
]

public class CoreDataManager: ObservableObject {
    let container = NSPersistentContainer(name: "BassBooster")
    
    public init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
        self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
    func saveSong(newSong: SongModel) -> SongEntity? {
        let song = SongEntity(context: container.viewContext)
        song.id = newSong.id
        song.name = newSong.name
        song.artist = newSong.artist
        song.imageID = newSong.imageID
        song.totalDuration = newSong.totalDuration
        song.isFavorite = newSong.isFavorite
        song.bookmarkData = newSong.bookmarkData
        song.isOnboarding = newSong.isOnboarding
        
        do {
            try container.viewContext.save()
            return song
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func renameSong(song: SongEntity, name: String) {
        song.name = name
        
        do {
            try container.viewContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func updateIsFavorite(song: SongEntity, isFavorite: Bool) {
        song.isFavorite = isFavorite
        
        do {
            try container.viewContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func getAllSongs() -> [SongEntity] {
        let request: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isOnboarding == false")
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func getAllFavoriteSongs() -> [SongEntity] {
        let request: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == true")
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Failed to fetch original songs: \(error.localizedDescription)")
            return []
        }
    }
    
    func getAllOnboardingSongs() -> [SongEntity] {
        let request: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isOnboarding == true")
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Failed to fetch original songs: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteAllOnboarding() {
        let request: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isOnboarding == true")
        
        do {
            let copies = try container.viewContext.fetch(request)
            
            for copy in copies {
                container.viewContext.delete(copy)
            }
            
            try container.viewContext.save()
            print("\(copies.count) onboarding songs deleted successfully.")
        } catch {
            print("Failed to delete copies: \(error.localizedDescription)")
        }
    }
    
    func deleteSong(song: SongEntity) {
        container.viewContext.delete(song)
        try? container.viewContext.save()
    }
}

public class SongViewModel: ObservableObject {
    @ObservedObject var miniHandler: MinimizableViewHandler = MinimizableViewHandler()
    
    @AppStorage("saveLocalTracks") private var saveLocalTracksUD = true

    @Published var allTracks: [SongEntity] = []
    @Published var favoriteTracks: [SongEntity] = []
    @Published var onboardingTracks: [SongEntity] = []
    @Published var currentPlaylist: [SongEntity] = []
    @Published var selectedTrack: SongEntity?
    @Published var isPlaying = false
    @Published var repeatMode: RepeatMode = .once
    
    @Published var is3DSurroundEnabled = false
    @Published var isBassBoostEnabled = true
    @Published var isSpeedEnabled = true
    @Published var isPitchEnabled = true
    
    @Published var bassBoost: Double = 0
    @Published var speed: Double = 1
    @Published var reverb: Double = 0
    @Published var pitch: Double = 0
    @Published var player = AVAudioPlayerNode()
    
    private let audioEngine = AVAudioEngine()
    private var reverbNode = AVAudioUnitReverb()
    private var timePitch = AVAudioUnitTimePitch()
    private var bassBoostNode = AVAudioUnitEQ(numberOfBands: 1)
    
    private var currentAudioFile: AVAudioFile?
    private var playbackStartTime: TimeInterval?
    private var pauseTime: TimeInterval?
    private var audioFileDuration: TimeInterval = 0
    private var audioFileSampleRate: Double = 0
    
    private let coreDataManager = CoreDataManager()
    private var startPlaylist = [SongEntity]()

    var currentTime: TimeInterval {
        guard let playbackStartTime = playbackStartTime else { return 0 }
        if let pauseTime = pauseTime {
            return pauseTime
        }
        return min(CACurrentMediaTime() - playbackStartTime, audioFileDuration)
    }
    
    public init() {
        setupAudioEngine()
        getAllSongs()
        if saveLocalTracksUD {
            saveLocalTracks(trackNames: ["track1", "track2", "track3", "track4", "track5"])
        }
        getOnboardingSongs()
    }
    
    // MARK: - Audio Effects
    private func setupAudioEngine() {
        audioEngine.attach(player)
        audioEngine.attach(reverbNode)
        audioEngine.attach(timePitch)
        audioEngine.attach(bassBoostNode)
        
        reverbNode.loadFactoryPreset(.largeHall) // Пресет для эффекта 3D Surround
        reverbNode.wetDryMix = 0 // По умолчанию выключено

        audioEngine.connect(player, to: reverbNode, format: nil)
        audioEngine.connect(reverbNode, to: timePitch, format: nil)
        audioEngine.connect(timePitch, to: bassBoostNode, format: nil)
        audioEngine.connect(bassBoostNode, to: audioEngine.mainMixerNode, format: nil)
        startAudioEngine()
    }
    
    func startAudioEngine() {
        do {
            try audioEngine.start()
        } catch {
            print("Audio Engine failed to start: \(error.localizedDescription)")
        }
    }
    
    func toggle3DSurround(_ isEnabled: Bool) {
        is3DSurroundEnabled = isEnabled
    }
    
    func toggleBassBoost(_ isEnabled: Bool) {
        isBassBoostEnabled = isEnabled
    }
    
    func toggleSpeedBoost(_ isEnabled: Bool) {
        isSpeedEnabled = isEnabled
    }
    
    func togglePitchBoost(_ isEnabled: Bool) {
        isPitchEnabled = isEnabled
    }
    
    func updateBassBoost(value: Double) {
        bassBoostNode.globalGain = Float(value)
        bassBoost = value
    }

    func updateSpeed(value: Double) {
        timePitch.rate = Float(value)
        speed = value
    }

    func updatePitch(value: Double) {
        timePitch.pitch = Float(value * 100)
        pitch = value * 100
    }

    func updateReverb(value: Double) {
        reverbNode.wetDryMix = Float(value)
        reverb = value
    }

    
    func saveLocalTracks(trackNames: [String]) {
        // Первый раз сохраняем треки и фиксируем в user defaults
        // Если надо обновить треки то обновляем ключ в user defaults -> saveLocalTracksV1
        /// старые треки удаляются из БД --> загружаются новые
        coreDataManager.deleteAllOnboarding()
        saveLocalTracksUD = false
        for trackName in trackNames {
            guard let url = Bundle.main.url(forResource: trackName, withExtension: "mp3") else {
                print("Error: Could not find track \(trackName) in the app bundle.")
                continue
            }
            
            if let trackInfo = ConvertManager.shared.getFileMetadata(from: url, isOnboarding: true) {
                do {
                    let songData = try Data(contentsOf: url)
                    saveSong(data: songData, song: trackInfo)
                } catch {
                    print("Error loading song data for \(trackName): \(error)")
                }
            } else {
                print("Error: Could not retrieve metadata for \(trackName).")
            }
        }
        getOnboardingSongs()
    }
    
    func getOnboardingSongs() {
        onboardingTracks = coreDataManager.getAllOnboardingSongs()
    }
    
    func getAllSongs() {
        favoriteTracks = coreDataManager.getAllFavoriteSongs()
        allTracks = coreDataManager.getAllSongs()
    }
    
    func saveSong(data: Data, song: SongModel) {
        FileHandler.shared.saveFile(data: data,
                                    fileID: song.id.uuidString)
        let _ = coreDataManager.saveSong(newSong: song)
        getAllSongs()
    }
    
    func updateIsFavorite(song: SongEntity, isFavorite: Bool) {
        coreDataManager.updateIsFavorite(song: song, isFavorite: isFavorite)
        getAllSongs()
    }
    
    func deleteSong(song: SongEntity) {
        coreDataManager.deleteSong(song: song)
        getAllSongs()
    }
    
    func hidePlayer() {
        if miniHandler.isPresented {
            miniHandler.isPresented = false
        }
    }
    
    func showPlayer() {
        if let selectedTrack = selectedTrack {
            if allTracks.contains(where: { $0.id == selectedTrack.id }) {
                miniHandler.isPresented = true
            }
        }
    }
    
    func stopCurrentTrack() {
        player.stop()
        currentAudioFile = nil
        audioFileDuration = 0
        playbackStartTime = nil
        pauseTime = nil
    }
    
    private func setupPlayer(track: SongEntity?) {
        var bookmarkDataIsStale = false
        guard let playNow = try? URL(resolvingBookmarkData: track?.bookmarkData ?? Data(), bookmarkDataIsStale: &bookmarkDataIsStale) else {
            return
        }
        guard let audioFile = try? AVAudioFile(forReading: playNow) else { return }
        currentAudioFile = audioFile
        audioFileDuration = audioFile.length.toSeconds(sampleRate: audioFile.processingFormat.sampleRate)
        audioFileSampleRate = audioFile.processingFormat.sampleRate
        
        player.scheduleFile(audioFile, at: nil, completionHandler: nil)
        playbackStartTime = CACurrentMediaTime()
        pauseTime = nil
        player.play()
        updateNowPlayingInfo(currentTime: 0)
        setupPlaylist(mode: repeatMode)
    }
    
    func togglePlayback(track: SongEntity, playlist: [SongEntity]? = nil) {
        if let playlist = playlist {
            currentPlaylist = Array(playlist.reversed())
            startPlaylist = Array(playlist.reversed())
        }
        if let currentTrack = selectedTrack, currentTrack.id == track.id {
            if isPlaying {
                pauseTrack()
            } else {
                playTrack()
            }
            isPlaying.toggle()
        } else {
            selectedTrack = track
            stopCurrentTrack()
            setupPlayer(track: track)
            isPlaying = true
            miniHandler.present()
        }
    }
    
    func pauseTrack() {
        pauseTime = currentTime
        player.pause()
    }
    
    func playTrack() {
        player.play()
        guard let pauseTime = pauseTime else { return }
        playbackStartTime = CACurrentMediaTime() - pauseTime
        self.pauseTime = nil
    }
    
    func togglePlayback() {
        isPlaying ? pauseTrack() : playTrack()
        MPNowPlayingInfoCenter.default().playbackState = isPlaying ? .paused : .playing
        isPlaying.toggle()
        updateNowPlayingInfo(currentTime: currentTime)
    }
    
    private func togglePlaybackActions() {
        stopCurrentTrack()
        setupPlayer(track: selectedTrack)
        isPlaying = true
    }
    
    func onPreviousTrack() {
        if let selectedTrack = selectedTrack {
            let index = (currentPlaylist.firstIndex(where: { $0.id == selectedTrack.id }) ?? 0) - 1
            if index >= currentPlaylist.startIndex {
                self.selectedTrack = currentPlaylist[index]
                self.togglePlaybackActions()
            } else if index < currentPlaylist.startIndex {
                if !currentPlaylist.isEmpty {
                    self.selectedTrack = currentPlaylist[currentPlaylist.endIndex - 1]
                }
                self.togglePlaybackActions()
            }
        }
    }
    
    func onNextTrack() {
        if let selectedTrack = selectedTrack {
            let index = (currentPlaylist.firstIndex(where: { $0.id == selectedTrack.id }) ?? 0) + 1
            if index < currentPlaylist.count {
                self.selectedTrack = currentPlaylist[index]
                self.togglePlaybackActions()
            } else {
                if !currentPlaylist.isEmpty {
                    self.selectedTrack = currentPlaylist[0]
                }
                self.togglePlaybackActions()
            }
        }
    }
    
    func updateNowPlayingInfo(currentTime: Double) {
        guard let selectedTrack = selectedTrack else { return }
        var image = UIImage()
        if let itemID = selectedTrack.imageID,
           let trackImageData = FileHandler.shared.loadFile(from: itemID.uuidString),
           let uiImage = UIImage(data: trackImageData) {
            image = uiImage
        } else {
            image = UIImage(named: "playerNoImage") ?? UIImage()
        }
        let nowPlayingInfo: [String : Any] = [
            MPMediaItemPropertyTitle: selectedTrack.name,
            MPMediaItemPropertyArtist: selectedTrack.artist,
            MPMediaItemPropertyPlaybackDuration: selectedTrack.totalDuration ?? 0, // Загальний час треку
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0, // Швидкість відтворення (0.0 - при паузі, 1.0 - при відтворенні)
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime, // Поточний час відтворення
            MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue, // Тип медіа (ваш випадок - аудіо)
            MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: CGSize(width: 100, height: 100), requestHandler: { (size) -> UIImage in //image.size
                return image
            })
        ]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func setupNextMode() {
        switch repeatMode {
        case .once:
            if let currentTrack = selectedTrack {
                if currentTrack == currentPlaylist.last {
                    updateNowPlayingInfo(currentTime: 0)
                    seek(to: CMTime(seconds: 0, preferredTimescale: 600))
                    player.pause()
                    isPlaying = false
                } else {
                    onNextTrack()
                }
            }
        case .loop:
            updateNowPlayingInfo(currentTime: 0)
            seek(to: CMTime(seconds: 0, preferredTimescale: 600))
            playTrack()
            isPlaying = true
        case .none:
            onNextTrack()
        case .shuffle:
            onNextTrack()
        }
    }
    
    func seek(to time: CMTime) {
        guard let audioFile = currentAudioFile else {
            print("Error: No audio file loaded.")
            return
        }
        
        // Ограничение времени в пределах длины файла
        let targetTime = max(0, min(time.seconds, audioFileDuration))
        let framePosition = AVAudioFramePosition(targetTime * audioFileSampleRate)
        
        // Проверка валидности позиции
        guard framePosition < audioFile.length else {
            print("Error: Frame position is out of bounds.")
            return
        }
        
        // Остановка текущего воспроизведения
        player.stop()
        
        // Расчет оставшегося количества кадров
        let remainingFrameCount = AVAudioFrameCount(audioFile.length - framePosition)
        
        // Планирование воспроизведения с новой позиции
        player.scheduleSegment(
            audioFile,
            startingFrame: framePosition,
            frameCount: remainingFrameCount,
            at: nil,
            completionHandler: nil
        )
        
        // Сброс времени воспроизведения
        playbackStartTime = CACurrentMediaTime() - targetTime
        
        // Запуск воспроизведения
        player.play()
    }
    
    func setupPlaylist(mode: RepeatMode) {
        switch mode {
        case .once:
            if !startPlaylist.isEmpty {
                currentPlaylist = startPlaylist
            }
        case .shuffle:
            if startPlaylist == currentPlaylist {
                if let selectedTrack = selectedTrack {
                    currentPlaylist = shufflePlaylist(currentPlaylist: currentPlaylist, selectedTrack: selectedTrack)
                }
            }
        case .loop:
            if !startPlaylist.isEmpty {
                currentPlaylist = startPlaylist
            }
        case .none:
            if !startPlaylist.isEmpty {
                currentPlaylist = startPlaylist
            }
        }
    }
    
    func shufflePlaylist(currentPlaylist: [SongEntity], selectedTrack: SongEntity) -> [SongEntity] {
        // Находим индекс выбранного трека
        guard let selectedIndex = currentPlaylist.firstIndex(where: { $0.id == selectedTrack.id }) else {
            // Возвращаем исходный плейлист, если выбранный трек не найден
            return currentPlaylist
        }
        
        // Создаем копию плейлиста без выбранного трека
        var playlistWithoutSelected = currentPlaylist
        playlistWithoutSelected.remove(at: selectedIndex)
        
        // Перемешиваем плейлист
        playlistWithoutSelected.shuffle()
        
        // Вставляем выбранный трек обратно на его первоначальное место
        playlistWithoutSelected.insert(selectedTrack, at: selectedIndex)
        return playlistWithoutSelected
    }
    
    func stopCurrentPlay() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [:]
        player.pause()
        isPlaying = false
        miniHandler.dismiss()
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
}


private extension AVAudioFramePosition {
    func toSeconds(sampleRate: Double) -> TimeInterval {
        return TimeInterval(self) / sampleRate
    }
}

public enum RepeatMode: CaseIterable {
    case once, shuffle, loop, none
    
    public var image: String {
        switch self {
        case .once:
            return "repeat"
        case .shuffle:
            return "shuffle"
        case .loop:
            return "repeat"
        case .none:
            return "repeat.1"
        }
    }
    
    public var nextMode: RepeatMode {
        switch self {
        case .once:
            return .shuffle
        case .shuffle:
            return .loop
        case .loop:
            return RepeatMode.none
        case .none:
            return .once
        }
    }
}

public class MinimizableViewHandler: ObservableObject {
 
    var keyboardResponder: MVKeyboardNotifier?
    public init() {

        self.keyboardResponder = MVKeyboardNotifier(keyboardWillShow: {
            if self.isMinimized {
                self.isVisible = false
            }
        }, keyboardWillHide: {
            self.isVisible = true
        })
        
    }
    ///onPresentation closure
    public var onPresentation: (()->Void)?
      ///onDismissal closure
    public var onDismissal:(()->Void)?
      ///onExpansion closure
    public  var onExpansion: (()->Void)?
      ///onMinimization closure
    public var onMinimization: (()->Void)?
    
    /**draggedOffset: The offset of the minimizable view's position. You can attach your own gesture recognizers to your content view or its subviews, e.g. to dismiss the minimizable view on swiping down.
 */
    @Published public var draggedOffsetY: CGFloat = 0
    
    
    @Published internal var isVisible = true
    /**
    Call this function to present the minimizable view instead of setting isPresented to true directly.
    */
    public func present(animation: Animation = Animation.spring()) {
        
        if self.isPresented == false {
            withAnimation(animation) {
                self.isPresented = true
            }
        }
  
    }
    
    /**
    Call this function to dismiss the minimizable view instead of setting isPresented to false directly.
    */
    public func dismiss(animation: Animation = Animation.default) {
        
        if self.isPresented == true {
            //withAnimation(animation) {
                self.isPresented = false
            //}
//            if self.isMinimized == true {
//                self.isMinimized = false
//            }
        }
    }
    
    /**
    Call this function to minimize the minimizable view instead of setting  isMinimized to true directly.
    */
    public func minimize(animation: Animation = Animation.default) {
        
        if self.isMinimized == false  {
            withAnimation(animation) {
                self.isMinimized = true
            }
            
            
        }
    }
    
    /**
    Call this function to expand the minimizable view instead of setting i  isMinimized to false directly.
    */
    public func expand(animation: Animation = Animation.default) {
        if self.isMinimized == true  {
            withAnimation(animation) {
                self.isMinimized = false
            }
        }
    }
    
    /**
    Call this function to expand or minimize the MinimizableView. Useful in an onTapGesture-closure because you don't need to check the expansion state.
    */
    public func toggleExpansionState(expandAnimation: Animation = .spring(), minimizeAnimation: Animation = .spring()) {
        if self.isMinimized {
            self.expand(animation: expandAnimation)
        } else {
            self.minimize(animation: minimizeAnimation)
        }

    }
    

    /**
    Published variable  get the presentation state of the minimizable view.
    */
    @Published public var isPresented: Bool = false {
        didSet {
            if isPresented {
                self.onPresentation?()
            } else {
                self.onDismissal?()
            }
        }
    }
    
    /**
    Published variable get the expansion state of the minimizable view.
    */
    @Published  public var isMinimized: Bool = false {
        didSet {
            if isMinimized {
                self.onMinimization?()
            } else {
                if self.isPresented == true {
                    self.onExpansion?()
                }
            }
        }
    }
}

/**
 Settings to pass in as parameter into the initializer of mini view
*/
public struct MiniSettings {
    public init(minimizedHeight: CGFloat = 60, overrideHeight: CGFloat? = UIDevice.current.hasNotch ? UIScreen.main.bounds.height - 60 : UIScreen.main.bounds.height, lateralMargin: CGFloat = 0, minimumDragDistance: CGFloat = 0, edgesIgnoringSafeArea: Edge.Set = UIDevice.current.hasNotch ? [.bottom, .top] : []) {
        self.minimizedHeight = minimizedHeight
        self.overrideHeight = overrideHeight
        self.lateralMargin = lateralMargin
        self.minimumDragDistance = minimumDragDistance
        self.edgesIgnoringSafeArea = edgesIgnoringSafeArea
    }

    var minimizedHeight: CGFloat

    var overrideHeight: CGFloat?

    var lateralMargin: CGFloat
    
    var minimumDragDistance: CGFloat
    
    var edgesIgnoringSafeArea: Edge.Set
}

public class MVKeyboardNotifier: ObservableObject {
   
    private var notificationCentre: NotificationCenter
    
    var keyboardWillShow: (()->Void)?
    var keyboardWillHide:(()->Void)?
    
    @Published public var keyboardIsShowing: Bool = false
    @Published public var keyboardHeight: CGFloat = 0
    
    public init(keyboardWillShow:  (()->Void)?, keyboardWillHide: (()->Void)?) {
        self.notificationCentre =  NotificationCenter.default
        notificationCentre.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCentre.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.keyboardWillShow = keyboardWillShow
        self.keyboardWillHide = keyboardWillHide
    }

    deinit {
        notificationCentre.removeObserver(self)
    }

    @objc func keyBoardWillShow(notification: Notification) {
        self.keyboardWillShow?()
        self.keyboardIsShowing = true
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHeight =  keyboardRectangle.height
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        self.keyboardWillHide?()
        self.keyboardIsShowing = false
        self.keyboardHeight = 0
    }
}

public struct EmptyListView: View {
    public var title: String
    public var image: String
    
    public init(title: String, image: String) {
        self.title = title
        self.image = image
    }
    
    public var body: some View {
        VStack {
            Spacer()
            
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.white)
                .padding()
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(height: 220)
        .opacity(0.5)
    }
}

public struct BlurView: UIViewRepresentable {
    
    public func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
        return view
    }
    
    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}

public struct SearchBar: View {
    @Binding var text: String
    
    public init(text: Binding<String>) {
        self._text = text
    }
    
    public var body: some View {
        HStack {
            ZStack {
                TextField("", text: $text)
                    .placeholder(when: text.isEmpty, placeholder: {
                        Text("Search Songs, Albums, Artists")
                            .foregroundColor(Color(red: 0.48, green: 0.48, blue: 0.48))
                            .font(.system(size: 16, weight: .light))
                            .lineLimit(1)
                    })
                    .padding(12)
                    .padding(.horizontal, 28)
                    .background(Color(red: 0.13, green: 0.13, blue: 0.13))
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
        }
        .overlay(
            HStack {
                Image("searchTabIcon")
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 30)
                    .opacity(0.2)
            }
        )
    }
}

public struct MainView: View {
    @EnvironmentObject var viewModel: SongViewModel
    @GestureState var dragOffset = CGSize.zero
    
    public var body: some View {
            TabBarView()
            .minimizableView(content: { MainPlayerView()
            },dragOffset: $dragOffset, dragUpdating: { (value, state, _) in
                state = value.translation
                self.dragUpdated(value: value)
            }, dragOnChanged: { (value) in
                
            }, dragOnEnded: { (value) in
                self.dragOnEnded(value: value)
            }, minimizedBottomMargin: UIDevice.current.hasNotch ? 95 : 80, settings: MiniSettings(minimizedHeight: 70))
            .environmentObject(self.viewModel.miniHandler)
            .preferredColorScheme(.dark)
    }
    
    func dragUpdated(value: DragGesture.Value) {
        if self.viewModel.miniHandler.isMinimized == false && value.translation.height > 0   { // expanded state
            self.viewModel.miniHandler.draggedOffsetY = value.translation.height  // divide by a factor > 1 for more "inertia"
        } else if self.viewModel.miniHandler.isMinimized && value.translation.height < 0   {// minimized state
            if self.viewModel.miniHandler.draggedOffsetY >= -60 {
                self.viewModel.miniHandler.draggedOffsetY = value.translation.height // divide by a factor > 1 for more "inertia"
            }
        }
    }
    
    func dragOnEnded(value: DragGesture.Value) {
        if self.viewModel.miniHandler.isMinimized == false && value.translation.height > 90  {
            self.viewModel.miniHandler.minimize()
            
        } else if self.viewModel.miniHandler.isMinimized &&  value.translation.height <= -60 {
            self.viewModel.miniHandler.expand()
        }
        self.viewModel.miniHandler.draggedOffsetY = 0
    }
}

public class TabBarViewModel: ObservableObject {
    // MARK: - TAB BAR
    @Published var currentTab: Tab = .Home
    
    // MARK: - DETAIL VIEW
    @Published var showDetail = false
    @Published var showCategories = false
    @Published var shouldReturnToTodayView = false
    
    func returnToTodayView() {
        shouldReturnToTodayView = true
    }
}

public struct TabBarView: View {
    
    @StateObject var baseData = TabBarViewModel()
    @State private var showingSheet = false
    
    // MARK: - HIDE TAB BAR
    public init() {
        UITabBar.appearance().isHidden = true
    }
    
    public var body: some View {
        TabView(selection: $baseData.currentTab) {
            PlaylistsView()
                .tag(Tab.Home)
            SearchView()
                .tag(Tab.Search)
            MySongsView()
                .tag(Tab.MySongs)
        }
        .environmentObject(baseData)
        
        .overlay(
            // MARK: - CUSTOM TAB BAR
            HStack(spacing: 0) {
                // MARK: - TAB BUTTON
                TabButton(Tab: .Home, label: "Home")
                TabButton(Tab: .Search, label: "Search")
                TabButton(Tab: .MySongs, label: "Songs")
            }
                .padding()
                .background(Color(hex: "#292929").ignoresSafeArea(.container, edges: .bottom))
            //MARK: - HIDE TAB ON DETAIL VIEW
                .offset(y: baseData.showDetail ? 200 : 0), alignment: .bottom)
    }
    
    @ViewBuilder
    func TabButton(Tab: Tab, label: String) -> some View {
        Button {
            baseData.currentTab = Tab
        } label: {
            VStack(spacing: 2) {
                Image(Tab.rawValue)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(baseData.currentTab == Tab ? .white : .white.opacity(0.2))
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(baseData.currentTab == Tab ? .white : .white.opacity(0.2))
            }
            .padding(.bottom)
            .frame(maxWidth: .infinity)
        }
    }
}

public struct SearchView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject var viewModel: SongViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isOpenPremium = false
    @State private var isOpenSettings = false
    @State var searchText: String = ""
    
    var filteredTracks: [SongEntity] {
        if searchText.isEmpty {
            // If the search query is empty, return the original array (unfiltered)
            return []
        } else {
            // If there is a search query, filter and sort the array
            let filteredTracks = viewModel.allTracks.filter { track in
                // Add your filtering condition here, for example, if you want to match the track name
                if let trackName = track.name {
                    return trackName.lowercased().contains(searchText.lowercased())
                } else {
                    return false
                }
            }
            
            // Sort the filtered array, you can change the sorting criteria based on your requirement
            let sortedTracks = filteredTracks.sorted { (track1, track2) in
                return track1.name ?? "" < track2.name ?? ""
            }
            
            return sortedTracks
        }
    }
    
    public var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#1c0d00") ?? .black, Color(hex: "#000000") ?? .black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack {
                HStack {
                    Button {
                        isOpenSettings = true
                    } label: {
                        Image("settingsDotsIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 5)
                    }
                    .padding(.leading)
                    Spacer()
                    Text("Search")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                    Button {
                        isOpenPremium = true
                    } label: {
                        Image("crownPremiumIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        
                    }
                    .opacity(purchaseManager.isPremium ? 0 : 1)
                    .disabled(purchaseManager.isPremium)
                    .padding(.trailing)
                }
                .background(Color(hex: "#292929").ignoresSafeArea(.container, edges: .top))
                
                Spacer()
                
                VStack {
                    SearchBar(text: $searchText)
                    if filteredTracks.isEmpty {
                        Spacer()
                        EmptyListView(title: "Search Your Songs!", image: "searchEmptyIcon")
                        
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack {
                                ForEach(filteredTracks.reversed(), id: \.id) { track in
                                    TrackListCell(track: track)
                                }
                            }
                        }
                        .padding(.top)
                        .padding(.horizontal)
                    }
                    Spacer()
                }
                .padding(.top)
            }
        }
        .fullScreenCover(isPresented: $isOpenSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $isOpenPremium) {
            PaywallView(showTabBar: false)
        }
        .onAppear {
            purchaseManager.checkSubscriptionStatus()
        }
    }
}

public struct BoostConfigView: View {
    @EnvironmentObject var viewModel: SongViewModel
    
    @State private var is3DSurroundEnabled = false
    @State private var isBassBoostEnabled = false
    @State private var isSpeedEnabled = false
    @State private var isPitchEnabled = false
    
    @State private var bassBoost: Double = 0
    @State private var speed: Double = 0
    @State private var reverb: Double = 0
    @State private var pitch: Double = 0
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack {
                Capsule()
                    .fill(Color.gray)
                    .frame(width: 70, height: 5)
                    .padding(.top, 5)
                HStack {
                    Spacer()
                    Text("Boost on")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top)
                    Spacer()
                }
            }
            .padding(.top, 10)
            Divider()
                .background(.white.opacity(0.2))

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    VStack {
                        ToggleRow(title: "3D Surround", isOn: $is3DSurroundEnabled)
                            .onChange(of: is3DSurroundEnabled) { value in
                                viewModel.toggle3DSurround(value)
                                if !value {
                                    reverb = 0
                                    viewModel.reverb = 0
                                }
                            }
                        
                        LinearGradientSlider(value: $reverb, range: 1...100, step: 1, label: "")
                            .disabled(!is3DSurroundEnabled)
                            .opacity(is3DSurroundEnabled ? 1 : 0.5)
                            .onChange(of: reverb) { value in
                                viewModel.updateReverb(value: value)
                            }
                    }
                    .padding(.vertical)
                    Divider()
                        .background(.white.opacity(0.2))
                    VStack {
                        ToggleRow(title: "Bass Boost", isOn: $isBassBoostEnabled)
                            .onChange(of: isBassBoostEnabled) { value in
                                viewModel.toggleBassBoost(value)
                                if !value {
                                    bassBoost = 0
                                    viewModel.bassBoost = 0
                                }
                            }
                        
                        LinearGradientSlider(value: $bassBoost, range: -10...24, step: 1, label: "")
                            .disabled(!isBassBoostEnabled)
                            .opacity(isBassBoostEnabled ? 1 : 0.5)
                            .onChange(of: bassBoost) { value in
                                viewModel.updateBassBoost(value: value)
                            }
                    }
                    .padding(.vertical)
                    Divider()
                        .background(.white.opacity(0.2))
                    VStack {
                        ToggleRow(title: "Speed", isOn: $isSpeedEnabled)
                            .onChange(of: isSpeedEnabled) { value in
                                viewModel.toggleSpeedBoost(value)
                                if !value {
                                    speed = 1
                                    viewModel.speed = 1
                                }
                            }
                        
                        LinearGradientSlider(value: $speed, range: 0.5...2, step: 0.1, label: "")
                            .disabled(!isSpeedEnabled)
                            .opacity(isSpeedEnabled ? 1 : 0.5)
                            .onChange(of: speed) { value in
                                viewModel.updateSpeed(value: value)
                            }
                    }
                    .padding(.vertical)
                    Divider()
                        .background(.white.opacity(0.2))
                    VStack {
                        ToggleRow(title: "Pitch", isOn: $isPitchEnabled)
                            .onChange(of: isPitchEnabled) { value in
                                viewModel.togglePitchBoost(value)
                                if !value {
                                    pitch = 0
                                    viewModel.pitch = 0
                                }
                            }
                        
                        LinearGradientSlider(value: $pitch, range: -10...10, step: 0.2, label: "")
                            .disabled(!isPitchEnabled)
                            .opacity(isPitchEnabled ? 1 : 0.5)
                            .onChange(of: pitch) { value in
                                viewModel.updatePitch(value: value)
                            }
                    }
                    .padding(.vertical)
                }

            }
            Spacer()
        }
        .padding(.vertical)
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            is3DSurroundEnabled = viewModel.is3DSurroundEnabled
            isBassBoostEnabled = viewModel.isBassBoostEnabled
            isSpeedEnabled = viewModel.isSpeedEnabled
            isPitchEnabled = viewModel.isPitchEnabled
            
            bassBoost = viewModel.bassBoost
            speed = viewModel.speed
            reverb = viewModel.reverb
            pitch = viewModel.pitch
        }
    }
}

public struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    public init(title: String, isOn: Binding<Bool>) {
        self.title = title
        self._isOn = isOn
    }
    
    public var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#FF6504") ?? .black))
        }
        .padding(.horizontal)
    }
}

public struct LinearGradientSlider: View {
    @Binding var value: Double
    var colors: [Color] = [Color(hex: "#A63103") ?? .black,
                           Color(hex: "#FF6504") ?? .black,
                           Color(hex: "#FFFF0C") ?? .black]
    var range: ClosedRange<Double>
    var step: Double
    var label: String
    
    public init(value: Binding<Double>, range: ClosedRange<Double>, step: Double, label: String) {
        self._value = value
        self.range = range
        self.step = step
        self.label = label
    }
    
    public var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: .leading,
                endPoint: .trailing
            )
            .mask(Slider(value: $value, in: range, step: step))
            
            // Dummy replicated slider, to allow sliding
            Slider(value: $value, in: range, step: step, label: { Text(label).font(Font.body.lowercaseSmallCaps()) })
            //            .opacity(0.05) // Opacity is the trick here.
                .accentColor(.clear)
        }
        .frame(height: 30)
        .padding(.horizontal)
    }
}

public struct PlaylistsView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @EnvironmentObject var songsVM: SongViewModel
    @State private var isOpenSettings = false
    @State private var isOpenPremium = false
    
    public var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "#1c0d00") ?? .black, Color(hex: "#000000") ?? .black]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                VStack {
                    HStack {
                        Button {
                            isOpenSettings = true
                        } label: {
                            Image("settingsDotsIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 5)
                        }
                        .padding(.leading)
                        Spacer()
                        Text("Boost Music")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                        Button {
                            isOpenPremium = true
                        } label: {
                            Image("crownPremiumIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        }
                        .opacity(purchaseManager.isPremium ? 0 : 1)
                        .disabled(purchaseManager.isPremium)
                        .padding(.trailing)
                    }
                    .background(Color(hex: "#292929").ignoresSafeArea(.container, edges: .top))
                    
                    
                    ScrollView(showsIndicators: false) {
//                        VStack(alignment: .leading) {
//                            HStack {
//                                Text("Playlist")
//                                    .font(.system(size: 20, weight: .bold))
//                                    .foregroundColor(.white)
//                                    .padding(.vertical)
//                                Divider()
//                                    .frame(maxWidth: .infinity)
//                                    .background(.white.opacity(0.2))
//                                    .frame(height: 1)
//                            }
//                            NavigationLink {
//                                DetailedPlaylistView()
//                            } label: {
//                                PlaylistCell()
//                            }
//                        }
                        
                        VStack {
                            HStack {
                                Text("Favorites")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.vertical)
                                Divider()
                                    .frame(maxWidth: .infinity)
                                    .background(.white.opacity(0.2))
                                    .frame(height: 1)
                            }
                            if songsVM.favoriteTracks.isEmpty {
                                EmptyListView(title: "No favorites\nGo ahead and like some songs!", image: "heartSlashIcon")
                                Spacer()
                            } else {
                                ForEach(Array(songsVM.favoriteTracks.reversed().enumerated()), id: \.element.id) { index, song  in
                                    FavoriteTrackCell(track: song)
                                        .padding(.bottom, index == songsVM.favoriteTracks.count - 1 ? 80 : 0)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
            }
            .fullScreenCover(isPresented: $isOpenPremium) {
                PaywallView(showTabBar: false)
            }
            
            .fullScreenCover(isPresented: $isOpenSettings) {
                SettingsView()
            }
            .onAppear {
                purchaseManager.checkSubscriptionStatus()
            }
        }
    }
}

public struct FavoriteTrackCell: View {
    @EnvironmentObject var viewModel: SongViewModel
    @State var track: SongEntity
    @State var showAlertDelete: Bool = false
    @State private var showActionSheet = false
    
    public var body: some View {
        ZStack(alignment: .trailing) {
            Button(action: {
                viewModel.togglePlayback(track: track, playlist: Array(viewModel.favoriteTracks.reversed()))
            }) {
                HStack(spacing: 10) {
                    ZStack {
                        if let itemID = track.imageID?.uuidString,
                           let dataImage = FileHandler.shared.loadFile(from: itemID),
                           let uiImage = UIImage(data: dataImage) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 48, height: 48)
                                .cornerRadius(10)
                        } else {
                            Image("musicEmptyIcon")
                                .resizable()
                                .frame(width: 48, height: 48)
                                .cornerRadius(10)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text(track.name ?? "")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text("\(track.artist ?? "") • \(track.totalDuration.formatTime())")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.white)
                    }
                    .padding(.trailing)
                    Spacer()
                }
                .padding(.vertical)
                
            }
            .frame(height: 60)
            .buttonStyle(NoTapAnimationStyle())
            
            Button {
                showActionSheet.toggle()
            } label: {
                Image("settingsDotsIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 40)
            }
        }
        .padding(8)
        .background((track.id == viewModel.selectedTrack?.id ? Color.white.opacity(0.05) : Color.clear))
        .cornerRadius(12)
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(title: Text("Choose Action"), buttons: [
                .default(Text("Remove From Favorites"), action: {
                    removeFromFavorites()
                }),
                .destructive(Text("Delete"), action: {
                    showAlertDelete.toggle()
                }),
                .cancel()
            ])
        }
        .alert(isPresented: $showAlertDelete) {
            Alert(
                title: Text("Are you sure you want to delete?"),
                primaryButton: .destructive(Text("Delete"), action: {
                    deleteTrack()
                }),
                secondaryButton: .cancel(Text("Cancel")))
        }
    }
    
    func removeFromFavorites() {
        if let track = viewModel.selectedTrack {
            viewModel.updateIsFavorite(song: track, isFavorite: !track.isFavorite)
        }
    }
    
    func deleteTrack() {
        viewModel.deleteSong(song: track)
        
        if let trackID = track.id {
            FileHandler.shared.deleteFile(fileID: trackID.uuidString)
            // Remove the tracks from the current playlist
            viewModel.currentPlaylist.removeAll { $0.id == trackID }
            
            if let currentTrack = viewModel.selectedTrack, currentTrack.id == trackID {
                viewModel.stopCurrentPlay()
            }
        }
    }
}

public struct PlaylistCell: View {
    @EnvironmentObject var viewModel: SongViewModel

    public var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 10) {
                
                if let itemID = viewModel.onboardingTracks.reversed().first?.imageID?.uuidString,
                   let dataImage = FileHandler.shared.loadFile(from: itemID),
                   let uiImage = UIImage(data: dataImage) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 157, height: 157)
                        .cornerRadius(8)
                } else {
                    Image("musicEmptyIcon")
                        .resizable()
                        .frame(width: 157, height: 157)
                        .cornerRadius(8)
                }
                
                VStack(spacing: 10) {
                    ForEach(viewModel.onboardingTracks.reversed().prefix(3).dropFirst(), id: \.self) { image in
                        
                        if let itemID = image.imageID?.uuidString,
                           let dataImage = FileHandler.shared.loadFile(from: itemID),
                           let uiImage = UIImage(data: dataImage) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 76, height: 76)
                                .cornerRadius(8)
                        } else {
                            Image("musicEmptyIcon")
                                .resizable()
                                .frame(width: 76, height: 76)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            VStack(alignment: .leading, spacing: 5) {
                Text("Onboarding Songs")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("\(viewModel.onboardingTracks.count) Songs")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

public struct DetailedPlaylistView: View {
    @EnvironmentObject var viewModel: SongViewModel
    @Environment(\.dismiss) private var dismiss
    @GestureState private var dragOffset = CGSize.zero

    public var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#1c0d00") ?? .black, Color(hex: "#000000") ?? .black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                // Header
                PlaylistHeaderView(dismiss: dismiss)

                // Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        PlaylistImageSection(viewModel: viewModel)
                        PlaylistActionsSection(viewModel: viewModel)
                        TrackListSection(viewModel: viewModel)
                    }
                    .padding(.bottom, calculateBottomPadding())
                }
                Spacer()
            }
            .navigationBarBackButtonHidden()
            .navigationBarHidden(true)
            .navigationTitle("")
            .gesture(DragGesture().updating($dragOffset, body: { (value, state, transaction) in
                if value.startLocation.x < 20 && value.translation.width > 100 {
                    dismiss()
                }
            }))
        }
    }

    private func calculateBottomPadding() -> CGFloat {
        let hasNotch = UIDevice.current.hasNotch
        return viewModel.miniHandler.isPresented
            ? (hasNotch ? 135 : 135)
            : (hasNotch ? 80 : 70)
    }
}

// MARK: - Subviews

private struct PlaylistHeaderView: View {
    let dismiss: DismissAction

    var body: some View {
        HStack {
            CustomBackButton(dismiss: dismiss)
            Spacer()
            Text("Onboarding Songs")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding()
            Spacer()
            CustomBackButton(dismiss: dismiss)
                .opacity(0)
                .disabled(true)
        }
        .background(Color(hex: "#292929").ignoresSafeArea(.container, edges: .top))
    }
}

private struct PlaylistImageSection: View {
    let viewModel: SongViewModel

    var body: some View {
        if let itemID = viewModel.onboardingTracks.reversed().first?.imageID?.uuidString,
           let dataImage = FileHandler.shared.loadFile(from: itemID),
           let uiImage = UIImage(data: dataImage) {
            Image(uiImage: uiImage)
                .resizable()
                .frame(width: 250, height: 250)
                .cornerRadius(8)
        } else {
            Image("musicEmptyIcon")
                .resizable()
                .frame(width: 250, height: 250)
                .cornerRadius(8)
        }
    }
}

private struct PlaylistActionsSection: View {
    let viewModel: SongViewModel

    var body: some View {
        HStack {
            ImportButton(title: "Play", iconName: "playButtonIcon") {
                if let firstTrack = viewModel.onboardingTracks.reversed().first {
                    viewModel.togglePlayback(track: firstTrack, playlist: Array(viewModel.onboardingTracks))
                }
            }
            .frame(width: 140)

            ShuffleButton(title: "Suffle", iconName: "suffleIcon") {
                if let randomTrack = viewModel.onboardingTracks.reversed().randomElement() {
                    viewModel.togglePlayback(track: randomTrack, playlist: Array(viewModel.onboardingTracks))
                }
            }
            .frame(width: 140, height: 50)
        }
    }
}

private struct TrackListSection: View {
    let viewModel: SongViewModel

    var body: some View {
        VStack {
            ForEach(Array(viewModel.onboardingTracks.reversed().enumerated()), id: \.element.id) { index, track in
                TrackListCell(track: track, isShowEdit: false)
                Divider()
                    .background(.white.opacity(0.2))
            }
        }
        .padding(.horizontal)
    }
}

public struct MainPlayerView: View {
    @EnvironmentObject var miniHandler: MinimizableViewHandler
    @EnvironmentObject var viewModel: SongViewModel
    
    @State var currentTime: Double = 0
    @State private var timer: Timer?
    @State var isFavorite: Bool = false
    @State private var sizeImage = UIScreen.main.bounds.width - 120
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                if self.viewModel.miniHandler.isMinimized {
                    BlurView()
                    // .cornerRadius(20)
                } else {
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#1c0d00") ?? .black, Color(hex: "#000000") ?? .black]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                }
                VStack {
                    VStack {
                        Capsule()
                            .fill(Color.gray)
                            .frame(width: 70, height: 5)
                            .padding(.top, 5)
                    }
                    .frame(width: self.miniHandler.isMinimized == false ? nil : 0, height: self.miniHandler.isMinimized == false ? nil : 0).opacity(self.miniHandler.isMinimized ? 0 : 1)
                    .padding(.top, self.miniHandler.isMinimized ? 0 : 10)
                    
                    if miniHandler.isMinimized {
                        VStack {
                            Spacer()
                            HStack {
                                Button {
                                    viewModel.togglePlayback()
                                } label: {
                                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(.white)
                                }
                                .buttonStyle(NoTapAnimationStyle())
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                )
                                .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(viewModel.selectedTrack?.name ?? "Be Yourself")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                    Text("\(viewModel.selectedTrack?.artist ?? "") • \(viewModel.selectedTrack?.totalDuration.formatTime() ?? "")")
                                        .font(.system(size: 14, weight: .regular))
                                        .lineLimit(1)
                                        .foregroundColor(Color(red: 0.44, green: 0.44, blue: 0.44))
                                }
                                Spacer()
                                Button {
                                    viewModel.onNextTrack()
                                } label: {
                                    Image(systemName: "forward.end.fill")
                                        .resizable()
                                        .foregroundColor(.white)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 25, height: 25)
                                }
                                .padding()
                                .buttonStyle(NoTapAnimationStyle())
                                BoostButton(isMini: true, imageName: "boostMiniIcon", width: 44, height: 44)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                    } else {
                        self.expandedControls
                    }
                }
            }
            .onTapGesture {
                if self.viewModel.miniHandler.isMinimized {
                    self.viewModel.miniHandler.expand()
                }
            }
        }.transition(AnyTransition.move(edge: .bottom))
    }
    
    var expandedControls: some View {
        VStack(spacing: 10) {
            ZStack {
                if let track = viewModel.selectedTrack,
                   let itemID = track.imageID?.uuidString,
                   let dataImage = FileHandler.shared.loadFile(from: itemID),
                   let uiImage = UIImage(data: dataImage) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: sizeImage, height: sizeImage)
                        .cornerRadius(6)
                } else {
                    Image("musicEmptyIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: sizeImage, height: sizeImage)
                        .cornerRadius(6)
                }
            }
            .padding(.top, 25)
            HorizontalEffectScrollView(effects: allEffects)
            
            Spacer()
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(viewModel.selectedTrack?.name ?? "Be Yourself")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.trailing, 25)
                                .lineLimit(2)
                            Spacer()
                            BoostButton(isMini: false, imageName: "boostMaxIcon", width: 107, height: 40)
                        }
                        Text(viewModel.selectedTrack?.artist ?? "Frank Ocean")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                }
                .padding()
                
                VStack {
                    MusicProgressSlider(value: $currentTime, currentTime: currentTime, inRange: 0...(viewModel.selectedTrack?.totalDuration ?? 0), totalTime: viewModel.selectedTrack?.totalDuration ?? 0) { started in
                        if !started {
                            viewModel.seek(to: CMTime(seconds: currentTime, preferredTimescale: 600))
                            viewModel.updateNowPlayingInfo(currentTime: currentTime)
                        }
                    }
                    .id("ProgressBar")
                    .frame(height: 10)
                    .padding(.vertical)
                    .onAppear {
                        currentTime = viewModel.currentTime
                        startTimer()
                    }
                    
                    VStack(spacing: 16) {
                        HStack {
                            Button {
                                viewModel.repeatMode = viewModel.repeatMode.nextMode
                                viewModel.setupPlaylist(mode: viewModel.repeatMode)
                            } label: {
                                Image(systemName: viewModel.repeatMode.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(viewModel.repeatMode == .once ? .white.opacity(0.5) : .white)
                            }
                            .buttonStyle(NoTapAnimationStyle())
                            
                            Spacer ()
                            
                            HStack(spacing: 40) {
                                Button {
                                    viewModel.onPreviousTrack()
                                } label: {
                                    Image(systemName: "backward.end.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 25, height: 25)
                                }
                                .buttonStyle(NoTapAnimationStyle())
                                Button {
                                    viewModel.togglePlayback()
                                } label: {
                                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.white)
                                }
                                .buttonStyle(NoTapAnimationStyle())
                                .frame(width: 85, height: 85)
                                .background(Color.black.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                )
                                .cornerRadius(8)
                                Button {
                                    viewModel.onNextTrack()
                                } label: {
                                    Image(systemName: "forward.end.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 25, height: 25)
                                }
                                .buttonStyle(NoTapAnimationStyle())
                            }
                            
                            Spacer()
                            
                            Button {
                                if let track = viewModel.selectedTrack {
                                    viewModel.updateIsFavorite(song: track, isFavorite: !track.isFavorite)
                                    isFavorite.toggle()
                                }
                            } label: {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)
                .padding(.bottom, 35)
            }
            .background(Color(hex: "#292929")?.ignoresSafeArea())
        }
        .onAppear {
            viewModel.updateNowPlayingInfo(currentTime: currentTime)
            if let track = viewModel.selectedTrack {
                isFavorite = track.isFavorite
            }
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: viewModel.selectedTrack, perform: { value in
            stopTimer()
            startTimer()
            
            if let track = viewModel.selectedTrack {
                isFavorite = track.isFavorite
            }
        })
    }
    
    private func startTimer() {
        var count = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0, repeats: true) { _ in
            print(viewModel.currentTime)
            currentTime = viewModel.currentTime
            if count == 0 {
                viewModel.updateNowPlayingInfo(currentTime: currentTime)
                count += 1
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

public struct NoTapAnimationStyle: PrimitiveButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .onTapGesture(perform: configuration.trigger)
    }
}

public struct MinimizableView<MainContent: View>: View {
    @EnvironmentObject var minimizableViewHandler: MinimizableViewHandler
    
    var geometry: GeometryProxy
    var contentView:  MainContent
    var minimizedBottomMargin: CGFloat
    var settings: MiniSettings
    
    var offsetY: CGFloat {
        
        if self.minimizableViewHandler.isMinimized {
            return self.minimizableViewHandler.draggedOffsetY < 0 ? self.minimizableViewHandler.draggedOffsetY : 0
        } else {
            return self.minimizableViewHandler.draggedOffsetY
        }
    }
    
    var positionY: CGFloat {
        if self.minimizableViewHandler.isMinimized {
            let dragCorrection = self.minimizableViewHandler.draggedOffsetY < 0 ? self.minimizableViewHandler.draggedOffsetY  : 0
            return geometry.size.height - settings.minimizedHeight / 2 - geometry.safeAreaInsets.bottom - minimizedBottomMargin - dragCorrection / 2
        } else {
            return geometry.size.height - (settings.overrideHeight ?? geometry.size.height) / 2
            
        }
    }
    
    var frameHeight: CGFloat? {
        
        if self.minimizableViewHandler.isMinimized {
            
            let draggedOffset: CGFloat = self.minimizableViewHandler.draggedOffsetY < 0 ? self.minimizableViewHandler.draggedOffsetY * (-1) : 0
            return self.settings.minimizedHeight + draggedOffset
            
        } else {
            return self.settings.overrideHeight
            
        }
    }
    
    public init(@ViewBuilder content: ()->MainContent, geometry: GeometryProxy, minimizedBottomMargin: CGFloat, settings: MiniSettings) {
        
        self.contentView = content()
        self.geometry = geometry
        self.minimizedBottomMargin = minimizedBottomMargin
        self.settings = settings
    }
    
    /**
     Body of MinimizableView.
     */
    public var body: some View {
        ZStack(alignment: .top) {
            if self.minimizableViewHandler.isPresented == true {
                self.contentView
                    .clipped()
            }
        }
        .frame(width: self.minimizableViewHandler.isMinimized ? geometry.size.width : geometry.size.width - self.settings.lateralMargin * 2, //self.settings.lateralMargin * 2
               height: self.frameHeight)
        .position(x: geometry.size.width / 2, y: self.positionY)
        .offset(y: self.offsetY)
    }
}

public struct MinimizableViewModifier<MainContent: View>: ViewModifier {
    @EnvironmentObject var minimizableViewHandler: MinimizableViewHandler
    
    var contentView:  ()-> MainContent
    var dragOffset: GestureState<CGSize>
    var dragUpdating: (DragGesture.Value, inout CGSize, inout SwiftUICore.Transaction)->()
    var dragOnChanged: (DragGesture.Value)->()
    var dragOnEnded: (DragGesture.Value)->()
    
    var minimizedBottomMargin: CGFloat
    var settings: MiniSettings
    
    public func body(content: Content) -> some View {
        GeometryReader { proxy in
            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                content.zIndex(0)
                if self.minimizableViewHandler.isPresented {
                    MinimizableView(content: contentView, geometry: proxy, minimizedBottomMargin: minimizedBottomMargin, settings: settings)
                        .environmentObject(self.minimizableViewHandler).opacity(self.minimizableViewHandler.isVisible ? 1 : 0)
                        .gesture(DragGesture(minimumDistance: settings.minimumDragDistance,  coordinateSpace: .global)
                            .onChanged(self.dragOnChanged)
                            .updating(dragOffset, body:self.dragUpdating)
                            .onEnded(self.dragOnEnded))
                        .simultaneousGesture(MagnificationGesture().onEnded({ value in
                            if self.minimizableViewHandler.draggedOffsetY > 10 || self.minimizableViewHandler.draggedOffsetY < 0 {
                                self.minimizableViewHandler.minimize()
                                self.minimizableViewHandler.draggedOffsetY = 0
                            }
                        }))
                        .zIndex(1)
                        .transition(AnyTransition.move(edge: .bottom))
                }
            }
        }.edgesIgnoringSafeArea(settings.edgesIgnoringSafeArea)
    }
}

public extension View {
    func minimizableView<MainContent: View>(@ViewBuilder content: @escaping ()->MainContent, dragOffset:  GestureState<CGSize>, dragUpdating: @escaping (DragGesture.Value, inout CGSize, inout SwiftUICore.Transaction)->(), dragOnChanged: @escaping (DragGesture.Value)->(),  dragOnEnded: @escaping (DragGesture.Value)->(), minimizedBottomMargin: CGFloat = 81,  settings: MiniSettings = MiniSettings())->some View  {
        self.modifier(MinimizableViewModifier(contentView: content, dragOffset: dragOffset , dragUpdating: dragUpdating, dragOnChanged: dragOnChanged,  dragOnEnded: dragOnEnded,   minimizedBottomMargin: minimizedBottomMargin, settings: settings))
    }
}

public struct HorizontalEffectScrollView: View {
    @State private var selectedEffect: UUID
    let effects: [EffectModel]
    
    public init(effects: [EffectModel]) {
        self.effects = effects
        // По умолчанию выбрана центральная ячейка
        _selectedEffect = State(initialValue: effects[effects.count / 2].id)
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(effects) { effect in
                        VStack(spacing: 8) {
                            Button(action: {
                                withAnimation {
                                    selectedEffect = effect.id
                                }
                            }) {
                                Image(effect.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: selectedEffect == effect.id ? 32 : 26, height: selectedEffect == effect.id ? 32 : 26)
                                    .foregroundColor(selectedEffect == effect.id ? .white : .gray)
                                
                            }
                            .frame(width: selectedEffect == effect.id ? 68 : 58,
                                   height: selectedEffect == effect.id ? 68 : 58)
                            .background(LinearGradient(gradient: Gradient(colors: selectedEffect == effect.id ?
                                                                          [Color(hex: "#A63103") ?? .black,
                                                                           Color(hex: "#FF6504") ?? .black,
                                                                           Color(hex: "#FFFF0C") ?? .black] : [.white.opacity(0.1)]),
                                                       
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing))
                            .cornerRadius(7)
                            Text(effect.name)
                                .font(.system(size: selectedEffect == effect.id ? 16 : 14, weight: selectedEffect == effect.id ? .bold : .regular ))
                                .foregroundColor(selectedEffect == effect.id ? .white : .gray)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 120)
            .onAppear {
                DispatchQueue.main.async {
                    proxy.scrollTo(selectedEffect, anchor: .center)
                }
            }
        }
    }
}

public struct MusicProgressSlider<T: BinaryFloatingPoint>: View {
    @Binding var value: T
    let currentTime: Double
    let inRange: ClosedRange<T>
    let totalTime: Double
    let height: CGFloat = 8
    let onEditingChanged: (Bool) -> Void

    // private variables
    @State private var localRealProgress: T = 0
    @State private var localTempProgress: T = 0
    @GestureState private var isActive: Bool = false
    @State private var progressDuration: T = 0
        
    public init(
        value: Binding<T>,
        currentTime: Double,
        inRange: ClosedRange<T>,
        totalTime: Double,
        onEditingChanged: @escaping (Bool) -> Void
    ) {
        self._value = value
        self.currentTime = currentTime
        self.inRange = inRange
        self.totalTime = totalTime
        self.onEditingChanged = onEditingChanged
    }
    
    public var body: some View {
        GeometryReader { bounds in
            ZStack(alignment: .leading) {
                VStack {
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: bounds.size.width, height: height)
                            .opacity(0.3)
                            .foregroundColor(Color.gray)
                            .cornerRadius(10.0)
                        
                        Rectangle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#A63103") ?? .black,
                                                            Color(hex: "#FF6504") ?? .black,
                                                            Color(hex: "#FFFF0C") ?? .black]),
                                
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(height: height)
                            .frame(width: max(bounds.size.width * CGFloat((localRealProgress + localTempProgress)), 0), alignment: .leading)
                            .cornerRadius(10.0)
                        
                        Circle()
                            .frame(height: 16)
                            .foregroundColor(Color.white)
                            .offset(x: max(bounds.size.width  * CGFloat((localRealProgress + localTempProgress)), 0) - 3)
                    }
                    
                    
                    HStack {
                        if isActive {
                            Text(progressDuration.asTimeString(style: .positional))
                                .font(.system(size: 14, weight: .medium, design: .default))
                                .foregroundColor(.white)
                        } else {
                            Text(currentTime.formatTime())
                                .font(.system(size: 14, weight: .medium, design: .default))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text(totalTime.formatTime())
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                    }
                    .padding(.top, 3)
                    
                }
            }
            //.shadow(color: .black.opacity(0.1), radius: isActive ? 20 : 0, x: 0, y: 0)
            .frame(width: bounds.size.width, alignment: .center)
            .animation(animation, value: isActive)
            .frame(width: bounds.size.width, height: bounds.size.height, alignment: .center)
            
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .updating($isActive) { value, state, transaction in
                    state = true
                }
                .onChanged { gesture in
                    localTempProgress = T(gesture.translation.width / bounds.size.width)
                    let prg = max(min((localRealProgress + localTempProgress), 1), 0)
                    progressDuration = inRange.upperBound * prg
                    value = max(min(getPrgValue(), inRange.upperBound), inRange.lowerBound)
                }.onEnded { value in
                    localRealProgress = max(min(localRealProgress + localTempProgress, 1), 0)
                    localTempProgress = 0
                    progressDuration = inRange.upperBound * localRealProgress
                })
            .onChange(of: isActive) { newValue in
                value = max(min(getPrgValue(), inRange.upperBound), inRange.lowerBound)
                onEditingChanged(newValue)
            }
            .onAppear {
                localRealProgress = getPrgPercentage(value)
                progressDuration = inRange.upperBound * localRealProgress
            }
            .onChange(of: value) { newValue in
                if !isActive {
                    localRealProgress = getPrgPercentage(newValue)
                }
            }
        }
    }
    
    private var animation: Animation {
        if isActive {
            return .spring()
        } else {
            return .spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.6)
        }
    }
    
    private func getPrgPercentage(_ value: T) -> T {
        let range = inRange.upperBound - inRange.lowerBound
        let correctedStartValue = value - inRange.lowerBound
        let percentage = correctedStartValue / range
        return percentage
    }
    
    private func getPrgValue() -> T {
        return ((localRealProgress + localTempProgress) * (inRange.upperBound - inRange.lowerBound)) + inRange.lowerBound
    }
}

public struct MySongsView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var isOpenPremium = false
    @State private var isOpenSettings = false
    @EnvironmentObject var viewModel: SongViewModel
    
    public init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
    }
    
    public var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#1c0d00") ?? .black, Color(hex: "#000000") ?? .black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack {
                HStack {
                    Button {
                        isOpenSettings = true
                    } label: {
                        Image("settingsDotsIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 5)
                    }
                    .padding(.leading)
                    Spacer()
                    Text("My Songs")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                    Button {
                        isOpenPremium = true
                    } label: {
                        Image("crownPremiumIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    .opacity(purchaseManager.isPremium ? 0 : 1)
                    .disabled(purchaseManager.isPremium)
                    .padding(.trailing)
                }
                .background(Color(hex: "#292929").ignoresSafeArea(.container, edges: .top))
                
                if viewModel.allTracks.isEmpty {
                    Spacer()
                    EmptyListView(title: "No songs yet!", image: "musicIcon")
                    ImportHeaderView()
                        .frame(width: UIScreen.main.bounds.width / 2)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack {
                            ForEach(Array(viewModel.allTracks.reversed().enumerated()), id: \.element.id) { index, track in
                                TrackListCell(track: track)
                                //if index != viewModel.allTracks.count - 1 {
                                Divider()
                                    .background(.white.opacity(0.2))
                                // }
                            }
                            ImportHeaderView()
                                .frame(width: UIScreen.main.bounds.width / 2)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, (viewModel.miniHandler.isPresented ? (UIDevice.current.hasNotch ? 135 : 135)
                                           : (UIDevice.current.hasNotch ? 80 : 70)))
                    }
                }
                Spacer()
            }
            .fullScreenCover(isPresented: $isOpenPremium) {
                PaywallView(showTabBar: false)
            }
            .fullScreenCover(isPresented: $isOpenSettings) {
                SettingsView()
            }
            .onAppear {
                purchaseManager.checkSubscriptionStatus()
            }
        }
    }
}

public struct TrackListCell: View {
    @EnvironmentObject var viewModel: SongViewModel
    @State var track: SongEntity
    @State private var showActionSheet = false
    @State var isShowEdit = true
    
    public init(track: SongEntity, isShowEdit: Bool? = true) {
        self._track = State(initialValue: track)
        self._isShowEdit = State(initialValue: isShowEdit ?? true) // Provide a default value
    }

    public var body: some View {
        ZStack(alignment: .trailing) {
            Button(action: {
                viewModel.togglePlayback(track: track, playlist: Array(isShowEdit ? viewModel.allTracks : viewModel.onboardingTracks))
            }) {
                HStack(spacing: 10) {
                    ZStack {
                        if let itemID = track.imageID?.uuidString,
                           let dataImage = FileHandler.shared.loadFile(from: itemID),
                           let uiImage = UIImage(data: dataImage) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 48, height: 48)
                                .cornerRadius(10)
                        } else {
                            Image("musicEmptyIcon")
                                .resizable()
                                .frame(width: 48, height: 48)
                                .cornerRadius(10)
                        }
                       
                    }
                    VStack(alignment: .leading) {
                        Text(track.name ?? "")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text("\(track.artist ?? "") • \(track.totalDuration.formatTime())")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.white)
                    }
                    .padding(.trailing)
                    Spacer()
                }
                .padding(.vertical)

            }
            .frame(height: 60)
            .buttonStyle(NoTapAnimationStyle())
            if isShowEdit {
                Button {
                    showActionSheet.toggle()
                } label: {
                    Image("settingsDotsIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 40)
                }
            }
        }
        .padding(8)
        .background((track.id == viewModel.selectedTrack?.id ? Color.white.opacity(0.05) : Color.clear))
        .cornerRadius(12)
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(title: Text("Choose Action"), buttons: [
                .default(Text(track.isFavorite ? "Remove From Favorites" : "Add To Favorites"), action: {
                    viewModel.updateIsFavorite(song: track, isFavorite: !track.isFavorite)
                    }),
                .destructive(Text("Delete"), action: {
                    showDeleteConfirmation()
                }),
                .cancel()
            ])
        }
    }

    func showDeleteConfirmation() {
        let alert = UIAlertController(title: "Are you sure you want to delete?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            deleteTrack()
        }))
        
        if let viewController = UIApplication.getTopViewController() {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func deleteTrack() {
        viewModel.deleteSong(song: track)
        
        if let trackID = track.id {
            FileHandler.shared.deleteFile(fileID: trackID.uuidString)
            // Remove the tracks from the current playlist
            viewModel.currentPlaylist.removeAll { $0.id == trackID }
            
            if let currentTrack = viewModel.selectedTrack, currentTrack.id == trackID {
                viewModel.stopCurrentPlay()
            }
        }
    }
}

public struct ImportButton: View {
    let title: String
    let iconName: String
    let action: () -> Void
    
    public init(title: String, iconName: String, action: @escaping () -> Void) {
        self.title = title
        self.iconName = iconName
        self.action = action
    }
    
    public var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "#A63103") ?? .black,
                                            Color(hex: "#FF6504") ?? .black,
                                            Color(hex: "#FFFF0C") ?? .black]),
                
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            Button(action: action) {
                VStack {
                    HStack(spacing: 13) {
                        Spacer()
                        Text(title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Image(iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
            }
        }
        .cornerRadius(7)
        .frame(height: 50)
    }
}

public struct ShuffleButton: View {
    let title: String
    let iconName: String
    let action: () -> Void
    
    public init(title: String, iconName: String, action: @escaping () -> Void) {
        self.title = title
        self.iconName = iconName
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 13) {
                Spacer()
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
                Spacer()
            }
            
            .buttonStyle(NoTapAnimationStyle())
            .frame(width: 140, height: 50)
            .background(Color(hex: "292929"))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
            )
            .cornerRadius(8)
            
        }
    }
}

public struct BoostButton: View {
    var isMini: Bool
    var imageName: String
    var width: Double
    var height: Double
    @State private var isShowBoostView = false

    public init(isMini: Bool, imageName: String, width: Double, height: Double) {
        self.isMini = isMini
        self.imageName = imageName
        self.width = width
        self.height = height
    }
    
    public var body: some View {
        Button {
            isShowBoostView.toggle()
        } label: {
            HStack(spacing: 8) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
                if !isMini {
                    Text("Boost")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
        }
        .frame(width: width,
               height: height)
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#A63103") ?? .black,
                                                       Color(hex: "#FF6504") ?? .black,
                                                       Color(hex: "#FFFF0C") ?? .black]),
                                   
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing))
        .cornerRadius(7)
        .sheet(isPresented: $isShowBoostView) {
            BoostConfigView()
        }
    }
}

public struct ImportHeaderView: View {
    @EnvironmentObject var viewModel: SongViewModel
    @State private var isDocumentPickerPresented = false
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var isOpenPremium = false
    
    public var body: some View {
        ImportButton(title: "Import Song", iconName: "musicIcon") {
            if purchaseManager.isPremium {
                isDocumentPickerPresented.toggle()
            } else {
                isOpenPremium = true
            }
        }
        .fullScreenCover(isPresented: $isOpenPremium) {
            PaywallView(showTabBar: false)
        }
        .onAppear {
            purchaseManager.checkSubscriptionStatus()
        }
        
        // Files Picker
        .fileImporter( isPresented: $isDocumentPickerPresented, allowedContentTypes: [.mp3, .mpeg4Audio, .audio], allowsMultipleSelection: true, onCompletion: { (Result) in
            do {
                let urls = try Result.get()
                for url in urls {
                    let StartAccess = url.startAccessingSecurityScopedResource()
                    defer {
                        if StartAccess {
                            url.stopAccessingSecurityScopedResource()
                        }
                    }
                    if let trackInfo = ConvertManager.shared.getFileMetadata(from: url) {
                        do {
                            let songData = try Data(contentsOf: url)
                            viewModel.saveSong(data: songData, song: trackInfo)
                        } catch {
                            print("Error loading test song data: \(error)")
                        }
                    }
                }
            } catch{
                print("error reading file \(error.localizedDescription)")
            }
        })
    }
}
