import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roamory/app/l10n/app_localizations.dart';
import 'package:roamory/app/theme/app_colors.dart';
import 'package:roamory/app/theme/app_theme.dart';
import 'package:roamory/core/errors/app_exception.dart';
import 'package:roamory/shared/widgets/app_buttons.dart';
import 'package:roamory/shared/widgets/app_confirm_sheet.dart';
import 'package:roamory/shared/widgets/app_state_views.dart';
import 'package:roamory/shared/widgets/app_text_field.dart';

/// Ortak widget testleri için Türkçe lokalizasyon ve tema sarmalayıcısı.
Widget _wrapWithApp(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    locale: const Locale('tr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: theme ?? AppTheme.light(useGoogleFonts: false),
    home: Scaffold(body: child),
  );
}

void main() {
  test(
    // Amaç: design.md otoriter renk tokenlarının AppTheme üzerinden doğru sunulması.
    'AppTheme açık ve koyu tema renk tokenlarını doğru sağlar',
    () {
      final lightTheme = AppTheme.light(useGoogleFonts: false);
      final darkTheme = AppTheme.dark(useGoogleFonts: false);

      final lightColors = lightTheme.extension<RoamoryColors>()!;
      final darkColors = darkTheme.extension<RoamoryColors>()!;

      expect(lightColors.primary, const Color(0xFF176B5B));
      expect(lightColors.background, const Color(0xFFF7F8F5));
      expect(lightColors.accent, const Color(0xFFD7A65C));
      expect(darkColors.background, const Color(0xFF0F1715));
    },
  );

  testWidgets(
    // Amaç: PrimaryButton yükleniyor durumunda tıklamayı engellemelidir.
    'PrimaryButton isLoading=true iken onPressed tetiklenmez',
    (tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        _wrapWithApp(
          PrimaryButton(
            label: 'Kaydet',
            isLoading: true,
            onPressed: () => tapCount++,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(tapCount, 0);
    },
  );

  testWidgets(
    // Amaç: ErrorState ağ hatasında yerelleştirilmiş başlık ve Tekrar Dene aksiyonu sunmalıdır.
    'ErrorState ağ hatasını gösterir ve Tekrar Dene butonunu çalıştırır',
    (tester) async {
      var retried = false;

      await tester.pumpWidget(
        _wrapWithApp(
          ErrorState(
            exception: const NetworkAppException(),
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Bağlantı Hatası'), findsOneWidget);
      await tester.tap(find.text('Tekrar Dene'));
      await tester.pump();
      expect(retried, isTrue);
    },
  );

  testWidgets(
    // Amaç: EmptyState ve LoadingSkeleton hata vermeden render edilmelidir.
    'EmptyState ve LoadingSkeleton sorunsuz çizilir',
    (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const EmptyState(
            title: 'Seyahat yok',
            message: 'İlk rotanı oluştur.',
          ),
        ),
      );
      expect(find.text('Seyahat yok'), findsOneWidget);

      await tester.pumpWidget(
        _wrapWithApp(const LoadingSkeleton(itemCount: 2)),
      );
      expect(find.byType(LoadingSkeleton), findsOneWidget);
    },
  );

  testWidgets(
    // Amaç: AppTextField hata metnini ve etiketi göstermelidir.
    'AppTextField etiket ve doğrulama hatasını gösterir',
    (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const Padding(
            padding: EdgeInsets.all(16),
            child: AppTextField(
              label: 'Seyahat Başlığı',
              errorText: 'Bu alan zorunludur',
            ),
          ),
        ),
      );

      expect(find.text('Seyahat Başlığı'), findsOneWidget);
      expect(find.text('Bu alan zorunludur'), findsOneWidget);
    },
  );

  testWidgets(
    // Amaç: showAppConfirmSheet onaylandığında true döndürmelidir.
    'showAppConfirmSheet onaylandığında true döner',
    (tester) async {
      bool? dialogResult;

      await tester.pumpWidget(
        _wrapWithApp(
          Builder(
            builder: (context) => PrimaryButton(
              label: 'Aç',
              onPressed: () async {
                dialogResult = await showAppConfirmSheet(
                  context: context,
                  title: 'Silme Onayı',
                  message: 'Kayıt kalıcı olarak silinecek.',
                  confirmLabel: 'Sil',
                  isDestructive: true,
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Aç'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sil'));
      await tester.pumpAndSettle();

      expect(dialogResult, isTrue);
    },
  );
}
