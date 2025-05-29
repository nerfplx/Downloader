import SwiftUI

struct AnimatedButtonView: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    
    @State private var isHovered = false
    @GestureState private var isPressed = false
    
    var body: some View {
        let pressGesture = LongPressGesture(minimumDuration: 0.01)
            .updating($isPressed) { current, state, _ in
                state = current
            }
            .onEnded { _ in
                if isEnabled { action() }
            }
        
        Text(title)
            .font(.custom("UbuntuSansMono-Regular", size: 18))
            .foregroundColor(isEnabled ? .black.opacity(0.7) : .gray)
            .padding(.horizontal, 44)
            .padding(.vertical, 20)
            .background(.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 50)
                    .stroke(isEnabled ? .black.opacity(0.7) : .gray, lineWidth: 1)
            )
            .offset(y: isPressed ? 10 : (isHovered ? -10 : 0))
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
            .onHover { hovering in
                if isEnabled { isHovered = hovering }
            }
            .gesture(isEnabled ? pressGesture : nil)
            .opacity(isEnabled ? 1.0 : 0.5)
    }
}
