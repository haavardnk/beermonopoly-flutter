class AuthValidator {
  static String? isNameValid(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vennligst oppgi et brukernavn';
    }
    if (value.length < 4) {
      return 'Brukernavnet må være minst 4 bokstaver langt';
    }
    return null;
  }

  static String? isEmailValid(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vennligst oppgi din e-post';
    }
    String pattern = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Oppgi en gyldig e-post adresse';
    }
    return null;
  }

  static String? isPasswordValid(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vennligst oppgi ditt passord';
    }
    if (value.length < 8) {
      return 'Passordet må være minst 8 bokstaver langt';
    }
    return null;
  }
}
