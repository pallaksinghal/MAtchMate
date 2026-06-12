import SwiftUI
import SDWebImageSwiftUI

struct ProfileImageView: View {
    let url: String?

    var body: some View {
        if let urlString = url, let imageURL = URL(string: urlString) {
            WebImage(url: imageURL)
                .resizable()
                .indicator(.activity)
                .transition(.fade(duration: 0.3))
                .scaledToFill()
        } else {
            placeholderView
        }
    }

    private var placeholderView: some View {
        ZStack {
            Color(.systemGray5)
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
        }
    }
}
