import SwiftUI
import UIKit

public enum LinksConstants {
    static let privacy = "https://sites.google.com/view/bassbooster-privacy-policy"
    static let terms = "https://sites.google.com/view/bassbooster-terms-of-use"
    static let share = "https://itunes.apple.com/app/id6738697391"
    static let support = "nancycastillo56789@outlook.com"
}

public struct SplashView: View {
    
    static var image: String?

    @available(iOS 13.0.0, *)
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
                Image(SplashView.image!)
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

@available(iOS 13.0, *)
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

@available(iOS 13.0, *)
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
