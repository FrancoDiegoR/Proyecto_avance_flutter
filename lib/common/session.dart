import '../iam/domain/account.dart';

/// Sesion en memoria (como SessionService de la app Android, sin guardar en el telefono).
class Session {
  static Account? currentAccount;

  static bool get isLoggedIn => currentAccount != null;

  static int get accountId => currentAccount?.id ?? 1;

  static void clear() => currentAccount = null;
}
