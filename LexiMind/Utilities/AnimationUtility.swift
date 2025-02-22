import SwiftUI
import Lottie
import SnapKit

class AnimationUtility {
    static func playAnimation(name: String, in view: UIView, loopMode: LottieLoopMode = .playOnce, completion: (() -> Void)? = nil) {
        let animationView = LottieAnimationView(name: name)
        view.addSubview(animationView)
        
        animationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(200)
        }
        
        animationView.loopMode = loopMode
        animationView.play { finished in
            if finished {
                animationView.removeFromSuperview()
                completion?()
            }
        }
    }
    
    static func createAnimationView(name: String, loopMode: LottieLoopMode = .loop) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit
        return animationView
    }
    
    // Achievement animation
    static func playAchievementAnimation(in view: UIView, completion: (() -> Void)? = nil) {
        playAnimation(name: "achievement", in: view) {
            Task { @MainActor in
                MessageUtility.showSuccess(
                    title: "Tebrikler!",
                    message: "Yeni bir başarı kazandınız!",
                    theme: Theme.default
                )
                completion?()
            }
        }
    }
    
    // Level up animation
    static func playLevelUpAnimation(in view: UIView, completion: (() -> Void)? = nil) {
        playAnimation(name: "level-up", in: view) {
            Task { @MainActor in
                MessageUtility.showSuccess(
                    title: "Seviye Atladınız!",
                    message: "Bir sonraki seviyeye ulaştınız!",
                    theme: Theme.default
                )
                completion?()
            }
        }
    }
    
    // Streak animation
    static func playStreakAnimation(in view: UIView, days: Int, completion: (() -> Void)? = nil) {
        playAnimation(name: "streak", in: view) {
            Task { @MainActor in
                MessageUtility.showSuccess(
                    title: "Seri!",
                    message: "\(days) günlük seri! Harika gidiyorsun!",
                    theme: Theme.default
                )
                completion?()
            }
        }
    }
    
    static func getAnimationSequence(for avatar: Avatar) -> AnimationSequence? {
        guard avatar.isAnimated else { return nil }
        
        switch avatar.name {
        case "Sparkly":
            return AnimationSequence(
                frames: ["sparkly_1", "sparkly_2", "sparkly_3"],
                duration: 0.5,
                repeatCount: 3,
                triggers: [.onAppear, .onTap]
            )
        case "Rainbow":
            return AnimationSequence(
                frames: ["rainbow_1", "rainbow_2", "rainbow_3", "rainbow_4"],
                duration: 1.0,
                repeatCount: -1,
                triggers: [.continuous]
            )
        case "Seasonal":
            return AnimationSequence(
                frames: ["seasonal_1", "seasonal_2"],
                duration: 0.3,
                repeatCount: 1,
                triggers: [.onTap]
            )
        default:
            return nil
        }
    }
    
    @ViewBuilder
    static func applyAnimation<V: View>(
        to view: V,
        sequence: AnimationSequence,
        trigger: AnimationTrigger
    ) -> some View {
        if !sequence.triggers.contains(trigger) {
            AnyView(view)
        } else {
            switch trigger {
            case .onAppear:
                AnyView(
                    view.onAppear {
                        withAnimation(
                            .easeInOut(duration: sequence.duration)
                            .repeatCount(sequence.repeatCount)
                        ) {
                            // Animation logic here
                        }
                    }
                )
            case .onTap:
                AnyView(
                    view.onTapGesture {
                        withAnimation(
                            .easeInOut(duration: sequence.duration)
                            .repeatCount(sequence.repeatCount)
                        ) {
                            // Animation logic here
                        }
                    }
                )
            case .continuous:
                AnyView(
                    view.modifier(
                        ContinuousAnimationModifier(
                            duration: sequence.duration,
                            frames: sequence.frames,
                            repeatCount: sequence.repeatCount
                        )
                    )
                )
            }
        }
    }
}

struct ContinuousAnimationModifier: ViewModifier {
    let duration: Double
    let frames: [String]
    let repeatCount: Int
    @State private var currentFrame = 0
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                withAnimation(
                    .linear(duration: duration)
                    .repeatCount(repeatCount)
                ) {
                    // Animation logic here
                }
            }
    }
}

extension View {
    func applyAnimation(
        sequence: AnimationSequence?,
        trigger: AnimationTrigger
    ) -> some View {
        guard let sequence = sequence else { return AnyView(self) }
        return AnyView(AnimationUtility.applyAnimation(
            to: self,
            sequence: sequence,
            trigger: trigger
        ))
    }
} 