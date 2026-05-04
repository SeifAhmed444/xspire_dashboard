import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'XSpire Dashboard',
      'food_outlet_management': 'Food Outlet Management',
      'quick_actions': 'Quick Actions',
      'add_bag_item': 'Add Bag Item',
      'add_bag_item_label': 'Add\nBag Item',
      'scan_add_bags': 'Scan & add bags',
      'add_restaurant': 'Add Restaurant',
      'add_restaurant_label': 'Add\nRestaurant',
      'create_new_restaurant': 'Create new restaurant',
      'manage_restaurants': 'Manage Restaurants',
      'manage_restaurants_label': 'Manage\nRestaurants',
      'view_edit_delete': 'View, edit & delete',
      'analytics_stats': 'Analytics & Stats',
      'analytics_stats_label': 'Analytics\n& Stats',
      'logout': 'Logout',
      'restaurant_name': 'Restaurant Name',
      'branch_location': 'Branch Location',
      'number_of_branches': 'Number of Branches',
      'save': 'Save',
      'cancel': 'Cancel',
      'edit': 'Edit',
      'delete': 'Delete',
      'available': 'Available',
      'not_available': 'Not Available',
      'open': 'Open',
      'closed': 'Closed',
      'reserve': 'Reserve',
      'bags_left': 'Bags left',
      'pickup_time': 'Pickup Time',
      'old_price': 'Old Price',
      'new_price': 'New Price',
      'quantity': 'Quantity',
      'is_available': 'Is available',
      'upload_image': 'Upload Image',
      'no_image_selected': 'No image selected',
      'restaurant_added': 'Restaurant added successfully',
      'restaurant_updated': 'Restaurant updated successfully',
      'restaurant_deleted': 'Restaurant deleted successfully',
      'error_occurred': 'An error occurred',
      'try_again': 'Try Again',
      'no_restaurants': 'No Restaurants Yet',
      'no_bags': 'No bags available yet',
      'coming_soon': 'Coming soon',
      'english': 'English',
      'arabic': 'العربية',
      'verify_detected_items': 'Verify Detected Items',
      'bag_item': 'Bag Item',
      'delete_item': 'Delete item',
      'will_be_deleted': 'Will be deleted on save',
      'undo': 'Undo',
      'old_price_egp': 'Old Price (EGP)',
      'new_price_egp': 'New Price (EGP)',
      'quantity_label': 'Quantity',
      'no_items_to_save': 'No items to save. Please add at least one item.',
      'select_restaurant': 'Select Restaurant',
      'no_restaurants_yet': 'No restaurants yet. Add one first!',
      'choose_restaurant': 'Choose a restaurant',
      'please_select_restaurant': 'Please select a restaurant',
    },
    'ar': {
      'app_title': 'XSpire لوحة التحكم',
      'food_outlet_management': 'إدارة منافذ الطعام',
      'quick_actions': 'الإجراءات السريعة',
      'add_bag_item': 'إضافة حقيبة',
      'add_bag_item_label': 'إضافة\nحقيبة',
      'scan_add_bags': 'مسح وإضافة حقائب',
      'add_restaurant': 'إضافة مطعم',
      'add_restaurant_label': 'إضافة\nمطعم',
      'create_new_restaurant': 'إنشاء مطعم جديد',
      'manage_restaurants': 'إدارة المطاعم',
      'manage_restaurants_label': 'إدارة\nالمطاعم',
      'view_edit_delete': 'عرض، تعديل وحذف',
      'analytics_stats': 'التحليلات والإحصائيات',
      'analytics_stats_label': 'التحليلات\nوالإحصائيات',
      'logout': 'تسجيل الخروج',
      'restaurant_name': 'اسم المطعم',
      'branch_location': 'موقع الفرع',
      'number_of_branches': 'عدد الفروع',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'edit': 'تعديل',
      'delete': 'حذف',
      'available': 'متاح',
      'not_available': 'غير متاح',
      'open': 'مفتوح',
      'closed': 'مغلق',
      'reserve': 'احجز',
      'bags_left': 'حقيبة متبقية',
      'pickup_time': 'وقت الاستلام',
      'old_price': 'السعر القديم',
      'new_price': 'السعر الجديد',
      'quantity': 'الكمية',
      'is_available': 'متاح',
      'upload_image': 'رفع صورة',
      'no_image_selected': 'لم يتم اختيار صورة',
      'restaurant_added': 'تم إضافة المطعم بنجاح',
      'restaurant_updated': 'تم تحديث المطعم بنجاح',
      'restaurant_deleted': 'تم حذف المطعم بنجاح',
      'error_occurred': 'حدث خطأ',
      'try_again': 'حاول مرة أخرى',
      'no_restaurants': 'لا يوجد مطاعم بعد',
      'no_bags': 'لا توجد حقائب متاحة',
      'coming_soon': 'قريباً',
      'english': 'English',
      'arabic': 'العربية',
      'verify_detected_items': 'التحقق من العناصر المكتشفة',
      'bag_item': 'عنصر الحقيبة',
      'delete_item': 'حذف العنصر',
      'will_be_deleted': 'سيتم الحذف عند الحفظ',
      'undo': 'تراجع',
      'old_price_egp': 'السعر القديم (جنيه)',
      'new_price_egp': 'السعر الجديد (جنيه)',
      'quantity_label': 'الكمية',
      'no_items_to_save': 'لا يوجد عناصر للحفظ. يرجى إضافة عنصر واحد على الأقل.',
      'select_restaurant': 'اختيار المطعم',
      'no_restaurants_yet': 'لا يوجد مطاعم بعد. أضف واحداً أولاً!',
      'choose_restaurant': 'اختر مطعماً',
      'please_select_restaurant': 'يرجى اختيار مطعم',
    },
  };
  
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
  
  String get appTitle => translate('app_title');
  String get foodOutletManagement => translate('food_outlet_management');
  String get quickActions => translate('quick_actions');
  String get addBagItem => translate('add_bag_item');
  String get addBagItemLabel => translate('add_bag_item_label');
  String get scanAddBags => translate('scan_add_bags');
  String get addRestaurantLabel => translate('add_restaurant_label');
  String get createNewRestaurant => translate('create_new_restaurant');
  String get manageRestaurantsLabel => translate('manage_restaurants_label');
  String get viewEditDelete => translate('view_edit_delete');
  String get analyticsStatsLabel => translate('analytics_stats_label');
  String get addRestaurant => translate('add_restaurant');
  String get manageRestaurants => translate('manage_restaurants');
  String get analyticsStats => translate('analytics_stats');
  String get logout => translate('logout');
  String get restaurantName => translate('restaurant_name');
  String get branchLocation => translate('branch_location');
  String get numberOfBranches => translate('number_of_branches');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get edit => translate('edit');
  String get delete => translate('delete');
  String get available => translate('available');
  String get notAvailable => translate('not_available');
  String get open => translate('open');
  String get closed => translate('closed');
  String get reserve => translate('reserve');
  String get bagsLeft => translate('bags_left');
  String get pickupTime => translate('pickup_time');
  String get oldPrice => translate('old_price');
  String get newPrice => translate('new_price');
  String get quantity => translate('quantity');
  String get isAvailable => translate('is_available');
  String get uploadImage => translate('upload_image');
  String get noImageSelected => translate('no_image_selected');
  String get restaurantAdded => translate('restaurant_added');
  String get restaurantUpdated => translate('restaurant_updated');
  String get restaurantDeleted => translate('restaurant_deleted');
  String get errorOccurred => translate('error_occurred');
  String get tryAgain => translate('try_again');
  String get noRestaurants => translate('no_restaurants');
  String get noBags => translate('no_bags');
  String get comingSoon => translate('coming_soon');
  String get english => translate('english');
  String get arabic => translate('arabic');
  String get verifyDetectedItems => translate('verify_detected_items');
  String get bagItem => translate('bag_item');
  String get deleteItem => translate('delete_item');
  String get willBeDeleted => translate('will_be_deleted');
  String get undo => translate('undo');
  String get oldPriceEgp => translate('old_price_egp');
  String get newPriceEgp => translate('new_price_egp');
  String get quantityLabel => translate('quantity_label');
  String get noItemsToSave => translate('no_items_to_save');
  String get selectRestaurant => translate('select_restaurant');
  String get noRestaurantsYet => translate('no_restaurants_yet');
  String get chooseRestaurant => translate('choose_restaurant');
  String get pleaseSelectRestaurant => translate('please_select_restaurant');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
