# 🧠 Async Flow with Provider (Step-by-Step Guide)

## 📌 Project Structure Convention
```
DATA
 ├── DTO
 │    └── post_dto.dart
 ├── REPOSITORY
 │    ├── posts_repository.dart
 │    └── http_posts_repository.dart
MODEL
 └── post.dart
UI
 ├── PROVIDER
 │    └── posts_provider.dart
 └── SCREEN
      └── posts_screen.dart
```

---

## ✅ Steps to Handle Futures with Provider

### 1. Provider fetches data from the repository
The provider initiates the fetch call and manages the state using `AsyncValue`.

```dart
class ExampleProvider extends ChangeNotifier {
  AsyncValue<DataType>? dataValue;

  Future<void> fetchData(int id) async {
    // 1️⃣ Set loading state
    dataValue = AsyncValue.loading();
    notifyListeners();

    try {
      // 2️⃣ Fetch the data
      DataType data = await _repository.getData(id);

      // 3️⃣ Set success state
      dataValue = AsyncValue.success(data);
    } catch (error) {
      // 4️⃣ Set error state
      dataValue = AsyncValue.error(error);
    }

    notifyListeners(); // 5️⃣ Notify listeners to update UI
  }
}
```

---

### 2. UI listens to provider and reacts based on the `AsyncValue` state

```dart
final exampleProvider = Provider.of<ExampleProvider>(context);
final dataValue = exampleProvider.dataValue;

if (dataValue == null) {
  return Text('Tap refresh to display data');
}

switch (dataValue.state) {
  case AsyncValueState.loading:
    return CircularProgressIndicator();
  case AsyncValueState.success:
    return DataCard(data: dataValue.data!);
  case AsyncValueState.error:
    return Text('Error: ${dataValue.error}');
}
```

---

## 🔄 AsyncValue Class

```dart
class AsyncValue<T> {
  final T? data;
  final Object? error;
  final AsyncValueState state;

  AsyncValue.loading() : data = null, error = null, state = AsyncValueState.loading;
  AsyncValue.success(this.data) : error = null, state = AsyncValueState.success;
  AsyncValue.error(this.error) : data = null, state = AsyncValueState.error;
}

enum AsyncValueState {
  loading,
  error,
  success
}
```

---

## 📌 Wrap Up Summary

1. ✅ The **provider** handles the fetch call to the **repository**.  
2. 📣 The provider calls `notifyListeners()` whenever the state changes.  
3. 🖼 The **UI** reacts to `AsyncValue` state:  
   - `loading`: show a `CircularProgressIndicator`  
   - `success`: show your data (`DataCard`)  
   - `error`: show an error message  
