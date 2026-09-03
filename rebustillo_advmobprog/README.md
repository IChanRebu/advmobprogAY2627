# Rebustillo, Christian Andrew P.
## INF233
## CTADMOBL Advance Mobile Programming
 
A Flutter Project that focuses on advance topics. Covering the web to mobile transactions
 
## Lab Activity Instance
 
## Discussions - Lab 01
setState is used for simple, temporary changes within a single screen, such as updating a counter. Provider is used to manage and share data across multiple screens, such as switching the app between light and dark mode.

# Lab Activity 3: Discussion

The `Cart` model represents the cart response from DummyJSON. It stores the cart ID, user ID, totals, quantity information, and a list of `CartProduct` objects. Each cart product stores its title, price, quantity, totals, discount, and thumbnail. Both models include `fromJson()` and `toJson()` methods so API data can be converted into Dart objects and back into JSON.

`CartService` is responsible for communicating with the API. It requests `/carts/user/{userId}` using the selected user ID from `constant.dart`, checks the HTTP response, parses the JSON, and returns the first cart for that user. It also sends a POST request to `/carts/add` with a user ID, product ID, and quantity. Errors, invalid JSON, and empty cart results are handled by the service and screen.

`CartScreen` receives the future returned by `CartService` and uses `FutureBuilder` to display loading, error, empty, or successful states. When data is available, it shows the cart products, quantities, prices, and totals. A cart item opens the same existing `product_detail_screen.dart`; its cart data is adapted to the existing `Product` object required by that screen, so a second detail screen is not needed.

The model, service, and screen have separate responsibilities. The model describes data, the service handles API requests, and the screen handles presentation and user interaction. This updated pattern keeps the code easier to organize and makes API changes less likely to affect the UI directly.

The cart tab retrieves data by user ID rather than requesting every cart from `/carts`. In this project, there is no authentication system, so user ID `1` is kept as a simple configurable value. The add-to-cart button in the existing product detail flow uses the same selected user ID and calls DummyJSON's `/carts/add` endpoint. DummyJSON is a mock API, so the returned cart should be treated as a demonstration response and not as permanent backend storage.

The cart also demonstrates the updated navigation pattern: the cart is available from the existing bottom-navigation tab and route, while the chat FloatingActionButton is hidden on the cart screen. No chat handler existed in the original project, so the visible action on other screens reports that chat is not configured instead of pretending a chat backend exists.
 