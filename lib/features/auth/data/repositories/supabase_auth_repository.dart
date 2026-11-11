import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roamory/core/config/supabase_config.dart';
import 'package:roamory/core/errors/error_mapper.dart';
import 'package:roamory/features/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:roamory/features/auth/data/models/user_profile_model.dart';
import 'package:roamory/features/auth/domain/entities/auth_user.dart';
import 'package:roamory/features/auth/domain/entities/user_profile.dart';
import 'package:roamory/features/auth/domain/repositories/auth_repository.dart';
import 'package:roamory/features/auth/domain/usecases/auth_validators.dart';

/// [AuthRepository] sözleşmesinin Supabase veri kaynağını kullanan uygulaması.
///
/// Tüm ağ, Auth, Postgrest ve Storage hataları [ErrorMapper] üzerinden
/// güvenli [AppException] türlerine dönüştürülerek üst katmana iletilir.
class SupabaseAuthRepository implements AuthRepository {
  /// Veri kaynağı enjeksiyonuyla [SupabaseAuthRepository] oluşturur.
  const SupabaseAuthRepository(this._datasource);

  final SupabaseAuthDatasource _datasource;

  @override
  AuthUser? getCurrentUser() => _datasource.getCurrentUser();

  @override
  Stream<AuthUser?> watchAuthChanges() => _datasource.watchAuthChanges();

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _datasource.signInWithEmail(
        email: email,
        password: password,
      );
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<AuthUser?> signUpWithEmail(SignUpRequest request) async {
    try {
      return await _datasource.signUpWithEmail(
        fullName: request.fullName,
        email: request.email,
        password: request.password,
      );
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _datasource.signInWithGoogle();
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<void> resendVerificationEmail({required String email}) async {
    try {
      await _datasource.resendVerificationEmail(email: email);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<AuthUser> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    try {
      return await _datasource.verifyEmailOtp(email: email, token: token);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<AuthUser?> refreshCurrentUser() async {
    try {
      return await _datasource.refreshCurrentUser();
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _datasource.sendPasswordResetEmail(email: email);
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<UserProfile?> fetchProfile(String userId) async {
    try {
      final model = await _datasource.fetchProfile(userId);
      return model?.toEntity();
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<bool> isUsernameAvailable({
    required String username,
    required String currentUserId,
  }) async {
    try {
      final normalized = AuthValidators.normalizeUsername(username);
      if (!AuthValidators.isValidUsername(normalized)) {
        return false;
      }
      return await _datasource.isUsernameAvailable(
        username: normalized,
        currentUserId: currentUserId,
      );
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<UserProfile> upsertProfile(ProfileUpsertRequest request) async {
    try {
      String? avatarUrl;
      // Fotoğraf baytları sağlandıysa önce Storage upload yapılır, sonra DB güncellenir.
      if (request.avatarBytes != null) {
        avatarUrl = await _datasource.uploadAvatar(
          userId: request.userId,
          bytes: request.avatarBytes!,
          extension: request.avatarFileExtension ?? 'jpg',
        );
      }

      final normalizedUsername = AuthValidators.normalizeUsername(
        request.username,
      );
      final model = UserProfileModel(
        id: request.userId,
        username: normalizedUsername,
        fullName: request.fullName.trim(),
        avatarUrl: avatarUrl,
        bio: request.bio?.trim().isEmpty ?? true ? null : request.bio?.trim(),
        preferredLanguage: request.preferredLanguage,
      );

      final saved = await _datasource.upsertProfile(model);
      return saved.toEntity();
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _datasource.signOut();
    } catch (error, stackTrace) {
      throw ErrorMapper.map(error, stackTrace);
    }
  }
}

/// Auth veri kaynağı sağlayıcısı.
final supabaseAuthDatasourceProvider = Provider<SupabaseAuthDatasource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthDatasource(client);
});

/// Uygulama genelinde kullanılan [AuthRepository] bağımlılık enjeksiyonu.
///
/// Testlerde bu provider `overrideWithValue` ile sahte (mock/fake) repository
/// kullanılarak gerçek Supabase ağına çıkmadan test edilebilir.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final datasource = ref.watch(supabaseAuthDatasourceProvider);
  return SupabaseAuthRepository(datasource);
});
