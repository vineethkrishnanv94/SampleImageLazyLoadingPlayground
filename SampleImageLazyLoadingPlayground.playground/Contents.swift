//: A UIKit based Playground for presenting user interface
  

import PlaygroundSupport
import SwiftUI
import UIKit

class ImageCache {
    static let shared = ImageCache()
    private init() {
        
    }
    private let cache = NSCache<NSString, UIImage>()
    
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func saveImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private var urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
        loadImage()
    }
    
    func loadImage() {
        
        if let cachedImage = ImageCache.shared.getImage(forKey: urlString) {
            self.image = cachedImage
            return
        }
        
        guard let imageUrl = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            guard let data, let downloadedImage = UIImage(data: data), error == nil else { return }
            ImageCache.shared.saveImage(downloadedImage, forKey: self.urlString )
                        
            DispatchQueue.main.async {
                self.image = downloadedImage
            }

        }.resume()
    }
    
}

struct LazyImageView: View {
    let url: String
    @StateObject private var loader: ImageLoader
    
    init(url: String) {
        self.url = url
        _loader = StateObject(wrappedValue: ImageLoader(urlString: url))
    }
    
    var body: some View {
        
        if let image = loader.image {

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        else {
            ProgressView().frame(height: 50)
        }
    }
    
}

struct ContentView: View {
    let imageURLs = [
           "https://picsum.photos/200/300",
           "https://picsum.photos/200/400",
           "https://picsum.photos/200/500",

       ]
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(imageURLs, id: \.self) { url in
                    LazyImageView(url: url)
                        .padding()
                }
            }
        }
    }
}


// Present the view in the Live View window
PlaygroundPage.current.setLiveView(ContentView())
