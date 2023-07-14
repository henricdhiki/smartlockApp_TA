class RegexHelper {
  // fungsi untuk mengecek format email menggunakan regex (regular expression)
  bool validatedEmail(String email) {
    const String pattern = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    final RegExp regex = RegExp(pattern);

    // jika cocok return true
    return regex.hasMatch(email);
  }
}
