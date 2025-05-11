
# Race App Coding Convention



#### 🗂 Folder Structure

```
/model       → Data models  
/service     → Service layer  
/theme       → Theming constants  
/utils       → Utility classes  
/widgets     → Reusable widgets  
/screens     → UI screens + components  
```

---

#### 📄 Model

- Located in `/model`
- Must be **immutable** (when possible)  
- Include:
  - `copyWith()`
  - `==` and `hashCode`
  - `toString()`
- Focused only on **data structure** (no persistence/networking)
- Organize in subfolders:  
  - `/model/users`  
  - `/model/rides`  
  - `/model/ride_preferences`  

---

#### 🛠️ Service

- Located in `/service`  
- Provides static test data (for now)

---

#### 🎨 Theme

- Defined in `/theme/theme.dart`  
Includes:
- `BlaColors` (colors)  
- `BlaTextStyles` (text styles)  
- `BlaSpacings` (spacing)  
- `BlaIcons` (icons)

**All widgets must use theme.dart, not hardcoded styles**

---

#### 🧰 Utils

- Located in `/utils`  
- Static methods for:
  - Date formatting  
  - Screen animations, etc.

---

#### 🧩 App Widgets

- Reusable widgets in `/widgets`  
- Grouped by UI category:
  ```
  actions/         → buttons  
  inputs/          → text fields  
  display/         → cards, lists  
  notifications/   → snackbars, alerts  
  ```
- Naming convention:  
  `bla_button.dart`

---

#### 📱 Screen Widgets

- Located in `/screens/{screen_name}/`  
- Widget subfolder:  
  `/screens/{screen_name}/widgets/`

- Naming example:  
  `ride_pref_history_tile.dart`  
  (for ride preference screen)

---

### 🔗 APP vs SCREEN WIDGETS


This diagram shows how styling and components flow in the app:
- **App Widgets** are built using **App Theme**
- **Screen Widgets** depend on both **App Widgets** and **App Theme**
- **Screens** use **Screen Widgets** and also directly reference the **App Theme** for layout/styling


All components should reference `theme.dart` for styles.

---

### 💬 Comments Guide

#### 1. Explaining a class:

```dart
/// This screen allows users to:
/// - Enter ride preferences and launch a search.
/// - Select previous ride preferences and reuse them.
```

#### 2. Explaining statements:

```dart
departure = null;              // User must select the departure  
departureDate = DateTime.now(); // Defaults to now  
```

#### 3. Clarifying steps:

```dart
// 1 - Notify the listener  
widget.onSearchChanged(newText);

// 2 - Update the cross icon  
setState(() {});
```

---

### 📛 Naming Conventions

| Type       | Format                 |
|------------|------------------------|
| Class      | UpperCamelCase         |
| Method     | lowerCamelCase         |
| Variable   | lowerCamelCase         |
| File Name  | lowercase_with_underscores.dart |

---

#### Getters (example):

```dart
bool get showArrivalPlaceholder => arrival == null;
String get dateLabel => DateTimeUtils.formatDateTime(departureDate);
```

---

### 📏 Typing and Naming Best Practices

- **Always use explicit types**

❌ Bad:
```dart
final dynamic initRidePreferences;
```

✅ Good:
```dart
final RidePref initRidePreferences;
```

---

#### ✅ Consistent Naming Examples

```dart
pageCount            // field  
updatePageCount()    // method  

toSomething()        // consistent with toList()  
```

---

#### ❌ Inconsistent Naming (Avoid)

```dart
renumberPages()        // doesn't match pageCount  
convertToSomething()   // not consistent with toX()  
wrappedAsSomething()   // not consistent with asX()  
```

---
