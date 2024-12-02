# Focus Timer

A simple GTK-based focus timer application with sound notification.

## Features

- Simple and clean GTK3 interface
- Customizable timer duration
- Audio notification when timer completes
- Automatic timer restart
- Time display in minutes:seconds format

## Installation

### Automatic Installation (Recommended)
```bash
./install.sh
```
This script will:
1. Detect your Linux distribution
2. Install required dependencies
3. Compile the program
4. Test the sound system

### Manual Installation

If you prefer to install manually, you'll need these dependencies:

#### Ubuntu/Debian
```bash
sudo apt-get install libgtk-3-dev libasound2-dev build-essential
```

#### Fedora
```bash
sudo dnf install gtk3-devel alsa-lib-devel gcc
```

#### Arch Linux
```bash
sudo pacman -S gtk3 alsa-lib base-devel
```

#### openSUSE
```bash
sudo zypper install gtk3-devel alsa-devel gcc
```

Then compile manually:
```bash
gcc -o focus_timer focus_timer.c $(pkg-config --cflags --libs gtk+-3.0) -lasound -lm
```

## Usage

1. Run the compiled program:
   ```bash
   ./focus_timer
   ```
2. Enter the desired duration in seconds (1-3600)
3. Click "Start" to begin the timer
4. Timer will beep when time is up and automatically restart

## Troubleshooting

If you don't hear the sound:
1. Check if ALSA is properly configured:
   ```bash
   alsamixer
   ```
2. Make sure your sound is not muted
3. Try running this command to test ALSA:
   ```bash
   speaker-test -t sine -f 1000 -l 1
   ```

## License

MIT License
