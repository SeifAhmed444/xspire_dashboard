import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'XSpire Dashboard'**
  String get app_title;

  /// No description provided for @food_outlet_management.
  ///
  /// In en, this message translates to:
  /// **'Food Outlet Management'**
  String get food_outlet_management;

  /// No description provided for @quick_actions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quick_actions;

  /// No description provided for @add_bag_item.
  ///
  /// In en, this message translates to:
  /// **'Add Bag Item'**
  String get add_bag_item;

  /// No description provided for @add_bag_item_label.
  ///
  /// In en, this message translates to:
  /// **'Add\nBag Item'**
  String get add_bag_item_label;

  /// No description provided for @scan_add_bags.
  ///
  /// In en, this message translates to:
  /// **'Scan & add bags'**
  String get scan_add_bags;

  /// No description provided for @add_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Add Restaurant'**
  String get add_restaurant;

  /// No description provided for @add_restaurant_label.
  ///
  /// In en, this message translates to:
  /// **'Add\nRestaurant'**
  String get add_restaurant_label;

  /// No description provided for @create_new_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Create new restaurant'**
  String get create_new_restaurant;

  /// No description provided for @manage_restaurants.
  ///
  /// In en, this message translates to:
  /// **'Manage Restaurants'**
  String get manage_restaurants;

  /// No description provided for @manage_restaurants_label.
  ///
  /// In en, this message translates to:
  /// **'Manage\nRestaurants'**
  String get manage_restaurants_label;

  /// No description provided for @view_edit_delete.
  ///
  /// In en, this message translates to:
  /// **'View, edit & delete'**
  String get view_edit_delete;

  /// No description provided for @analytics_stats.
  ///
  /// In en, this message translates to:
  /// **'Analytics & Stats'**
  String get analytics_stats;

  /// No description provided for @analytics_stats_label.
  ///
  /// In en, this message translates to:
  /// **'Analytics\n& Stats'**
  String get analytics_stats_label;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @restaurant_name.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Name'**
  String get restaurant_name;

  /// No description provided for @branch_location.
  ///
  /// In en, this message translates to:
  /// **'Branch Location'**
  String get branch_location;

  /// No description provided for @number_of_branches.
  ///
  /// In en, this message translates to:
  /// **'Number of Branches'**
  String get number_of_branches;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @not_available.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get not_available;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @reserve.
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get reserve;

  /// No description provided for @bags_left.
  ///
  /// In en, this message translates to:
  /// **'Bags left'**
  String get bags_left;

  /// No description provided for @pickup_time.
  ///
  /// In en, this message translates to:
  /// **'Pickup Time'**
  String get pickup_time;

  /// No description provided for @old_price.
  ///
  /// In en, this message translates to:
  /// **'Old Price'**
  String get old_price;

  /// No description provided for @new_price.
  ///
  /// In en, this message translates to:
  /// **'New Price'**
  String get new_price;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @is_available.
  ///
  /// In en, this message translates to:
  /// **'Is available'**
  String get is_available;

  /// No description provided for @upload_image.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get upload_image;

  /// No description provided for @no_image_selected.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get no_image_selected;

  /// No description provided for @restaurant_added.
  ///
  /// In en, this message translates to:
  /// **'Restaurant added successfully'**
  String get restaurant_added;

  /// No description provided for @restaurant_updated.
  ///
  /// In en, this message translates to:
  /// **'Restaurant updated successfully'**
  String get restaurant_updated;

  /// No description provided for @restaurant_deleted.
  ///
  /// In en, this message translates to:
  /// **'Restaurant deleted successfully'**
  String get restaurant_deleted;

  /// No description provided for @error_occurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error_occurred;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get try_again;

  /// No description provided for @no_restaurants.
  ///
  /// In en, this message translates to:
  /// **'No Restaurants Yet'**
  String get no_restaurants;

  /// No description provided for @no_bags.
  ///
  /// In en, this message translates to:
  /// **'No bags available yet'**
  String get no_bags;

  /// No description provided for @coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get coming_soon;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @verify_detected_items.
  ///
  /// In en, this message translates to:
  /// **'Verify Detected Items'**
  String get verify_detected_items;

  /// No description provided for @bag_item.
  ///
  /// In en, this message translates to:
  /// **'Bag Item'**
  String get bag_item;

  /// No description provided for @delete_item.
  ///
  /// In en, this message translates to:
  /// **'Delete item'**
  String get delete_item;

  /// No description provided for @will_be_deleted.
  ///
  /// In en, this message translates to:
  /// **'Will be deleted on save'**
  String get will_be_deleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @old_price_egp.
  ///
  /// In en, this message translates to:
  /// **'Old Price (EGP)'**
  String get old_price_egp;

  /// No description provided for @new_price_egp.
  ///
  /// In en, this message translates to:
  /// **'New Price (EGP)'**
  String get new_price_egp;

  /// No description provided for @quantity_label.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity_label;

  /// No description provided for @no_items_to_save.
  ///
  /// In en, this message translates to:
  /// **'No items to save. Please add at least one item.'**
  String get no_items_to_save;

  /// No description provided for @select_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Select Restaurant'**
  String get select_restaurant;

  /// No description provided for @no_restaurants_yet.
  ///
  /// In en, this message translates to:
  /// **'No restaurants yet. Add one first!'**
  String get no_restaurants_yet;

  /// No description provided for @choose_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Choose a restaurant'**
  String get choose_restaurant;

  /// No description provided for @please_select_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Please select a restaurant'**
  String get please_select_restaurant;

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcome_back;

  /// No description provided for @sign_in_to_continue_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue to your dashboard'**
  String get sign_in_to_continue_dashboard;

  /// No description provided for @demo_accounts.
  ///
  /// In en, this message translates to:
  /// **'Demo Accounts'**
  String get demo_accounts;

  /// No description provided for @tap_any_account_auto_fill.
  ///
  /// In en, this message translates to:
  /// **'Tap any account to auto-fill credentials'**
  String get tap_any_account_auto_fill;

  /// No description provided for @email_address.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email_address;

  /// No description provided for @password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password_label;

  /// No description provided for @email_is_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get email_is_required;

  /// No description provided for @enter_valid_email.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get enter_valid_email;

  /// No description provided for @password_is_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get password_is_required;

  /// No description provided for @password_min_length.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get password_min_length;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in;

  /// No description provided for @add_logo.
  ///
  /// In en, this message translates to:
  /// **'Add Logo'**
  String get add_logo;

  /// No description provided for @restaurant_name_example.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Name (e.g. Madbina)'**
  String get restaurant_name_example;

  /// No description provided for @branch_location_example.
  ///
  /// In en, this message translates to:
  /// **'Branch Location (e.g. Zamalek, 2 Taha Hussein)'**
  String get branch_location_example;

  /// No description provided for @open_now.
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get open_now;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @save_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Save Restaurant'**
  String get save_restaurant;

  /// No description provided for @restaurant_logo_required.
  ///
  /// In en, this message translates to:
  /// **'Please add a restaurant logo before saving'**
  String get restaurant_logo_required;

  /// No description provided for @edit_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Edit Restaurant'**
  String get edit_restaurant;

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save_changes;

  /// No description provided for @restaurant_image.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Image'**
  String get restaurant_image;

  /// No description provided for @tap_to_change.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get tap_to_change;

  /// No description provided for @tap_to_select_image.
  ///
  /// In en, this message translates to:
  /// **'Tap to select image'**
  String get tap_to_select_image;

  /// No description provided for @required_label.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required_label;

  /// No description provided for @loading_bags.
  ///
  /// In en, this message translates to:
  /// **'Loading bags...'**
  String get loading_bags;

  /// No description provided for @available_bags.
  ///
  /// In en, this message translates to:
  /// **'Available bags'**
  String get available_bags;

  /// No description provided for @bags_left_label.
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String bags_left_label(Object count);

  /// No description provided for @reserve_button.
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get reserve_button;

  /// No description provided for @delete_product.
  ///
  /// In en, this message translates to:
  /// **'Delete product'**
  String get delete_product;

  /// No description provided for @no_restaurants_yet_cta.
  ///
  /// In en, this message translates to:
  /// **'No Restaurants Yet'**
  String get no_restaurants_yet_cta;

  /// No description provided for @add_first_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Add your first restaurant to start selling bags.'**
  String get add_first_restaurant;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @confirm_logout.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirm_logout;

  /// No description provided for @are_you_sure_logout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get are_you_sure_logout;

  /// No description provided for @logout_button.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout_button;

  /// No description provided for @latest_reviews.
  ///
  /// In en, this message translates to:
  /// **'Latest Reviews'**
  String get latest_reviews;

  /// No description provided for @total_restaurants.
  ///
  /// In en, this message translates to:
  /// **'Total Restaurants'**
  String get total_restaurants;

  /// No description provided for @total_reviews.
  ///
  /// In en, this message translates to:
  /// **'Total Reviews'**
  String get total_reviews;

  /// No description provided for @total_products.
  ///
  /// In en, this message translates to:
  /// **'Total Products'**
  String get total_products;

  /// No description provided for @average_rating.
  ///
  /// In en, this message translates to:
  /// **'Average Rating'**
  String get average_rating;

  /// No description provided for @restaurant_breakdown.
  ///
  /// In en, this message translates to:
  /// **'Restaurant Breakdown'**
  String get restaurant_breakdown;

  /// No description provided for @debug_analytics_data.
  ///
  /// In en, this message translates to:
  /// **'Debug: Analytics Data'**
  String get debug_analytics_data;

  /// No description provided for @product_performance.
  ///
  /// In en, this message translates to:
  /// **'Product Performance:'**
  String get product_performance;

  /// No description provided for @no_rated_products_yet.
  ///
  /// In en, this message translates to:
  /// **'No rated products yet'**
  String get no_rated_products_yet;

  /// No description provided for @your_best_products.
  ///
  /// In en, this message translates to:
  /// **'⭐ Your Best Products'**
  String get your_best_products;

  /// No description provided for @products_needing_attention.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Products Needing Attention'**
  String get products_needing_attention;

  /// No description provided for @manager_alerts.
  ///
  /// In en, this message translates to:
  /// **'Manager Alerts'**
  String get manager_alerts;

  /// No description provided for @low_stock.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get low_stock;

  /// No description provided for @unavailable_products.
  ///
  /// In en, this message translates to:
  /// **'Unavailable products'**
  String get unavailable_products;

  /// No description provided for @no_reviews_yet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get no_reviews_yet;

  /// No description provided for @discounted_products.
  ///
  /// In en, this message translates to:
  /// **'Discounted products'**
  String get discounted_products;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @no_reviews.
  ///
  /// In en, this message translates to:
  /// **'✗ No reviews'**
  String get no_reviews;

  /// No description provided for @sample_review.
  ///
  /// In en, this message translates to:
  /// **'✓ Sample: \"{text}\" ({rating}★ by {name})'**
  String sample_review(Object name, Object rating, Object text);

  /// No description provided for @delete_restaurant.
  ///
  /// In en, this message translates to:
  /// **'Delete Restaurant'**
  String get delete_restaurant;

  /// No description provided for @delete_restaurant_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String delete_restaurant_confirm(Object name);

  /// No description provided for @delete_product_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this product? This cannot be undone.'**
  String get delete_product_confirm;

  /// No description provided for @product_deleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get product_deleted;

  /// No description provided for @product_count.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String product_count(Object count);

  /// No description provided for @available_hidden.
  ///
  /// In en, this message translates to:
  /// **'{available} available • {hidden} hidden'**
  String available_hidden(Object available, Object hidden);

  /// No description provided for @reviews_low_stock.
  ///
  /// In en, this message translates to:
  /// **'{reviews} reviews • {lowStock} low stock'**
  String reviews_low_stock(Object lowStock, Object reviews);

  /// No description provided for @no_reviews_count.
  ///
  /// In en, this message translates to:
  /// **'{count} no reviews'**
  String no_reviews_count(Object count);

  /// No description provided for @discounted_count.
  ///
  /// In en, this message translates to:
  /// **'{count} discounted'**
  String discounted_count(Object count);

  /// No description provided for @pickup_default.
  ///
  /// In en, this message translates to:
  /// **'Pickup 9:00 AM - 11:59 PM'**
  String get pickup_default;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
