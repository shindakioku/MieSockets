import Foundation

import Starscream

extension MieSockets {
    /// Need for property wrappers for urls. You must use it instead of Socket
    public class SocketSingleton {
        public var instance: Socket!
        
        public static let shared = SocketSingleton()
        private init() {}
        
    }
    
    public class Socket: WebSocketDelegate {
        /// Server url
        internal let url: URL
        
        public let socket: WebSocket
        public let router: MieSockets.Router
        
        /// Global handlers
        public var connectedHandler: MieSockets.ConnectedHandler = DefaultSocketConnectedHandler()
        public var disconnectedHandler: MieSockets.DisconnectedHandler = DefaultSocketDisconnectedHandler()
        public var errorHandler: MieSockets.ErrorHandler = DefaultSocketErrorHandler()
        public var receivedDataHandler: MieSockets.ReceivedDataHandler = DefaultSocketReceivedDataHandler()
        public var reconnectHandler: MieSockets.ReconnectHandler = DefaultSocketReconnectHandler()
        public var cancelledHandler: MieSockets.CancelledHandler = DefaultSocketCancelledHandler()
        
        public var hydrator: ReceivedDataHydrator = DefaultReceivedDataHydrator()
        
        public init(
            url: String,
            setupRequestObject: ((URLRequest) -> URLRequest)? = nil
        ) {
            self.url = URL(string: url)!
            self.router = MieSockets.Router()
            
            var request = URLRequest(url: self.url)
            if let setupRequestObject = setupRequestObject {
                request = setupRequestObject(request)
            } else {
                request.timeoutInterval = 5
            }
            self.socket = WebSocket(request: request)
            self.socket.delegate = self
        }
        
        public func connect() -> Self {
            socket.connect()
            
            return self
        }
        
        public func didReceive(event: WebSocketEvent, client: WebSocket) -> Void {
            switch event {
            case .connected(let headers):
                connectedHandler.handle(headers: headers)
            case .disconnected(let reason, let code):
                disconnectedHandler.handle(reason: reason, code: code)
            case .text(let string):
                onReceivedData(string.data(using: .utf8) ?? "".data(using: .utf8)!)
            case .binary(let data):
                onReceivedData(data)
            case .reconnectSuggested(let status):
                reconnectHandler.handle(status: status)
            case .cancelled:
                cancelledHandler.handle()
            case .error(let error):
                errorHandler.handle(error: error)
            default:
                break
            }
        }
        
        internal func onReceivedData(_ data: Data) -> Void {
            receivedDataHandler.handle(data: data)
            
            guard let hydratedData = hydrator.hydrate(data),
                let route = router.find(hydratedData.url)
                else { return }
            
            route.handler.handle(router.toHandledRoute(
                route: route,
                urlWithData: hydratedData.url,
                rawData: hydratedData.rawData,
                extractedParams: router.extractParamsByFoundRoute(route, hydratedData.url) ?? []
            ))
        }
    }
}
