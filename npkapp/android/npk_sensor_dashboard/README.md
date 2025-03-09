# NPK Sensor Dashboard

This project is a modern and visually appealing dashboard for monitoring NPK sensor data from a Raspberry Pi. It features a clean layout, vibrant color palette, circular gauges, trend charts, and card-style components, all designed with smooth animations and modern typography.

## Features

- **Dashboard Screen**: Displays real-time sensor readings with circular gauges and trend charts.
- **History Screen**: View historical data in a user-friendly format.
- **Settings Screen**: Customize your dashboard experience with user settings.
- **Responsive Design**: Optimized for various screen sizes and orientations.
- **Smooth Animations**: Enhances user experience with fluid transitions and interactions.

## Project Structure

```
npk_sensor_dashboard
├── lib
│   ├── main.dart
│   ├── app.dart
│   ├── config
│   │   ├── constants.dart
│   │   ├── routes.dart
│   │   └── themes.dart
│   ├── models
│   │   ├── npk_reading.dart
│   │   ├── sensor_data.dart
│   │   └── user_settings.dart
│   ├── screens
│   │   ├── home_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── history_screen.dart
│   │   ├── settings_screen.dart
│   │   └── sensor_details_screen.dart
│   ├── services
│   │   ├── api_service.dart
│   │   ├── sensor_service.dart
│   │   └── local_storage_service.dart
│   ├── utils
│   │   ├── date_formatter.dart
│   │   └── validators.dart
│   └── widgets
│       ├── common
│       │   ├── app_bar.dart
│       │   ├── drawer.dart
│       │   └── loading_indicator.dart
│       ├── charts
│       │   ├── line_chart.dart
│       │   └── trend_chart.dart
│       ├── cards
│       │   ├── info_card.dart
│       │   └── sensor_card.dart
│       └── gauges
│           ├── circular_gauge.dart
│           └── nutrient_level_gauge.dart
├── assets
│   ├── fonts
│   ├── images
│   └── icons
├── pubspec.yaml
└── README.md
```

## Getting Started

To run this project, ensure you have Flutter installed on your machine. Follow these steps:

1. Clone the repository:
   ```
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```
   cd npk_sensor_dashboard
   ```
3. Install the dependencies:
   ```
   flutter pub get
   ```
4. Run the application:
   ```
   flutter run
   ```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.