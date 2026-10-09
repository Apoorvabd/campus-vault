import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/data/bookmarks_repository.dart';
import 'core/data/posts_repository.dart';
import 'core/data/profile_repository.dart';
import 'core/data/resources_repository.dart';
import 'core/data/subjects_repository.dart';
import 'core/network/api_client.dart';
import 'core/network/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_logo.dart';
import 'features/Auth/bloc/auth_bloc.dart';
import 'features/Auth/bloc/auth_event.dart';
import 'features/Auth/bloc/auth_state.dart';
import 'features/Auth/data/auth_repository.dart';
import 'features/catalog/data/catalog_repository.dart';
import 'features/shell/main_shell.dart';
import 'features/local_vault/bloc/local_vault_cubit.dart';
import 'features/local_vault/data/local_vault_repository.dart';
import 'features/landing/presentation/landingscreen.dart';
import 'features/landing/presentation/welcome_screen.dart';
import 'features/Auth/presentation/loginscreen.dart';
import 'features/profile/bloc/profile_cubit.dart';
import 'features/subjects/presentation/subjects_setup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Built once, shared by the whole app (dependency injection)
  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage);

  runApp(
    MyApp(
      apiClient: apiClient,
      authRepository: AuthRepository(apiClient, tokenStorage),
      catalogRepository: CatalogRepository(apiClient),
      profileRepository: ProfileRepository(apiClient),
      subjectsRepository: SubjectsRepository(apiClient),
      resourcesRepository: ResourcesRepository(apiClient),
      postsRepository: PostsRepository(apiClient),
      bookmarksRepository: BookmarksRepository(apiClient),
      localVaultRepository: LocalVaultRepository(prefs),
    ),
  );
}

// Lets us navigate from outside a screen (the listener below needs this)
final _navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.apiClient,
    required this.authRepository,
    required this.catalogRepository,
    required this.profileRepository,
    required this.subjectsRepository,
    required this.resourcesRepository,
    required this.postsRepository,
    required this.bookmarksRepository,
    required this.localVaultRepository,
  });

  final ApiClient apiClient;
  final AuthRepository authRepository;
  final CatalogRepository catalogRepository;
  final ProfileRepository profileRepository;
  final SubjectsRepository subjectsRepository;
  final ResourcesRepository resourcesRepository;
  final PostsRepository postsRepository;
  final BookmarksRepository bookmarksRepository;
  final LocalVaultRepository localVaultRepository;

  @override
  Widget build(BuildContext context) {
    // Any screen can now do context.read<XRepository>()
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: catalogRepository),
        RepositoryProvider.value(value: profileRepository),
        RepositoryProvider.value(value: subjectsRepository),
        RepositoryProvider.value(value: resourcesRepository),
        RepositoryProvider.value(value: postsRepository),
        RepositoryProvider.value(value: bookmarksRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          // create the Bloc and immediately fire the first event
          BlocProvider(
            create: (_) =>
                AuthBloc(authRepository, apiClient)..add(const AuthStarted()),
          ),
          // The logged-in user's profile, shared by Home / Profile / Create Post
          BlocProvider(create: (_) => ProfileCubit(profileRepository)),
          // Files saved on this device, shared by Saved + Storage screens
          BlocProvider(
            create: (_) => LocalVaultCubit(localVaultRepository)..load(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Semester Forge',
          theme: AppTheme.light,
          navigatorKey: _navigatorKey,
          home: const _SplashScreen(),
          // The listener sits above every screen and reacts to auth changes
          // Default look of the system navigation bar for every screen. A
          // screen can override it with its own AnnotatedRegion (the welcome
          // and landing screens do, to go purple); once that screen is gone
          // this default applies again, so the colour never sticks.
          builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                final nav = _navigatorKey.currentState;
                if (nav == null) return;

                if (state is Authenticated) {
                  context.read<ProfileCubit>().load();
                  nav.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainShell()),
                    (route) => false,
                  );
                  // First time only: right after sign-up, show the subjects form
                  // on top of Home (leaving it just reveals Home)
                  final authBloc = context.read<AuthBloc>();
                  if (authBloc.justRegistered) {
                    authBloc.justRegistered = false;
                    nav.push(
                      MaterialPageRoute(
                        builder: (_) => const SubjectsSetupScreen(),
                      ),
                    );
                  }
                } else if (state is Unauthenticated) {
                  // The landing screen is about to show: start waking a
                  // sleeping backend now, so login / register don't hit a
                  // cold server
                  apiClient.wakeServer();
                  context.read<ProfileCubit>().clear();
                  // Main landing is the welcome screen. "Get started" opens the
                  // older landing screen (which leads on to login); "Sign in"
                  // goes straight to login.
                  nav.pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => WelcomeScreen(
                        onGetStarted: () => nav.push(
                          MaterialPageRoute(
                            builder: (_) => const LandingScreen(),
                          ),
                        ),
                        onSignIn: () => nav.push(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                      ),
                    ),
                    (route) => false,
                  );
                }
              },
              child: child!,
            ),
          ),
        ),
      ),
    );
  }
}

// Shown for a moment while AuthStarted checks the saved login
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [AppLogo.full(height: 120)],
        ),
      ),
    );
  }
}
