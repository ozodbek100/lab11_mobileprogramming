Lab 11 – REST API Client with Cubit and Bloc
Part 1 – Setup and first request

Which fields in product.json are a number, a list of strings, a nested object and a list of objects?

Number: price (9.99), also id, rating, stock
List of strings: tags (and images)
Nested object: dimensions (width, height, depth), also meta
List of objects: reviews

What do /products/0 return? Status code 404, with a small JSON body containing a message saying the product was not found. The body is JSON too, which is why the status must be checked before parsing the body as data.

Part 2 – Models

What happens if you write json['price'] as double and the server sends 10? jsonDecode turns 10 into an int, and an int is not a double, so the cast throws a TypeError at run time. The compiler cannot catch it, because json['price'] is dynamic. The fix is (json['price'] as num).toDouble().

Why test fromJson with a saved file instead of a live request? A saved file is fast, works offline, always gives the same data, and cannot fail because of the server, the internet or changed data. A live request makes a test slow and flaky.

Decision on missing tags: a missing tags key becomes an empty list (?? const []), so the UI never has to handle null. A missing brand stays null (String?).

Part 3 – API service

All network code is in ProductApi. Every failure (timeout, no connection, bad status, invalid JSON, unexpected data shape) ends as an ApiException with a readable message.

Part 4 – Cubit

What would happen without the isClosed check if you leave the screen during the 3 s delay? BlocProvider closes the Cubit when the screen is left. When the late response arrives, emit would be called on a closed Cubit and throw a StateError ("Cannot emit new states after calling close"). isClosed skips the emit.

Why does the test use isA<…>() instead of ProductsLoaded([...])? What would you add to compare by value? ProductsLoaded has no ==, so two instances are compared by identity and would never be equal. isA<ProductsLoaded>() checks only the type. To compare by value, override == and hashCode (or use Equatable with props => [products, total]), and do the same for Product.

Part 5 – Bloc

T15 – cancel experiment (what I saw):

I set delayMs: 3000, searched "phone" and then immediately "laptop". The spinner stayed on screen and after the delay only laptop results appeared. The phone results never showed up, because restartable() cancelled the first search when the second one started.
Checkpoint questions

1. Trace one product from the HTTP response to a row on screen.

String (response.body) – lib/data/product_api.dart, in _get
Map<String, dynamic> (result of jsonDecode) – lib/data/product_api.dart
ProductPage and Product objects (fromJson) – lib/models/product_page.dart, lib/models/product.dart
ProductsLoaded state holding List<Product> – lib/cubit/products_cubit.dart
switch in BlocBuilder – lib/screens/products_screen.dart
ProductTile row – lib/widgets/product_tile.dart

2. Which errors can getProducts meet, and which state does the user see?

No internet (SocketException / ClientException) → ProductsError("No internet connection.")
Timeout after 10 s → ProductsError("The server took too long…")
Non-200 status such as 500 → ProductsError("Server answered 500…")
Invalid JSON (FormatException) → ProductsError("…data we could not read.")
Unexpected data shape (TypeError) → ProductsError("…unexpected shape.")

In every case the user sees the error message with a Retry button.

3. When would you choose a Cubit and when a Bloc? A Cubit is enough when the UI just calls methods and state changes simply, like my product list (load, refresh, loadMore). A Bloc fits when user actions are events that need event handling, such as a transformer. My search is the example: events (SearchSubmitted, SearchCleared) plus restartable() to cancel an old search when a new one starts.

4. What does restartable() do, and what would the user see with the default transformer? restartable() cancels the running handler when a new event arrives, and its late emit is ignored, so the newest search always wins. With the default (concurrent) transformer, both searches run. If the old search finishes last, its results overwrite the new ones, so the user could see results for "phone" after searching "laptop".

5. Why must widgets never call http.get or read a Map directly? (two reasons)

Separation of concerns: widgets only draw states. Network code, error handling and parsing live in one place (ProductApi and the models), so a change to the server affects only one file.
Testability and safety: widgets that depend on a Cubit and typed models can be tested with a fake API and no network, and the compiler checks typed models. Reading raw Maps in widgets means untyped keys and crashes at run time.