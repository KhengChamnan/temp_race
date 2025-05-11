enum AsyncValueState {
  loading,
  error,
  success
}

class AsyncValue<T> {
  final T? data;
  final Object? error;
  final AsyncValueState state;

  const AsyncValue.loading() 
      : data = null, 
        error = null, 
        state = AsyncValueState.loading;
        
  const AsyncValue.success(this.data) 
      : error = null, 
        state = AsyncValueState.success;
        
  const AsyncValue.error(this.error) 
      : data = null, 
        state = AsyncValueState.error;
        
  bool get isLoading => state == AsyncValueState.loading;
  bool get isSuccess => state == AsyncValueState.success;
  bool get isError => state == AsyncValueState.error;
} 