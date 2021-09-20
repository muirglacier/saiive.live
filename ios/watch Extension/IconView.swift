import SwiftUI

struct IconView: View {
    var token: String
    @State private var image: Image?
    @State private var imageTriedLoading: Bool = false
    
    static private var colors: [String: Color] = [:];
    
    var body: some View {
        VStack {
            if (image != nil) {
                image?
                    .resizable()
                    .frame(width: 32.0, height: 32.0)
                
            }
            else {
                Text(token.prefix(1).uppercased())
                    .padding()
                    .background(getTokenColor())
                    .clipShape(Circle())
                    .frame(width: 32, height: 32, alignment: .center)
                
            }
        }
        .onAppear(perform: loadImage)
    }
    
    func getTokenColor() -> Color {
        var color: Color = Color.random;
        
        if IconView.colors.keys.contains(token) {
            color = IconView.colors[token]!
        } else {
            color = Color.random
            IconView.colors[token] = color
        }
        
        return color;
    }
    
    func loadImage() {
        if (false == imageTriedLoading) {
            let uiImage: UIImage? = UIImage(named: token.lowercased() + "-icon")
            
            if (uiImage != nil) {
                image = Image(uiImage: uiImage!)
            }
            
            imageTriedLoading = true
        }
    }
}
