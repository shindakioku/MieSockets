import Foundation

/// The object will passing to resolver of the router.
public protocol HandledRoute {
    /// Raw data from server. You can use it how you want
    var rawData: Data { get set }
    
    /// Contains the matched params by regex
    var associatedParams: MieSockets.RouteAssociatedParams { get set }
    
    /// Extracted params without naming bind
    var extractedParams: Array<String> { get set }
    
    /// Defined url in the router
    var originalUrl: String { get set }
    
    /// Url from server. For example /user/1
    var urlWithData: String { get set }
}


public class BaseHandledRoute: HandledRoute {
    public var originalUrl: MieSockets.RouteUrl
    public var urlWithData: String
    public var rawData: Data
    public var associatedParams: MieSockets.RouteAssociatedParams
    public var extractedParams: Array<String>
    
    public init(
        rawData: Data,
        associatedParams: MieSockets.RouteAssociatedParams,
        extractedParams: Array<String>,
        originalUrl: MieSockets.RouteUrl,
        urlWithData: String
    ) {
        self.rawData = rawData
        self.associatedParams = associatedParams
        self.extractedParams = extractedParams
        self.originalUrl = originalUrl
        self.urlWithData = urlWithData
    }
}
