class Weather {
  final String cityName;
  final double temperature;
  final double min;
  final double max;
  final String icon;
  final String description;
  final String mainCondition;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.min,
    required this.max,
    required this.icon,
    required this.description,
    required this.mainCondition,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      min: json['main']['temp_min'].toDouble(),
      max: json['main']['temp_max'].toDouble(),
      icon: json['weather'][0]['icon'],
      description: json['weather'][0]['description'],
      mainCondition: json['weather'][0]['main'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': cityName,
      'main': {
        'temp': temperature,
        'temp_min': min,
        'temp_max': max,
      },
      'weather': [
        {
          'icon': icon,
          'description': description,
          'main': mainCondition,
        }
      ],
    };
  }
}
