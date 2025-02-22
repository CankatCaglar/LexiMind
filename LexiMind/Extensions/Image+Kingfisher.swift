import SwiftUI
import Kingfisher

extension KFImage {
    func setupImage(placeholder: Image = Image(systemName: "photo")) -> some View {
        self
            .placeholder { _ in
                placeholder
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .fade(duration: 0.25)
            .onFailure { error in
                print("Error loading image: \(error)")
            }
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct KFImageView: View {
    let urlString: String?
    let placeholder: Image
    let size: CGSize
    
    init(urlString: String?,
         placeholder: Image = Image(systemName: "person.circle.fill"),
         size: CGSize = CGSize(width: 100, height: 100)) {
        self.urlString = urlString
        self.placeholder = placeholder
        self.size = size
    }
    
    var body: some View {
        Group {
            if let url = urlString, let imageURL = URL(string: url) {
                KFImage(imageURL)
                    .setupImage(placeholder: placeholder)
                    .frame(width: size.width, height: size.height)
                    .clipShape(Circle())
            } else {
                placeholder
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
                    .clipShape(Circle())
            }
        }
    }
}

#Preview {
    KFImageView(urlString: "https://example.com/image.jpg")
} 