/// Paths to every image and icon in `assets/`. Screens reference images only
/// through these constants (`ImageConst.google`), never a path string — add a
/// constant here when you add a file to `assets/`.
abstract final class ImageConst {
  static const String _root = 'assets';
  static const String _foods = '$_root/foods';
  static const String _navBar = '$_root/navBar';
  static const String _banner = '$_root/banner';

  // App logo
  static const String logo = '$_root/logo.png';

  /// White line-art waves (SVG), drawn faintly over the Settings header.
  static const String waveVectorPattern =
      '$_root/redesign_wave_vector_pattern.svg';

  // Home screen promotional banners
  static const String banner1 = '$_banner/banner1.jpg';
  static const String banner2 = '$_banner/banner2.jpg';
  static const String banner3 = '$_banner/banner3.jpeg';

  /// All banners in display order — used by the home carousel.
  static const List<String> banners = [banner1, banner2, banner3];

  // Bank logos
  static const String aba = '$_root/aba.png';
  static const String acleda = '$_root/acleda.png';
  static const String bakong = '$_root/bakong.png';

  // Sign-in providers
  static const String facebook = '$_root/facebook.png';
  static const String google = '$_root/google.png';
  static const String microsoft = '$_root/microsoft.png';

  // Icons
  static const String spatulaSpoon =
      '$_root/fluent_spatula-spoon-48-regular.png';

  // Bottom navigation bar
  static const String navBarGroup = '$_navBar/Group.png';
  static const String navBarVector = '$_navBar/Vector.png';
  static const String navBarVector1 = '$_navBar/Vector-1.png';
  static const String navBarVector2 = '$_navBar/Vector-2.png';
  static const String navBarQrCode = '$_navBar/bi_qr-code.png';

  // Lottie animations
  static const String cookingLoader = '$_root/lottie/cooking_loader.json';
  static const String checkMark = '$_root/lottie/check_mark.json';

  // Dishes and drinks
  static const String beefLokLak = '$_foods/beef_lok_lak.png';
  static const String chickenWithRice = '$_foods/chicken_with_rice.png';
  static const String coconutMilkTea = '$_foods/coconut_milk_tea.png';
  static const String exclusive = '$_foods/exlusive.png';
  static const String friedEggRice = '$_foods/fried_egg_rice.png';
  static const String khmerNoodle = '$_foods/khmer_noodle.png';
  static const String porkWithRice = '$_foods/pork_with_rice.png';
  static const String sugarcaneJuice = '$_foods/sugarcane_juice.png';
}
