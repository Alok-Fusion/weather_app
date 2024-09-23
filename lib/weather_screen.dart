import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_app/HourlyForecast.dart';
import 'package:weather_app/additionalinfo.dart';
import 'package:weather_app/env.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityname = 'Mumbai';
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityname,&APPID=$weatherapi',
        ),
      );
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'An unexpected error occurred';
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: weather,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            //String currenttemp.toStringAsFixed(2);
            final data = snapshot.data!;
            final list = data['list'][0];
            final currenttemp =
                (list['main']['temp'] - 273.15).toStringAsFixed(2);
            final currentsky = list['weather'][0]['main'];
            final currentpressure = list['main']['pressure'];
            final currentwindspeed = list['wind']['speed'];
            final currenthumidity = list['main']['humidity'];
            final currentcity = data['city']['name'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 15,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  '$currenttemp ℃',
                                  style: const TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Icon(
                                  currentsky == 'Clouds' || currentsky == 'Rain'
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  size: 70,
                                ),
                                Text(
                                  currentsky,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontFamily: 'Times New Roman'),
                                ),
                                Text(
                                  currentcity,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Times New Roman'),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Hourly ForeCast',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 128,
                    child: ListView.builder(
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final hourlyForecast = data['list'][index + 1];
                        final hourlysky =
                            data['list'][index + 1]['weather'][0]['main'];
                        final hourlytemp =
                            (data['list'][index + 1]['main']['temp'] - 273.15)
                                .toStringAsFixed(2);
                        final time = DateTime.parse(hourlyForecast['dt_txt']);
                        return HourlyForecast(
                          time: DateFormat.j().format(time),
                          icon: hourlysky == 'Clouds' || hourlysky == 'Rain'
                              ? Icons.cloud
                              : Icons.sunny,
                          label: hourlytemp,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Additional Information',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditionalInfo(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: currenthumidity.toString(),
                      ),
                      AdditionalInfo(
                          icon: Icons.air,
                          label: 'wind speed',
                          value: currentwindspeed.toString()),
                      AdditionalInfo(
                          icon: Icons.beach_access,
                          label: 'Pressure',
                          value: currentpressure.toString()),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
