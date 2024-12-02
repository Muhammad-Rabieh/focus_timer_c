# Focus Timer

A simple GTK-based focus timer application with sound notification.

## Features

- Simple and clean GTK3 interface
- Customizable timer duration
- Audio notification when timer completes
- Automatic timer restart
- Time display in minutes:seconds format

## Dependencies

- GTK 3 (libgtk-3-dev)
- ALSA (libasound2-dev)

## Building

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

## License

MIT License
