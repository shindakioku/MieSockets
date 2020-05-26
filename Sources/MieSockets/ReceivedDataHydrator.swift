import Foundation

public typealias HydratedData = (url: MieSockets.RouteUrl, rawData: Data)

/// Hydrator must be call after received new data. It must take url from response.
public protocol ReceivedDataHydrator {
    func hydrate(_ data: Data) -> HydratedData?
}

/// By default it will take route url like event
public class DefaultReceivedDataHydrator: ReceivedDataHydrator {
    public func hydrate(_ data: Data) -> HydratedData? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let event = json["event"] as? MieSockets.RouteUrl {
                    return (url: event, rawData: data)
                }
            }
        } catch {
            print("Can\'t hydrate data: \(String(decoding: data, as: UTF8.self)) \(error)")
        }
        
        return nil
    }
}
