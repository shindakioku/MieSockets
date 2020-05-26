import Foundation

extension MieSockets {
    @propertyWrapper
    @available(iOS 13.0, *)
    public class RouterWrapperWithDecodable<T: Decodable> {
        @Published public var value: T?
        
        public init(
            url: MieSockets.RouteUrl,
            decodeAs: T.Type,
            namedParams: MieSockets.RouteNamedParams = []
        ) {
            self.value = nil
            
            MieSockets.SocketSingleton.shared.instance.router.add(url, namedParams) { [weak self] in
                do {
                    self?.value = try JSONDecoder().decode(T.self, from: $0.rawData)
                } catch {
                    print("Error in RouterWrapperWithDecodable for: \(url). Error: \(error)")
                }
            }
        }
        
        public var wrappedValue: T? {
            get { value }
            set { value = newValue }
        }
    }
}
