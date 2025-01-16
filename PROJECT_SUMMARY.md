# Project Summary: Focus Timer

This project is a focus timer application built using GTK and C. It provides a simple GUI with the following features:

*   **Timer Input:** Allows the user to input a duration in seconds using a text entry field.
*   **Start/Stop Button:** A button to start and stop the timer.
*   **Timer Label:** Displays the remaining time.
*   **Beep Sound:** Plays a beep sound when the timer reaches zero.
*   **Volume Control:** A slider to control the volume of the beep sound.
*   **Error Handling:** Displays error messages for invalid time inputs.
*   **Configuration:** Uses constants for default timer duration, min/max timer values, window size, and update interval.
*   **CSS Styling:** Applies basic CSS styling to the widgets.
*   **Icon:** Sets an application icon.

## Key Components:

*   **`focus_timer.c`:** Contains the main application logic, including:
    *   **`main` function:** Initializes the GTK application and starts the main loop.
    *   **`activate` function:** Creates the main window and its widgets.
    *   **`toggle_timer` function:** Starts and stops the timer based on user input.
    *   **`timer_tick` function:** Decrements the remaining time and updates the label.
    *   **`play_beep` function:** Generates and plays a beep sound.
    *   **`update_label` function:** Updates the timer label with the remaining time.
    *   **`validate_time_input` function:** Validates the user's time input.
    *   **`setup_css` function:** Loads and applies CSS styling.
    *   **`cleanup` function:** Frees resources.
    *   **`show_error_dialog` function:** Displays error messages.

## Overall Structure:

The code is structured as a single C file, using GTK for the GUI and ALSA for audio. It uses a global `App` struct to store the application's state. The code is relatively straightforward, but could benefit from some refactoring and improvements, such as using a pre-recorded sound file instead of generating a sine wave.
