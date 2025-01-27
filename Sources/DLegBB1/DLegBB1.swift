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
            } else {
                // Fallback on earlier versions
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
    let trackerRotation: Double = 2
    let animationDuration: Double = 0.75
    
    @State var isAnimating: Bool = false
    @State var circleStart: CGFloat = 0.17
    @State var circleEnd: CGFloat = 0.6
    
    @State var rotationDegree: Angle = Angle.degrees(0)
    
    // MARK:- views
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
    
    func getRotationAngle() -> Angle {
        return .degrees(360 * self.trackerRotation) + .degrees(120)
    }
    
    func animateLoader() {
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
            .onAppear {
                Apphud.paywallsDidLoadCallback { paywalls in
                    if let paywall = paywalls.first(where: { $0.identifier == (UserDefaults.standard.bool(forKey: "HasShownTabbar") ? "inapp_paywall" : "onboarding_paywall") }) {
                        apphudProducts = paywall.products
                    }
                }
            }
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
    

 
