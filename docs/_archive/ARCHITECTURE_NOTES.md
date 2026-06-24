# DEPRECATED — do not use

Documento arquivado para histórico.
Fonte oficial atual: docs/README.md.

# Architecture Notes (Mock Data + Clean Architecture)

## Current Conventions Observed
- **Feature structure:** `lib/features/<feature>/{data,domain,presentation}` (e.g., `lib/features/map`, `lib/features/auth`, `lib/features/location`).
- **State management (current implementation):** `flutter_bloc` with `Bloc` or `Cubit` in `presentation` (e.g., `AuthBloc` in `lib/features/auth/presentation/bloc/auth_bloc.dart`, `DeviceLocationCubit` in `lib/features/location/presentation/cubit/device_location_cubit.dart`).
- **Dependency injection:** `get_it` + `injectable` with generated bindings in `lib/app/di/injection.config.dart`, initialized from `configureDependencies()` in `lib/app/di/injection.dart` and called in `lib/main.dart`.
- **Routing:** `AppRouter` + `AppRoutes` in `lib/app/router/*`, role-aware routing via `AppRole`.
- **Localization: For now all texts in portuguese from portugal without translations.
- **Design tokens:** `lib/app/theme/*` for colors, spacing, typography, motion, radius, elevation.

## MVP Decisions (Confirmed)
- **State management (MVP direction):** Riverpod with codegen (`riverpod_generator` + `build_runner`) and `riverpod_lint` for consistency and safer provider usage.
- **Spacing tokens:** 4/8pt grid with `4, 8, 12, 16, 24, 32, 40, 48` to keep layouts calm and predictable.
- **Typography scale:** small, readable scale mapped to Material text styles for predictable rendering (display → headline → title → body → caption).
- **Role-based navigation:** bottom tabs for Client + Driver (daily-flow speed) and a single admin dashboard for Admin (management-first).

## Clean Architecture Boundaries (How They Interact)
**Presentation → Domain → Data** only.
- **Presentation (UI + BLoC/Cubit)**
  - Uses domain use cases; emits states for UI rendering.
  - Example: `AuthBloc` calls `SignInUseCase` and emits loading/success/failure states.
- **Domain (Entities + Use Cases + Repository Interfaces)**
  - Owns business rules and workflow decisions.
  - Use cases depend on repository interfaces only.
- **Data (Repositories + Data Sources)**
  - Implements repository interfaces.
  - Holds platform/API/Firebase logic and mock data.

This keeps platform/Firebase code isolated to Data. UI never performs business logic beyond reacting to state.

## Mock Data Implementation (Current + Recommended)
### Current Pattern
- **Fake repositories in Data:**
  - `FakeAuthRepository` (`lib/features/auth/data/repositories/fake_auth_repository.dart`).
- **Local data sources for mock entities:**
  - `LocalDriverLocationDataSource` (`lib/features/map/data/data_sources/local_driver_location_data_source.dart`).
- **Repository implementations wrap data sources:**
  - `MapRepositoryImpl` uses `DriverLocationDataSource` (`lib/features/map/data/repositories/map_repository_impl.dart`).
- **DI binds mocks to interfaces:**
  - `injection.config.dart` registers fake/local implementations for interfaces (e.g., `AuthRepository`, `DriverLocationDataSource`).

### Recommended Mock Strategy for New Features
1. **Define repository interfaces in Domain**
   - Example path: `lib/features/trips/domain/repositories/trips_repository.dart`.
2. **Create mock data sources in Data**
   - Example path: `lib/features/trips/data/datasources/local_trip_data_source.dart`.
3. **Implement repositories in Data**
   - Example path: `lib/features/trips/data/repositories/trips_repository_fake_impl.dart`.
4. **Register mocks in DI**
   - Update bindings in `lib/app/di/injection.config.dart` (or via injectable annotations), keeping Presentation and Domain unchanged.

This ensures mock data is replaceable without leaking into Domain/Presentation.

## Switching to Firebase Later (Without Breaking Boundaries)
When ready to replace mocks:
1. **Add Firebase data sources in Data layer**
   - `lib/features/<feature>/data/datasources/firebase_<feature>_data_source.dart`.
2. **Create repository implementations that use Firebase data sources**
   - `lib/features/<feature>/data/repositories/<feature>_repository_firebase_impl.dart`.
3. **Update DI registration**
   - Swap `Fake*` / `Local*` bindings to Firebase implementations in `lib/app/di/injection.config.dart`.
4. **Preserve Domain + Presentation**
   - No changes required in `domain` entities/use cases or `presentation` BLoCs/Cubits.

This maintains clean boundaries and keeps the app swap-ready for real services.

## Navigation Cleanup
- Removed unused placeholder screens that were not part of the current role-based flows (PricingScreen, ReportsScreen, TripsScreen, DriverScreen, AdminModuleScreen).
