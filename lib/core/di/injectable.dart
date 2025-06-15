import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shop_trendy/core/constants/api_constants.dart';
import 'package:shop_trendy/core/database/database_helper.dart';
import 'injectable.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // Matches the generated function name
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies(String environment) async {
  getIt.registerSingleton<String>(
    ApiConstants.fakeStoreApiUrl,
    instanceName: 'fakeStoreApiUrl',
  );
  getIt.registerSingleton<String>(
    ApiConstants.backendBaseUrl,
    instanceName: 'paymentBackendUrl',
  );

  // ✅ Call top-level generated `init` function, not getIt.init!
  await init(getIt, environment: environment);

  final dbHelper = getIt<DatabaseHelper>();
  await dbHelper.initDb();

  // Optional: wait for all async initializations
  await getIt.allReady();
}
