/// Where each chit falls on the timeline's three-day window (ADR-024).
///
/// Midnight to midnight, today and the two days before it, proportional to
/// real time. *This file was `day_arc_provider.dart` and the strip was the day
/// arc, running 5am to midnight over one day; ADR-024 says why it is not.*
///
/// Arrives in M2. Placed here now so the layer it belongs to is decided
/// before the code is written — ARCHITECTURE.md §1 and §2.

library;
