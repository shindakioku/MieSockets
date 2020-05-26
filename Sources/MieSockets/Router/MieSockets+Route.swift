import Foundation

extension MieSockets {
    public class Route {
        public typealias Url = String
        public typealias NamedParams = Array<String>
        
        internal let url: Url
        internal let handler: RouteHandler
        internal let namedParams: NamedParams
        
        public init(_ url: Url, _ handler: RouteHandler, _ namedParams: NamedParams = []) {
            self.url = url
            self.handler = handler
            self.namedParams = namedParams
        }
    }
}
