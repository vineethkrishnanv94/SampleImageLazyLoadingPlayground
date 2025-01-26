# SwiftUI Playground: Lazy Loading Remote URL Images with Caching

This Xcode playground demonstrates how to efficiently load and display remote images in a SwiftUI `LazyVStack` with a **lazy loading** and caching mechanism. The implementation includes `NSCache` to optimize performance by storing downloaded images and reducing redundant network requests.

## Features

- **Lazy Loading:** Images are fetched and displayed only when they appear on the screen.
- **Image Caching with `NSCache`:** Ensures previously loaded images are stored and reused.
- **SwiftUI Preview in Playground:** Uses `PlaygroundPage.setLiveView` to preview SwiftUI content within the playground.

---

## How It Works

### 1. Caching with `NSCache`

An `ImageCache` singleton is implemented to store downloaded images in memory using `NSCache`. This improves efficiency by avoiding unnecessary network requests.

```swift
class ImageCache {
    static let shared = ImageCache()
    private init() {}
    private let cache = NSCache<NSString, UIImage>()
    
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func saveImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
```

### 2. Caching with Remote Images
The ImageLoader class fetches the image from the provided URL and caches it after downloading. If the image is already cached, it retrieves it from memory instead of making a network call.

```swift
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
        URLSession.shared.dataTask(with: imageUrl) { data, _, error in
            guard let data, let downloadedImage = UIImage(data: data), error == nil else { return }
            ImageCache.shared.saveImage(downloadedImage, forKey: self.urlString)
            DispatchQueue.main.async {
                self.image = downloadedImage
            }
        }.resume()
    }
}
```
### SwiftUI View with Lazy Loading
The LazyImageView view leverages StateObject to handle image loading and display a placeholder while the image is being fetched.

```swift
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
        } else {
            ProgressView().frame(height: 50)
        }
    }
}
```
Displaying SwiftUI Content with .setLiveView
In Xcode playgrounds, PlaygroundSupport is used to preview SwiftUI views in real time.

```swift
import PlaygroundSupport

PlaygroundPage.current.setLiveView(ContentView())
```
Running the Playground

Open the Xcode playground file.


Ensure you have an active internet connection to fetch remote images.


Run the playground to observe the lazy loading and caching in action.


