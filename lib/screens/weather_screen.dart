import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // services
  final _weatherService = WeatherService();
  final _locationService = LocationService();

  // controller
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  // loading animation
  bool _loading = true;

  // city list
  final List<String> _cities = ['Dortmund', 'Hamburg', 'Berlin'];

  // weather icons
  FaIcon getWeatherIcon(String? condition, size, color) {
    if (condition == null) {
      return FaIcon(FontAwesomeIcons.cloud,
          size: size, color: color); // default if null
    }

    switch (condition.toLowerCase()) {
      case '01d':
      case '01n':
        return FaIcon(FontAwesomeIcons.sun, size: size, color: color);
      case '02d':
      case '02n':
        return FaIcon(FontAwesomeIcons.cloudSun, size: size, color: color);
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return FaIcon(FontAwesomeIcons.cloud, size: size, color: color);
      case '09d':
      case '09n':
        return FaIcon(FontAwesomeIcons.cloudRain, size: size, color: color);
      case '10d':
      case '10n':
        return FaIcon(FontAwesomeIcons.cloudSunRain, size: size, color: color);
      case '11d':
      case '11n':
        return FaIcon(FontAwesomeIcons.cloudBolt, size: size, color: color);
      case '13d':
      case '13n':
        return FaIcon(FontAwesomeIcons.snowflake, size: size, color: color);
      case '50d':
      case '50n':
        return FaIcon(FontAwesomeIcons.smog, size: size, color: color);
      default:
        return FaIcon(FontAwesomeIcons.cloud, size: size, color: color);
    }
  }

  // init state
  @override
  void initState() {
    super.initState();

    // get location
    _locationService.getLocality().then(
      (placemark) {
        _cities.insert(0, placemark.locality!);
        setState(() {
          _loading = false;
        });
      },
    );

    // add listener to pageController
    _pageController.addListener(
      () {
        setState(() {
          _currentPageIndex = _pageController.page!.round();
        });
      },
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: Colors.grey[200]))
            : Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _cities.length,
                      itemBuilder: (context, index) {
                        return _buildWeatherPage(_cities[index]);
                      },
                    ),
                  ),
                  _buildPageIndicator(),
                ],
              ),
      ),
    );
  }

  Widget _buildWeatherPage(locality) {
    return FutureBuilder<Weather>(
      future: _weatherService.fetchWeather(locality),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: Colors.grey[200]));
        } else if (snapshot.hasError) {
          return FutureBuilder<Weather?>(
            future: _weatherService.getWeatherData(locality),
            builder: (context, cacheSnapshot) {
              if (cacheSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: CircularProgressIndicator(color: Colors.grey[200]));
              } else if (cacheSnapshot.hasError || !cacheSnapshot.hasData) {
                return const Center(child: Text('No cached data available'));
              } else {
                final weather = cacheSnapshot.data!;
                return _buildWeatherInfo(weather);
              }
            },
          );
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data'));
        } else {
          final weather = snapshot.data!;
          // Save the fetched data to preferences
          _weatherService.saveWeatherData(locality, weather);
          return _buildWeatherInfo(weather);
        }
      },
    );
  }

  Widget _buildWeatherInfo(Weather weather) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // city name
        Text(weather.cityName,
            style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),

        const SizedBox(height: 30),

        // icon
        getWeatherIcon(weather.icon, 200.00, Colors.grey[200]),

        const SizedBox(height: 30),

        // temperature
        Text('${weather.temperature.round()}°C',
            style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),

        const SizedBox(height: 15),

        // min max temps in row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // max temperature
            FaIcon(FontAwesomeIcons.temperatureFull,
                size: 30, color: Colors.grey[200]),
            Text(' ${weather.max.round()}°C',
                style: const TextStyle(fontSize: 30)),

            const SizedBox(width: 30),

            // min temperature
            FaIcon(FontAwesomeIcons.temperatureEmpty,
                size: 30, color: Colors.grey[200]),
            Text(' ${weather.min.round()}°C',
                style: const TextStyle(fontSize: 30)),
          ],
        ),

        const SizedBox(height: 10),

        // description and main condition
        Text('${weather.description}, ${weather.mainCondition}',
            style: const TextStyle(fontSize: 20)),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_cities.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
          width: _currentPageIndex == index ? 12.0 : 8.0,
          height: _currentPageIndex == index ? 12.0 : 8.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPageIndex == index ? Colors.grey[200] : Colors.grey,
          ),
        );
      }),
    );
  }
}
