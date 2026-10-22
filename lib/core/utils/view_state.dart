/// Status of a ViewModel's async work. The data and the error message live in
/// their own fields on the ViewModel; this only says where the work stands.
enum ViewState { idle, loading, success, error }
