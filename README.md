# Focus Timer <img src="./assets/icons/focus_timer.png" alt="Logo" style="width: 30px; height: auto;">

A simple GTK-based focus timer application with sound notification.

![Screenshot](./assets/images/Screenshot_2025-01-19_11-05-17.png)

## Features
- Simple and clean GTK3 interface
- Customizable timer duration
- Audio notification when timer completes
- Automatic timer restart
- Time display in minutes:seconds format
- Volume control slider to adjust audio notification volume

## Dependencies

The Focus Timer application requires the following libraries:

- **GTK 3**: For the graphical user interface.
- **ALSA**: For audio playback.

## Installation

### Automatic Installation (Recommended)
To install the Focus Timer, run the following command:

./install.sh

- This script will:Install required dependencies and Compile the program.
- Testing Sound System
  The installation script includes a test for the sound system. Ensure that your audio is working correctly.

## Running the Application 
After installation, you can run the Focus Timer using:

./focus_timer

## Debian Package
To create a `.deb` package for easy installation and distribution on Debian-based systems (like Ubuntu):

1.  Run the build script:
    ```bash
    ./build_deb.sh
    ```
2.  Install the generated package:
    ```bash
    sudo dpkg -i focus-timer_0.16.0_amd64.deb
    ```

## Uninstallation
If you installed via the source script, use:
./uninstall.sh

If you installed via the `.deb` package, use:
```bash
sudo apt remove focus-timer
```

## Usage
Adjust the timer duration in seconds.
Use the volume control slider to set the desired notification volume.
Click "Start" to begin the timer.

## Cloning and Building

To clone and build the project, follow these steps:

1.  Clone the repository:
    ```bash
    git clone [repository URL]
    cd focus-timer
    ```
2.  Run the install script:
    ```bash
    ./install.sh
    ```
3.  Run the application:
    ```bash
    ./focus_timer
    ```

## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

For the full license text, see the [LICENSE](LICENSE) file or visit [https://www.gnu.org/licenses/gpl-3.0.html](https://www.gnu.org/licenses/gpl-3.0.html).
