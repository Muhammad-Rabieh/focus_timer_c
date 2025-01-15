# Focus Timer - Complete Documentation

## Project Overview
The Focus Timer is a GTK-based application designed to help users manage their time effectively by providing a customizable timer with audio notifications. It is particularly useful for techniques like the Pomodoro Technique, where users work for a set period followed by a short break.

## Quick Start Guide
1. Install the application:
   ```bash
   ./install.sh
   ```
2. Run the application:
   ```bash
   ./focus_timer
   ```

## Features
- Simple and clean GTK3 interface
- Customizable timer duration
- Audio notification when timer completes
- Automatic timer restart
- Time display in minutes:seconds format
- Volume control slider to adjust audio notification volume

## Dependencies
The Focus Timer application requires the following libraries:
- **GTK 3**: For the graphical user interface
- **ALSA**: For audio playback

## Technical Documentation

### Architecture Overview
The application is built using C and follows a simple, modular architecture:
1. GUI Layer (GTK3)
2. Timer Logic
3. Audio System (ALSA)

### Code Structure
The codebase is organized into the following components:

#### Main Source File (focus_timer.c)
1. **Main Function**:
   - Entry point of the application
   - Initializes GTK application
   - Sets up the application window
   - Connects to the activate function

2. **Activate Function**:
   - Creates the main window
   - Sets up GUI elements:
     - Timer input field
     - Start/Stop button
     - Volume control slider
   - Arranges elements using GTK containers
   - Connects signal handlers

3. **Timer Logic**:
   - Implements countdown mechanism
   - Handles timer start/stop/reset
   - Updates display
   - Triggers notifications

4. **Audio System**:
   - Manages sound notifications
   - Controls volume levels
   - Handles audio playback errors

### Key Components Detail

#### GUI Elements
- **Main Window**: Contains all UI elements
- **Input Field**: Accepts timer duration in seconds
- **Control Button**: Toggles timer state
- **Volume Slider**: Adjusts notification volume
- **Timer Display**: Shows remaining time

#### Timer Implementation
- Uses GTK's timer functionality
- Updates display every second
- Handles user input validation
- Manages timer state (running/stopped)

#### Audio System
- Utilizes ALSA for sound playback
- Implements volume control
- Handles audio device errors
- Manages sound resources

### Installation Process
The installation script (install.sh) performs the following:
1. Checks system requirements
2. Installs necessary dependencies
3. Compiles the application
4. Tests the sound system

### Error Handling
The application implements error handling for:
- Invalid user input
- Audio system failures
- Resource allocation issues
- Timer-related errors

## Development Guide

### Building from Source
1. Ensure all dependencies are installed
2. Run the installation script
3. Verify the compilation
4. Test the application

### Contributing
To contribute to the project:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

### Testing
- Test timer functionality
- Verify audio playback
- Check volume control
- Validate user input handling

## Troubleshooting
Common issues and solutions:
1. **No Sound**:
   - Check system volume
   - Verify ALSA configuration
   - Test sound system

2. **Compilation Errors**:
   - Verify dependencies
   - Check compiler version
   - Review error messages

## License
This project is licensed under the MIT License. See the LICENSE file for details.
