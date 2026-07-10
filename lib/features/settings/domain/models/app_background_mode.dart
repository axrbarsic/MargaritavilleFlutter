enum AppBackgroundMode {
  off,
  matrixRain,
  tvStaticNoise,
  video;

  String get title => switch (this) {
    AppBackgroundMode.off => 'Выкл',
    AppBackgroundMode.matrixRain => 'Matrix',
    AppBackgroundMode.tvStaticNoise => 'TV',
    AppBackgroundMode.video => 'Видео',
  };

  String get description => switch (this) {
    AppBackgroundMode.off => 'Чёрный фон',
    AppBackgroundMode.matrixRain => 'Matrix Rain',
    AppBackgroundMode.tvStaticNoise => 'Сломанный телевизор',
    AppBackgroundMode.video => 'Видео фон',
  };
}
