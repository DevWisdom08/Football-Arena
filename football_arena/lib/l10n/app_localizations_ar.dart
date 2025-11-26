// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'ساحة كرة القدم';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'التسجيل';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get country => 'الدولة';

  @override
  String get continueAsGuest => 'المتابعة كضيف';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get home => 'الرئيسية';

  @override
  String get leaderboard => 'لوحة المتصدرين';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get store => 'المتجر';

  @override
  String get settings => 'الإعدادات';

  @override
  String get friends => 'الأصدقاء';

  @override
  String get history => 'السجل';

  @override
  String get soloMode => 'الوضع الفردي';

  @override
  String get challenge1v1 => 'تحدي 1 ضد 1';

  @override
  String get teamMatch => 'مباراة الفريق';

  @override
  String get dailyQuiz => 'اختبار يومي';

  @override
  String get play => 'العب';

  @override
  String get roomName => 'اسم الغرفة';

  @override
  String get roomNameOptional => 'اسم الغرفة (اختياري)';

  @override
  String get roomNameHint => 'أدخل اسماً لغرفتك';

  @override
  String get numberOfRounds => 'عدد الجولات';

  @override
  String get roundsHint => 'عدد الأسئلة (5-30)';

  @override
  String get roundsMin => 'الحد الأدنى 5 جولات';

  @override
  String get roundsMax => 'الحد الأقصى 30 جولة';

  @override
  String get roundsInvalid => 'يرجى إدخال رقم صحيح بين 5 و 30';

  @override
  String get shuffleTeams => 'خلط الفرق';

  @override
  String get teamsShuffled => 'تم خلط الفرق!';

  @override
  String get shufflingTeams => 'جاري خلط الفرق...';

  @override
  String get onlyHostCanShuffle => 'فقط المضيف يمكنه خلط الفرق';

  @override
  String get cannotShuffleAfterStart => 'لا يمكن خلط الفرق بعد بدء اللعبة';

  @override
  String get needTwoPlayersToShuffle => 'يحتاج إلى لاعبين على الأقل لخلط الفرق';

  @override
  String get protectYourStreak => 'احمِ سلسلتك';

  @override
  String currentStreak(int streak) {
    return 'السلسلة الحالية: $streak أيام';
  }

  @override
  String get streakProtectionDescription =>
      'سلسلتك على وشك الانقطاع! احمها باستخدام العملات أو عضوية VIP.';

  @override
  String get protectWithVip => 'احمِ بـ VIP (مجاني)';

  @override
  String protectWithCoins(int coins) {
    return 'احمِ بـ $coins عملة';
  }

  @override
  String get notEnoughCoinsForProtection => 'تحتاج إلى 100 عملة لحماية سلسلتك';

  @override
  String get noThanks => 'لا شكراً';

  @override
  String streakProtected(int streak) {
    return 'تم حماية السلسلة! $streak أيام';
  }

  @override
  String get streakBroken => 'انقطعت السلسلة';

  @override
  String dayStreak(int count) {
    return 'سلسلة $count يوم';
  }

  @override
  String get streakProtectedMessage => 'تم حماية سلسلتك!';

  @override
  String get streakBrokenMessage => 'انقطعت سلسلتك';

  @override
  String get keepPlayingDaily => 'استمر في اللعب يومياً!';

  @override
  String get protectStreakNow => 'احمِ سلسلتك الآن!';

  @override
  String get protectStreakDescription =>
      'لا تفقد تقدمك! استخدم العملات أو VIP لحماية سلسلتك.';

  @override
  String get protectMyStreak => 'احمِ سلسلتي';

  @override
  String get pleaseLoginToProtectStreak => 'يرجى تسجيل الدخول لحماية سلسلتك';

  @override
  String get streakProtectedSuccessfully => 'تم حماية السلسلة بنجاح!';

  @override
  String get startQuiz => 'بدء الاختبار';

  @override
  String get startGame => 'بدء اللعبة';

  @override
  String get playAgain => 'العب مرة أخرى';

  @override
  String get backHome => 'العودة للرئيسية';

  @override
  String get shareScore => 'مشاركة النتيجة';

  @override
  String get difficulty => 'الصعوبة';

  @override
  String get category => 'الفئة';

  @override
  String get selectDifficulty => 'اختر الصعوبة';

  @override
  String get selectCategory => 'اختر الفئة (اختياري)';

  @override
  String get easy => 'سهل';

  @override
  String get medium => 'متوسط';

  @override
  String get hard => 'صعب';

  @override
  String get general => 'عام';

  @override
  String get worldCup => 'كأس العالم';

  @override
  String get clubs => 'الأندية';

  @override
  String get players => 'اللاعبون';

  @override
  String get difficultyDescription => 'اختر مستوى التحدي';

  @override
  String get categoryDescription =>
      'اختر موضوعاً محدداً أو اتركه فارغاً للأسئلة المختلطة';

  @override
  String get anyDifficulty => 'أي صعوبة';

  @override
  String get anyCategory => 'أي فئة';

  @override
  String get welcomeBack => 'مرحباً بعودتك';

  @override
  String get level => 'المستوى';

  @override
  String get xp => 'النقاط';

  @override
  String coins(int count) {
    return '$count عملة';
  }

  @override
  String get streak => 'السلسلة';

  @override
  String get question => 'السؤال';

  @override
  String questionNumber(int current, int total) {
    return 'السؤال $current من $total';
  }

  @override
  String timeRemaining(int seconds) {
    return '$secondsث';
  }

  @override
  String get correct => 'صحيح';

  @override
  String get wrong => 'خطأ';

  @override
  String get trueText => 'صحيح';

  @override
  String get falseText => 'خطأ';

  @override
  String get selectAnswer => 'اختر الإجابة';

  @override
  String get timeUp => 'انتهى الوقت!';

  @override
  String get nextQuestion => 'السؤال التالي';

  @override
  String get skip => 'تخطي';

  @override
  String get revealWrong => 'كشف خاطئ';

  @override
  String get extraTime => 'وقت إضافي';

  @override
  String get results => 'النتائج';

  @override
  String get score => 'النتيجة';

  @override
  String get correctAnswers => 'الإجابات الصحيحة';

  @override
  String get incorrectAnswers => 'الإجابات الخاطئة';

  @override
  String get accuracy => 'الدقة';

  @override
  String get xpGained => 'النقاط المكتسبة';

  @override
  String get coinsEarned => 'العملات المكتسبة';

  @override
  String get timeBonus => 'مكافأة الوقت';

  @override
  String get totalScore => 'النتيجة الإجمالية';

  @override
  String get wellDone => 'أحسنت!';

  @override
  String get greatJob => 'عمل رائع!';

  @override
  String get excellent => 'ممتاز!';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get matchmaking => 'البحث عن خصم';

  @override
  String get findingOpponent => 'جاري البحث عن خصم...';

  @override
  String get opponentFound => 'تم العثور على خصم!';

  @override
  String get waitingForOpponent => 'في انتظار الخصم...';

  @override
  String get opponent => 'الخصم';

  @override
  String get you => 'أنت';

  @override
  String get attack => 'هجوم';

  @override
  String get counterAttack => 'هجوم مضاد';

  @override
  String get neutralPlay => 'لعب محايد';

  @override
  String get addFriend => 'إضافة صديق';

  @override
  String get shareResult => 'مشاركة النتيجة';

  @override
  String get region => 'المنطقة';

  @override
  String get selectRegion => 'اختر المنطقة';

  @override
  String get teamLobby => 'غرفة الفريق';

  @override
  String get createTeam => 'إنشاء فريق';

  @override
  String get joinTeam => 'الانضمام لفريق';

  @override
  String get teamA => 'الفريق أ';

  @override
  String get teamB => 'الفريق ب';

  @override
  String get ready => 'جاهز';

  @override
  String get notReady => 'غير جاهز';

  @override
  String get waitingForPlayers => 'في انتظار اللاعبين...';

  @override
  String get teamFull => 'الفريق ممتلئ';

  @override
  String get mvp => 'أفضل لاعب';

  @override
  String get dailyQuizAvailable => 'الاختبار اليومي متاح';

  @override
  String get dailyQuizCompleted => 'تم إكمال الاختبار اليومي';

  @override
  String quizStartsIn(String time) {
    return 'يبدأ الاختبار في $time';
  }

  @override
  String get specialRewards => 'مكافآت خاصة';

  @override
  String get bonusCoins => 'عملات إضافية';

  @override
  String get bonusXP => 'نقاط إضافية';

  @override
  String get global => 'العالمي';

  @override
  String get monthly => 'الشهري';

  @override
  String get allTime => 'كل الوقت';

  @override
  String get daily => 'اليومي';

  @override
  String get weekly => 'الأسبوعي';

  @override
  String get rank => 'الترتيب';

  @override
  String get noDataAvailable => 'لا توجد بيانات متاحة';

  @override
  String get noFriendsYet => 'لا توجد أصدقاء بعد. أضف أصدقاء لرؤية ترتيبهم!';

  @override
  String get usingOfflineData => 'استخدام البيانات غير المتصلة. اسحب للتحديث.';

  @override
  String get friendsList => 'قائمة الأصدقاء';

  @override
  String get friendRequests => 'طلبات الصداقة';

  @override
  String get pendingRequests => 'الطلبات المعلقة';

  @override
  String get sentRequests => 'الطلبات المرسلة';

  @override
  String get accept => 'قبول';

  @override
  String get reject => 'رفض';

  @override
  String get remove => 'إزالة';

  @override
  String get searchFriends => 'البحث عن أصدقاء';

  @override
  String get noFriends => 'لا توجد أصدقاء بعد';

  @override
  String get noRequests => 'لا توجد طلبات معلقة';

  @override
  String get addFriendsToChallenge => 'أضف أصدقاء لتحديهم!';

  @override
  String get noPendingRequests => 'لا توجد طلبات معلقة';

  @override
  String get removeFriend => 'إزالة صديق';

  @override
  String get removeFriendConfirmation =>
      'هل أنت متأكد أنك تريد إزالة هذا الصديق؟';

  @override
  String get friendRemoved => 'تمت إزالة الصديق بنجاح';

  @override
  String get enterUsernameOrEmail => 'أدخل اسم المستخدم أو البريد الإلكتروني';

  @override
  String get sendRequest => 'إرسال طلب';

  @override
  String get friendRequestSent => 'تم إرسال طلب الصداقة بنجاح';

  @override
  String get userNotFound => 'المستخدم غير موجود';

  @override
  String get friendRequestAccepted => 'تم قبول طلب الصداقة';

  @override
  String get friendRequestRejected => 'تم رفض طلب الصداقة';

  @override
  String get matchHistory => 'سجل المباريات';

  @override
  String get recentMatches => 'المباريات الأخيرة';

  @override
  String get noMatches => 'لم يتم لعب أي مباريات بعد';

  @override
  String get matchType => 'نوع المباراة';

  @override
  String get result => 'النتيجة';

  @override
  String get win => 'فوز';

  @override
  String get lose => 'خسارة';

  @override
  String get draw => 'تعادل';

  @override
  String get playedAt => 'تم اللعب في';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get changeAvatar => 'تغيير الصورة';

  @override
  String get totalGames => 'إجمالي المباريات';

  @override
  String get soloGames => 'مباريات فردية';

  @override
  String get challengeGames => 'مباريات 1 ضد 1';

  @override
  String get teamGames => 'مباريات الفريق';

  @override
  String get winRate => 'معدل الفوز';

  @override
  String get accuracyRate => 'معدل الدقة';

  @override
  String get achievements => 'الإنجازات';

  @override
  String get badges => 'شارات';

  @override
  String get vipStatus => 'حالة العضوية المميزة';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get expiresOn => 'ينتهي في';

  @override
  String get coinPacks => 'باقات العملات';

  @override
  String get vipMembership => 'العضوية المميزة';

  @override
  String get boosts => 'تعزيزات';

  @override
  String get smallPack => 'باقة صغيرة';

  @override
  String get mediumPack => 'باقة متوسطة';

  @override
  String get largePack => 'باقة كبيرة';

  @override
  String get vipMonthly => 'عضوية شهرية';

  @override
  String get vipYearly => 'عضوية سنوية';

  @override
  String get vipLifetime => 'عضوية مدى الحياة';

  @override
  String get noAds => 'بدون إعلانات + 50% مكافآت إضافية';

  @override
  String get purchase => 'شراء';

  @override
  String get purchased => 'تم الشراء';

  @override
  String get insufficientCoins => 'عملات غير كافية';

  @override
  String get purchaseSuccessful => 'تم الشراء بنجاح!';

  @override
  String get purchaseFailed => 'فشل الشراء';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get sound => 'الصوت';

  @override
  String get vibration => 'الاهتزاز';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get clearCache => 'مسح الذاكرة المؤقتة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get about => 'حول';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get version => 'الإصدار';

  @override
  String get cacheCleared => 'تم مسح الذاكرة المؤقتة بنجاح';

  @override
  String get onboarding => 'البدء';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get welcome => 'مرحباً';

  @override
  String get welcomeDescription =>
      'اختبر معرفتك بكرة القدم وتنافس مع اللاعبين حول العالم';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجح';

  @override
  String get warning => 'تحذير';

  @override
  String get info => 'معلومات';

  @override
  String get ok => 'موافق';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get close => 'إغلاق';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get refresh => 'تحديث';

  @override
  String get networkError => 'خطأ في الشبكة. يرجى التحقق من اتصالك.';

  @override
  String get connectionTimeout =>
      'انتهت مهلة الاتصال. يرجى التحقق من اتصالك بالإنترنت.';

  @override
  String get serverError => 'خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get unknownError => 'حدث خطأ غير معروف';

  @override
  String get pleaseLogin => 'يرجى تسجيل الدخول للمتابعة';

  @override
  String get pleaseLoginToPurchase => 'يرجى تسجيل الدخول لإجراء عمليات الشراء';

  @override
  String get invalidCredentials => 'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get emailAlreadyExists => 'البريد الإلكتروني موجود بالفعل';

  @override
  String get weakPassword => 'كلمة المرور ضعيفة جداً';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get emailInvalid => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get upgradeGuestAccount => 'ترقية حساب الضيف';

  @override
  String get upgradeGuestDescription =>
      'حول حساب الضيف الخاص بك إلى حساب كامل لحفظ تقدمك والوصول إلى جميع الميزات.';

  @override
  String get upgradeAccount => 'ترقية الحساب';

  @override
  String get accountUpgradedSuccessfully => 'تمت ترقية الحساب بنجاح!';

  @override
  String get optional => 'اختياري';

  @override
  String get confirmPasswordRequired => 'يرجى تأكيد كلمة المرور';

  @override
  String get bonus20Percent => 'مكافأة 20%';

  @override
  String get bestValue => 'أفضل قيمة';

  @override
  String get skipQuestion => 'تخطي السؤال';

  @override
  String get revealWrongOption => 'كشف خاطئ';

  @override
  String get extraTimeBoost => 'وقت إضافي';

  @override
  String get plus5Seconds => '+5 ثوانٍ لكل سؤال';

  @override
  String get skipAnyQuestion => 'تخطي أي سؤال';

  @override
  String get revealOneWrong => 'كشف خيار خاطئ واحد';

  @override
  String get gameModes => 'أوضاع اللعبة';

  @override
  String get xpProgress => 'تقدم النقاط';

  @override
  String get yourStats => 'إحصائياتك';

  @override
  String get games => 'المباريات';

  @override
  String get visitStore => 'زيارة المتجر';

  @override
  String get boostsAndItems => 'التعزيزات والعناصر';

  @override
  String get open => 'فتح';

  @override
  String get playNow => 'العب الآن';

  @override
  String get quickQuiz => 'اختبار سريع';

  @override
  String get duelMode => 'وضع المبارزة';

  @override
  String get upTo10Players => 'حتى 10 لاعبين';

  @override
  String get twoXRewards => 'مكافآت مضاعفة';

  @override
  String get twoXXP => 'نقاط مضاعفة';

  @override
  String get bonusCoinsExclamation => 'عملات إضافية!';

  @override
  String get or => 'أو';

  @override
  String get apple => 'آبل';

  @override
  String get google => 'جوجل';

  @override
  String get pleaseEnterEmail => 'يرجى إدخال بريدك الإلكتروني';

  @override
  String get pleaseEnterValidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get pleaseEnterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get passwordMinLength => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String levelFormat(int level, String country) {
    return 'المستوى $level - $country';
  }

  @override
  String get empty => 'فارغ';

  @override
  String get noQuestions =>
      'لا توجد أسئلة متاحة. يرجى المحاولة مرة أخرى لاحقاً.';

  @override
  String get quizCompleted => 'تم إكمال الاختبار';

  @override
  String get matchEnded => 'انتهت المباراة';
}
