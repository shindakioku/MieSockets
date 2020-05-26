# MieSockets

Simple library to provide easily work with sockets.

-----------

To first you must configure socket

```swift
import MieSockets

let socket = MieSockets.SocketSingleton.shared
socket.instance = MieSockets.Socket(url: "http://localhost:3000").connect()
```
You must use `MieSockets.SocketSingleton` for getting configured socket
##### You can paste this code to SceneDelegate if you are using the swiftui

------------
Now you must add the routes:
```swift
socket.instance.router.add("/") {
  print("Matched!")
}
```
You can implement handler with class 
```swift
public class SomeHandler: RouteHandler {
	public func handle(_ handledRoute: HandledRoute) -> Void {
	  print("Matched")
	}
}

socket.instance.router.add("/", SomeHandler())
```

You can use regex
```swift
socket.instance.router.add("[0-9]") {
   print($0.extractedParams) // [0] = Integer
}

socket.instance.router.add("[0-9]/[a-z]+") {
   print($0.extractedParams) // [0] = Integer, [1] - String
}
```

If you want named params, just add `namedParams` 
```swift
socket.instance.router.add("[0-9]/[a-z]", namedParams: ["id", "name"]) {
	print($0.associatedParams) // ["id"] - Integer, ["name"] - String
}
```
```swift
socket.instance.router.add(MieSockets.Route("messages", SomeHandler(), ["id"]))
```
You can use RouterWrapper for decodable structures 
```swift
public class UserData: Decodable {
  public var id: Int
  public var username: String
}

public class SomeObservable: ObservableObject {
	@MieSockets.RouterWrapperWithDecodable(url: "users", decodeAs: UserData.self) public var user: User?
}
```

--------
You can pass handlers on events (like connected, disconnected, etc)
```swift
class ConnectedHandler: SocketConnectedHandler {
	public func handle(headers: SocketConnectedHandler.Headers) -> Void {
		print("Connected: \(headers)")
	}
}

socket.instance.connectedHandler = ConnectedHandler()
```
By default all handlers are just print data only
```swift
public var connectedHandler: MieSockets.ConnectedHandler = DefaultSocketConnectedHandler()
public var disconnectedHandler: MieSockets.DisconnectedHandler = DefaultSocketDisconnectedHandler()
public var errorHandler: MieSockets.ErrorHandler = DefaultSocketErrorHandler()
public var receivedDataHandler: MieSockets.ReceivedDataHandler = DefaultSocketReceivedDataHandler()
public var reconnectHandler: MieSockets.ReconnectHandler = DefaultSocketReconnectHandler()
public var cancelledHandler: MieSockets.CancelledHandler = DefaultSocketCancelledHandler()
```

-------

#### Now you can ask: how socket can extract the route on receive data?
That's easy!

When server send some data socket must to first extract route and then try to find resolver for the route. By default in the websocket world routers passed in the `event` key
So the library try to extract the route with that name in data.
It's calling `hydrator`

By default it's looks so simple
```swift
public class DefaultReceivedDataHydrator: ReceivedDataHydrator {
	public func hydrate(_ data: Data) -> HydratedData? {
		do {
			if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
				if let event = json["event"] as? MieSockets.RouteUrl {
					return (url: event, rawData: data)
				}
			}
		} catch {
			print("Can\'t hydrate data: \(String(decoding: data, as: UTF8.self))  \(error)")
		}
		
		return nil
	}
}
```
If your server sends the route by `event` key - use default implementation. But you can implement it if you need

```swift
public class MyHydrator: ReceivedDataHydrator {
	public func hydrate(_ data: Data) -> HydratedData? {
		//
	}
}

socket.instance.hydrator = MyHydrator()
```
Thats it!
