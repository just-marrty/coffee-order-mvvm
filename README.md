# CoffeeOrder

A SwiftUI application for managing coffee orders with full CRUD operations, integrating with a custom Python/Django backend API.

> **Note**: This application uses a custom backend server built with Python/Django framework with a RESTful API for order management.

## Features

- Browse a list of coffee orders with detailed information (customer name, coffee type, size, price)
- Add new coffee orders with coffee selection and size customization
- Edit existing orders with pre-populated data
- Delete orders directly from detail view
- Real-time price calculation based on coffee size
- Loading states and error handling with retry functionality
- Clean and modern UI with SwiftUI
- Form validation for order creation and editing
- ISO 8601 date formatting for order timestamps
- Bottom toolbar navigation with "Add Order" functionality
- Full CRUD operations (Create, Read, Update, Delete)
- Environment-based configuration (Development, Test, Production)

## Architecture

The project demonstrates modern SwiftUI patterns and MVVM architecture with dependency injection:

### Model

**CoffeeSize** - Enum representing coffee sizes with pricing
- Three size options: Small (50.00), Medium (75.00), Large (100.00)
- Conforms to `Codable` and `CaseIterable` for JSON parsing and UI iteration
- Computed property `price` returns the appropriate price for each size
- Raw values for display purposes

**CoffeeName** - Enum representing coffee types
- Four coffee varieties: Espresso, Latté, Cappuccino, Flat White
- Conforms to `Codable` and `CaseIterable`
- Uses raw values for API communication and display

**Order** - Main model representing a coffee order
- Properties: `id` (optional Int), `name`, `coffeeName`, `total`, `size`, `createdAt`
- Conforms to `Codable`, `Identifiable`, and `Hashable`
- Custom `Decodable` implementation to handle API's string-based total conversion
- Optional `id` to support creation of new orders (nil until persisted)
- Maps JSON response with snake_case to camelCase conversion
- ISO 8601 timestamp for order creation time

### Service

**FetchService** - Handles all HTTP operations with the backend API
- Uses URLSession with async/await for network requests
- Custom error handling with `NetworkError` enum:
  - `invalidURL` - Malformed URL construction
  - `badResponse` - Invalid HTTP response
  - `httpError(statusCode:)` - HTTP status code errors
  - `decodingFail` - JSON decoding failures
  - `encodingFail` - JSON encoding failures
  - `missingID` - Missing order ID for update/delete operations
- **GET** - Fetches all orders from `/api/orders/`
- **POST** - Creates new order at `/api/orders/`
- **PUT** - Updates existing order at `/api/orders/{id}`
- **DELETE** - Deletes order at `/api/orders/{id}`
- Uses `JSONDecoder` with `convertFromSnakeCase` strategy
- Uses `JSONEncoder` with `convertToSnakeCase` strategy
- HTTP status code validation (200-299 range)
- Content-Type header management for JSON
- Dependency injection via constructor (receives baseURL)
- `@MainActor` for thread-safe operations

### ViewModel

**OrderViewModel** - Manages application state and business logic
- Uses `@Observable` macro for reactive UI updates
- `@MainActor` for thread-safe UI updates
- Dependency injection via initializer (receives `FetchService`)
- **State Properties**:
  - `orders` - Array of fetched orders
  - `isLoading` - Loading state indicator
  - `errorMessage` - Optional error message for display
  - `name`, `coffeeName`, `coffeeSize` - Form input bindings
  - `price` - Computed property based on selected size
  - `validationError` - Form validation error message
  - `editingOrderId` - Tracks order being edited
- **Operations**:
  - `loadOrders()` - Fetches orders with error handling
  - `submitOrder()` - Creates new order via POST
  - `startEditingOrder()` - Prepares form for editing
  - `editOrder()` - Updates order via PUT
  - `deleteOrder()` - Removes order via DELETE
  - `validate()` - Validates form input (name cannot be empty)
  - `resetOrder()` - Clears form to default values
- Separates domain model from presentation concerns
- Automatic order list updates after CRUD operations

### Views

**ContentView** - Main container with order list and navigation
- Uses `@Environment` to access shared `OrderViewModel`
- `NavigationStack` for hierarchical navigation
- Three states: Loading (ProgressView), Error (with retry button), Content (order list)
- Empty state handling with "No orders available" message
- List view with `OrderCellView` for each order
- Navigation to `OrderDetailView` on row tap
- Bottom toolbar with "Add Order" button
- Sheet presentation for `AddOrderView`
- Automatic order loading on appear with `.task` modifier
- Toolbar background visibility for polished appearance
- Error UI with icon, message, and retry functionality

**AddOrderView** - Form for creating new orders
- Form-based layout with validation
- Text field for customer name with accessibility identifier
- Inline pickers for coffee type and size selection
- Real-time price display based on size
- Validation error display in red
- "Place order" button triggers validation and submission
- Reset button (clockwise arrow icon) clears form
- Uses `@Bindable` for two-way binding with ViewModel
- Dismisses automatically on successful submission
- Autocorrection disabled for name input

**EditOrderView** - Form for updating existing orders
- Nearly identical to `AddOrderView` but for editing
- Pre-populates form with existing order data
- "Update order" button instead of "Place order"
- Uses `startEditingOrder()` to initialize form state
- Receives order as parameter for context
- Reset button allows reverting changes

**OrderCellView** - List row component displaying order summary
- HStack layout with order info and price
- Displays customer name (bold), coffee type and size
- Formatted creation timestamp with reduced opacity
- Price displayed with currency formatter
- Vertical spacing optimization for list density
- Accessibility identifiers for UI testing
- Reusable component for consistent list appearance

**OrderDetailView** - Detailed view for individual order
- Form-based layout displaying all order properties
- Shows name, coffee type, size, formatted timestamp, and price
- Edit button triggers `EditOrderView` in sheet
- Delete button with red styling immediately removes order and dismisses view
- HStack with centered buttons for actions
- Uses `@Environment(\.dismiss)` for navigation dismissal
- Navigation title "Order detail" with inline display mode
- Error handling for delete operation

### Utilities

**AppEnvironment** - Environment configuration management
- Enum with three environments: `dev`, `test`, `prod`
- Each environment provides a `baseURL` for backend API
- Currently all point to local development server (http://127.0.0.1:8000/)
- Comments indicate production URLs would be different
- Supports custom backend server built with Python/Django

**Endpoints** - API endpoint path management
- Enum with associated values for dynamic paths
- `getOrders` - "/api/orders/" for fetching all orders
- `postOrder` - "/api/orders/" for creating orders
- `putOrder(Int)` - "/api/orders/{id}" for updating
- `deleteOrder(Int)` - "/api/orders/{id}" for deleting
- Centralizes API path definitions
- Comments indicate paths depend on backend requirements

**Configuration** - Configuration loader with environment detection
- Lazy property reads "ENV" from ProcessInfo environment variables
- Maps "TEST" → `.test`, "PROD" → `.prod`, default → `.dev`
- Provides environment configuration to app initialization

### Extensions

**NumberFormatter+Extensions** - Currency formatting
- Static computed property `currency` returns configured NumberFormatter
- Sets `numberStyle` to `.currency` for proper formatting
- Used throughout app for displaying prices

**String+Extensions** - Date/time formatting
- `formattedDateTime()` method converts ISO 8601 strings to readable format
- Handles ISO 8601 with fractional seconds
- Handles ISO 8601 without fractional seconds
- Falls back to original string if parsing fails
- Returns abbreviated date with shortened time format

## Dependency Injection

The project uses constructor-based dependency injection:

- `FetchService` receives `baseURL` through its initializer
- `OrderViewModel` receives `FetchService` as a dependency through its initializer
- `Configuration` is created at app launch to determine environment
- `FetchService` is instantiated with appropriate base URL from configuration
- `OrderViewModel` is injected as environment object throughout the view hierarchy
- This allows for easy testing and swapping implementations
- Promotes loose coupling and testability
- Dependencies are resolved at app entry point (`CoffeeOrderApp`)

## State Management

- `@State` for local view state (sheet presentation, ViewModel instance)
- `@Environment` for accessing shared `OrderViewModel` across views
- `@Observable` macro for reactive ViewModel updates
- `@Bindable` for two-way binding in forms
- `@Environment(\.dismiss)` for programmatic view dismissal
- State-based loading, error, and content display
- Reactive form validation with computed properties
- CRUD operations automatically update the orders array

## Technologies

- **SwiftUI** - Modern declarative UI framework
- **Async/Await** - Asynchronous data fetching from API using modern Swift concurrency
- **REST API** - Integration with custom Python/Django backend
- **Python/Django** - Custom backend server with RESTful API
- **NavigationStack** - Programmatic navigation with type-safe routing
- **JSON Encoding/Decoding** - Custom Codable implementation with snake_case conversion
- **Observable** - Using @Observable macro for reactive UI updates
- **Dependency Injection** - Constructor-based DI for testability and flexibility
- **URLSession** - Modern async/await API for network requests
- **Form** - SwiftUI form components for data entry
- **Sheet** - Modal presentation for add/edit views
- **Environment** - SwiftUI environment for dependency sharing
- **ISO 8601** - Standard date/time format for API communication
- **MVVM** - Model-View-ViewModel architectural pattern

## Backend API

This application requires a custom Python/Django backend server with the following REST API endpoints:

- **GET** `/api/orders/` - Returns array of all orders
- **POST** `/api/orders/` - Creates new order, returns created order with ID
- **PUT** `/api/orders/{id}` - Updates order by ID, returns updated order
- **DELETE** `/api/orders/{id}` - Deletes order by ID

### API Data Format

Orders are exchanged in JSON format with snake_case keys:

{
  "id": 1,
  "name": "John Doe",
  "coffee_name": "Espresso",
  "total": "50.00",
  "size": "Small",
  "created_at": "2025-12-16T10:30:00Z"
}**Note**: The `total` field is sent as a string from the backend and converted to Double in the app.

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Internet connection for API access
- Running Python/Django backend server
