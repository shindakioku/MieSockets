import Foundation

extension MieSockets {
    /// Base class for define routes. You must use router from MieSockets.Socket.
    public class Router {
        /// Extracted params with names. For example [[id: 1], [username: user]]
        public typealias AssociatedParams = Dictionary<String, Any>
        
        /// Way with passing lambda-function for route handler
        public class RouteHandlerWithEvent: RouteHandler {
            internal let handler: (HandledRoute) -> Void
            
            public init(_ handler: @escaping (HandledRoute) -> Void) {
                self.handler = handler
            }
            
            public func handle(_ handledRoute: HandledRoute) -> Void {
                self.handler(handledRoute)
            }
        }
        
        /// List of available routes
        internal var routes: [Route] = []
        
        /// Adding new route
        ///
        /// ```
        /// MieSockets.Socket().router.add(MieSockets.Route("messages", self))
        ///
        /// MieSockets.Socket().router
        ///     .add(MieSockets.Route("users/([0-9]+$)", self))
        ///     .add(MieSockets.Route("users/([0-9]+$)/profile", self))
        /// ```
        ///
        ///  - Parameter route: The Route with defined URL and handler
        ///  - Returns: Pointer on the router object so you can use fluent interface for defining routes.
        @discardableResult
        public func add(_ route: Route) -> Self {
            routes.append(route)
            
            return self
        }
        
        /// Adding new route
        ///
        /// ```
        /// MieSockets.Socket().router.add("messages", self)
        ///
        /// MieSockets.Socket().router
        ///     .add("users/([0-9]+$)", self, ["id"])
        ///     .add("users/([0-9]+$)/profile", self)
        /// ```
        ///
        ///  - Parameter url: URL
        ///  - Parameter handler: Route Handler
        ///  - Returns: Pointer on the router object so you can use fluent interface for defining routes.
        @discardableResult
        public func add(_ url: MieSockets.RouteUrl, _ handler: RouteHandler, _ namedParams: MieSockets.RouteNamedParams = []) -> Self {
            add(Route(url, handler, namedParams))
        }
        
        
        /// Adding new route with handler as lambda-function
        ///
        /// ```
        /// MieSockets.Socket().router.add("messages", self) { (handledRoute: HandledRoute) in dump(handledRoute) }
        /// ```
        @discardableResult
        public func add(
            _ url: MieSockets.RouteUrl,
            _ namedParams: MieSockets.RouteNamedParams = [],
            _ handler: @escaping (HandledRoute) -> Void
        ) -> Self {
            add(Route(url, RouteHandlerWithEvent(handler), namedParams))
        }
        
        /// TODO: Use function composition for work with extract and creating handledRoute
        /// Find router by url
        internal func find(_ url: MieSockets.RouteUrl) -> Route? {
            return routes.first(where: { url.range(of: $0.url, options: .regularExpression) != nil })
        }
        
        /// Extract regex matches
        internal func extractParamsByFoundRoute(_ route: Route, _ urlWithData: String) -> Array<String>? {
            do {
                let regex = try NSRegularExpression(pattern: route.url)
                guard let result =
                    regex.matches(in: urlWithData, range: NSRange(urlWithData.startIndex..., in: urlWithData)).first
                    else { return nil }
                
                let nsString = urlWithData as NSString
                return (0..<result.numberOfRanges)
                    .filter{ result.range(at: $0).location != NSNotFound }
                    .dropFirst() // url param
                    .map { nsString.substring(with: result.range(at: $0)) }
            } catch {
                print("Regex error: \(error)")
                
                return nil
            }
        }
        
        internal func toHandledRoute(route: Route, urlWithData: String, rawData: Data, extractedParams: Array<String>) -> HandledRoute {
            BaseHandledRoute(
                rawData: rawData,
                associatedParams: Dictionary(uniqueKeysWithValues: zip(route.namedParams, extractedParams)),
                extractedParams: extractedParams,
                originalUrl: route.url,
                urlWithData: urlWithData
            )
        }
    }
}
