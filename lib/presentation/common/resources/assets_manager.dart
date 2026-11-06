const String imagePath = 'assets/images';
const String jsonPath = 'assets/json';
const String animationPath = 'assets/animation';
const String patternPath = 'assets/pattern';
const String stampPath = 'assets/stamp';
const String videoPath = 'assets/videos';
const String cardsPath = 'assets/images/cards';

const String zooPath = 'assets/images/zoo';
const String seaPath = 'assets/images/sea';
const String dragonsPath = 'assets/images/dragons';
const String fairyPath = 'assets/images/fairy';
const String spacePath = 'assets/images/space';
const String transportationPath = 'assets/images/transportation';
const String circisPath = 'assets/images/circis';
const String foodPath = 'assets/images/food';
const String lettersPath = 'assets/images/letters';
const String numbersPath = 'assets/images/numbers';
const String flowersPath = 'assets/images/planet';

class ImageAssets {
  static const String dragon = '$animationPath/dragon.riv';
  static const String animals = '$animationPath/Jungle.riv';

  static const String background = '$imagePath/background.png';
  static const String jungle = '$imagePath/jungle.svg';
  static const String ant = '$imagePath/ant.svg';

  static const String zoo = '$imagePath/jungle.png';
  static const String dragons = '$imagePath/dragon.png';
  static const String fairy = '$imagePath/fairy.png';
  static const String sea = '$imagePath/sea.png';
  static const String food = '$imagePath/food.png';
  static const String space = '$imagePath/space.png';
  static const String cars = '$imagePath/cars.png';
  static const String numbers = '$imagePath/numbers.png';
  static const String letters = '$imagePath/letters.png';
  static const String flowers = '$imagePath/flowers.png';

  static const String cirks = '$imagePath/cirks.png';
  static const String glitter = '$imagePath/10.png';
  static const String camera = '$imagePath/camera.png';
  static const String redo = '$imagePath/redo.png';
  static const String close = '$imagePath/close.png';

  static const String eraser = '$imagePath/eraser.png';
  static const String magic = '$imagePath/magic.png';
  static const String fill1 = '$imagePath/fill1.svg';
  static const String fill2 = '$imagePath/fill2.svg';
  static const String glitter1 = '$imagePath/glitter1.svg';
  static const String glitter2 = '$imagePath/glitter2.svg';
  static const String glitter3 = '$imagePath/glitter3.svg';
  static const String freeHand1 = '$imagePath/freeHand1.svg';
  static const String freeHand2 = '$imagePath/freeHand2.svg';
  static const String pencil1 = '$imagePath/pencil1.svg';
  static const String pencil2 = '$imagePath/pencil2.svg';
  static const String wallpaper = '$imagePath/wallpaper.svg';
  static const String stamp = '$imagePath/stamp.svg';
  static const String delete = '$imagePath/delete.svg';
  static const String appIcon = '$imagePath/app_icon.png';
  static const String splashBackground = '$imagePath/splash_bg.jpg';
  static const String zero = '$imagePath/0.svg';
}

class JsonAssets {
  // The file in assets/json is named Loader.json (capital L). The old names
  // loading.json, empty.json and error.json do not exist in the asset folder,
  // which caused the "missing asset" errors in the logcat.
  // TODO(owner): add real error.json and empty.json, then point these at them.
  static const String loading = '$jsonPath/Loader.json';
  static const String empty = '$jsonPath/Loader.json';
  static const String error = '$jsonPath/Loader.json';
  static const String success = '$jsonPath/success.json';
  static const String location = '$jsonPath/location.json';
  static const String phone = '$jsonPath/phone.json';
  static const String location1 = '$jsonPath/location1.json';
  static const String sepha = '$jsonPath/sepha.json';
  static const String start = '$jsonPath/start.json';
  static const String leaves = '$jsonPath/leaves.json';
  static const String mainBackground = '$jsonPath/main background.json';
  static const String home = '$jsonPath/home.json';
  static const String loader = '$jsonPath/Loader.json';
  static const String setting = '$jsonPath/setting.json';
  static const String confetti = '$jsonPath/Confetti.json';
  static const String giftBox = '$jsonPath/giftBox.json';
}

////////////////////////////////// pattern Images////////////////////////////
class PatternAssets {
  static String asset(int index) => '$patternPath/$index.webp';
}

//////////////////////////////////// stamps Images////////////////////////////
class StampsAssets {
  static String asset(int index) => '$stampPath/$index.svg';
}

//////////////////////////////////// zoo Images////////////////////////////
class ZooAssets {
  static String asset(int index) => '$zooPath/$index.svg';
}

//////////////////////////////////// Sea Images////////////////////////////
class SeaAssets {
  static String asset(int index) => '$seaPath/$index.svg';
}

//////////////////////////////////// Dragons Images////////////////////////////

class DragonsAssets {
  static String asset(int index) => '$dragonsPath/$index.svg';
}

//////////////////////////////////// fairy Images////////////////////////////

class FairyAssets {
  static String asset(int index) => '$fairyPath/$index.svg';
}

//////////////////////////////////// space Images////////////////////////////

class SpaceAssets {
  static String asset(int index) => '$spacePath/$index.svg';
}

//////////////////////////////////// cirkis Images////////////////////////////

class CirclesAssets {
  static String asset(int index) => '$circisPath/$index.svg';
}

//////////////////////////////////// Transportation Images////////////////////////////

class TransportationAssets {
  static String asset(int index) => '$transportationPath/$index.svg';
}

//////////////////////////////////// food Images////////////////////////////

class FoodAssets {
  static String asset(int index) => '$foodPath/$index.svg';
}

//////////////////////////////////// letters Images////////////////////////////

class LettersAssets {
  static String asset(int index) => '$lettersPath/$index.svg';
}

//////////////////////////////////// numbers Images////////////////////////////

class NumbersAssets {
  static String asset(int index) => '$numbersPath/$index.svg';
}

//////////////////////////////////// flowers Images////////////////////////////

class FlowersAssets {
  static String asset(int index) => '$flowersPath/$index.svg';
}

//////////////////////////////////// Home cards (Lottie)////////////////////////////

class CardAssets {
  static const String jungle = '$cardsPath/jungle.json';
  static const String sea = '$cardsPath/sea.json';
  static const String dragons = '$cardsPath/dragons.json';
  static const String fairy = '$cardsPath/fairy.json';
  static const String space = '$cardsPath/space.json';
  static const String cars = '$cardsPath/cars.json';
  static const String circus = '$cardsPath/circus.json';
  static const String food = '$cardsPath/food.json';
  static const String flowers = '$cardsPath/flowers.json';
  static const String letters = '$cardsPath/letters.json';
  static const String numbers = '$cardsPath/numbers.json';
  static const String freeHand = '$cardsPath/free hand.json';
}

//////////////////////////////////// Videos////////////////////////////

class VideoAssets {
  static const String jungle = '$videoPath/jungle.mp4';
  static const String sea = '$videoPath/sea.mp4';
  static const String dragons = '$videoPath/dragons.mp4';
  static const String fairy = '$videoPath/fairy.mp4';
  static const String space = '$videoPath/space.mp4';
  static const String cars = '$videoPath/cars.mp4';
  static const String cirks = '$videoPath/cirks.mp4';
  static const String food = '$videoPath/food.mp4';
  static const String flowers = '$videoPath/flowers.mp4';
  static const String letters = '$videoPath/letters.mp4';
  static const String numbers = '$videoPath/numbers.mp4';
  static const String whiteboard = '$videoPath/whiteboard.mp4';
}
