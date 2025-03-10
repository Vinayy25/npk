Below is a step-by-step guide based on the flutter-pi documentation that will help you set up your Raspberry Pi to run Flutter apps. This guide covers installing the necessary dependencies, building flutter-pi, configuring the Pi, and finally building & running your Flutter app.

---

## 1. Install the Dependencies

Before building flutter-pi, install all required system libraries and tools. Open a terminal on your Raspberry Pi and run:

```bash
sudo apt update
sudo apt install cmake libgl1-mesa-dev libgles2-mesa-dev libegl1-mesa-dev libdrm-dev libgbm-dev ttf-mscorefonts-installer fontconfig libsystemd-dev libinput-dev libudev-dev libxkbcommon-dev
```

> If you plan on using the gstreamer video player (for video support in your Flutter app), install these as well:
>
> ```bash
> sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-alsa
> ```

After installing, update the system fonts cache:

```bash
sudo fc-cache
```

> citeturn0search4

---

## 2. Build flutter-pi

### Clone the Repository

Clone the flutter-pi repository along with its submodules:

```bash
git clone --recursive https://github.com/ardera/flutter-pi
cd flutter-pi
```

### Compile flutter-pi

Create a build directory and compile the source:

```bash
mkdir build && cd build
cmake ..
make -j$(nproc)
```

After compilation, install flutter-pi with:

```bash
sudo make install
```

> citeturn0search4

---

## 3. Configure Your Raspberry Pi

### Adjust Boot and Graphics Settings

1. **Open raspi-config:**

   ```bash
   sudo raspi-config
   ```

2. **Switch to Console Mode:**  
   Under **System Options → Boot / Auto Login**, choose either **Console** or **Console (Autologin)**. (This can be skipped on Raspberry Pi 4 with Raspbian Bullseye.)

3. **Enable the V3D Graphics Driver:**  
   Go to **Advanced Options → GL Driver** and select **GL (Fake KMS)**.

4. **Set GPU Memory:**  
   Under **Performance Options → GPU Memory**, set the memory to **64 MB**.

5. **Add Your User to the Render Group:**  
   This grants permission for 3D acceleration (note that it has potential security implications):
   
   ```bash
   sudo usermod -a -G render pi
   ```

6. **Reboot the Raspberry Pi:**

   ```bash
   sudo reboot
   ```

> citeturn0search4

---

## 4. Build and Deploy Your Flutter App

Flutter apps for flutter-pi need to be built on your development machine (not on the Raspberry Pi). Follow these steps:

### One-Time Setup on Your Development Machine

- **Install Flutter SDK:**  
  Make sure you’re running Flutter SDK version >= 3.10.5.
  
- **Install flutterpi_tool:**  
  Run the following command once to install the tool that simplifies building and deploying apps:
  
  ```bash
  flutter pub global activate flutterpi_tool
  ```

  If the tool is not recognized, add the Dart global bin directory to your PATH or run it via:
  
  ```bash
  flutter pub global run flutterpi_tool build --help
  ```

### Building the App Bundle

1. **Navigate to Your Flutter App Directory:**

   ```bash
   cd path/to/your/flutter/app
   flutter pub get
   ```

2. **Build the App Bundle for Raspberry Pi:**  
   For example, to build a release mode app for a Raspberry Pi 4 (ARM64):

   ```bash
   flutterpi_tool build --arch=arm64 --cpu=pi4 --release
   ```

   This command generates an asset bundle (a folder containing `kernel_blob.bin` and other Flutter assets).

### Deploying to Your Raspberry Pi

Use a tool like `rsync` or `scp` to copy the generated `flutter_assets` folder to your Raspberry Pi. For example, using `rsync`:

```bash
rsync -a --info=progress2 ./build/flutter_assets/ pi@<your_pi_ip>:/home/pi/my_flutter_app
```

> citeturn0search4

---

## 5. Run Your Flutter App with flutter-pi

On your Raspberry Pi, run your Flutter app using flutter-pi. For example, if your asset bundle is located at `/home/pi/my_flutter_app`, launch it with:

```bash
flutter-pi --release /home/pi/my_flutter_app
```

You can also pass additional options such as orientation or video mode if needed. Check the help options by running:

```bash
flutter-pi --help
```

> citeturn0search4

---

## Additional Considerations

- **GStreamer and Audio:**  
  If your Flutter app uses video or audio, ensure that you have the necessary GStreamer packages installed and configured (see the dependency section above). For audio with the `audioplayers` plugin, consider removing pulseaudio if you face issues.

- **Performance and Troubleshooting:**  
  The flutter-pi project is designed for constrained systems like the Raspberry Pi. Ensure your hardware (e.g., Pi 3 or 4) meets the requirements and check the [flutter-pi GitHub repository](https://github.com/ardera/flutter-pi) for known issues and updates.

- **Development Tips:**  
  - Develop your Flutter UI on your main machine and build the asset bundle using `flutterpi_tool`.
  - Use hot reload (where applicable) during development to streamline the UI creation process.

By following these steps, you’ll be able to configure your Raspberry Pi to run Flutter apps using flutter-pi. This setup bypasses the need for a full desktop environment, enabling you to run Flutter apps directly from the command line. Happy coding!

> citeturn0search4
>
> 
to setup startup script
nano ~/.bashrc 


to enter no profile mode bypassing bashrc

ssh pi@192.168.96.171 -t "bash --noprofile --norc"