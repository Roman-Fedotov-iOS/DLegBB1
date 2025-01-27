import SwiftUI
import UIKit
import StoreKit
import CoreHaptics
import AVFoundation
import CoreData
import MediaPlayer
import ApphudSDK

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
//                TabBarView()
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
//                TabBarView()
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
