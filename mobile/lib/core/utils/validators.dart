/// Quick client-side email check. The backend (Zod) has the final say.
bool isValidEmail(String email) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
