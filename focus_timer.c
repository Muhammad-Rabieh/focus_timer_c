/*
 * Focus Timer - A simple GTK-based timer application
 * Copyright (C) 2024 Muhammad Rabieh
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#include <gtk/gtk.h>
#include <stdio.h>
#include <stdlib.h>
#include <alsa/asoundlib.h>
#include <math.h>
#include <gdk-pixbuf/gdk-pixbuf.h>

// Configuration constants
#define SAMPLE_RATE 44100
#define DURATION_MS 100
#define FREQUENCY 1000
#define DEFAULT_TIMER_SECONDS 30
#define MIN_TIMER_SECONDS 1
#define MAX_TIMER_SECONDS 3600
#define WINDOW_WIDTH 300
#define WINDOW_HEIGHT 200
#define UPDATE_INTERVAL_MS 1000

typedef struct {
    GtkWidget *window;
    GtkWidget *entry;
    GtkWidget *label;
    GtkWidget *button;
    GtkWidget *volume_slider;
    guint timer_id;
    int remaining_time;
    gboolean is_running;
    GtkCssProvider *css_provider;
} App;

static App app = {0};  // Zero-initialize all members

// Function declarations
static void show_error_dialog(const char *message);
static void play_beep(void);
static void update_label(void);
static int validate_time_input(const char *text);
static gboolean timer_tick(gpointer data);
static void toggle_timer(GtkWidget *widget, gpointer data);
static void setup_css(void);
static void cleanup(void);
static void activate(GtkApplication *app_gtk, gpointer user_data);

// Function implementations
static void show_error_dialog(const char *message) {
    GtkWidget *dialog = gtk_message_dialog_new(GTK_WINDOW(app.window),
                                             GTK_DIALOG_DESTROY_WITH_PARENT,
                                             GTK_MESSAGE_ERROR,
                                             GTK_BUTTONS_CLOSE,
                                             "Error: %s", message);
    gtk_dialog_run(GTK_DIALOG(dialog));
    gtk_widget_destroy(dialog);
}

static void play_beep(void) {
    snd_pcm_t *handle;
    int err;
    
    if ((err = snd_pcm_open(&handle, "default", SND_PCM_STREAM_PLAYBACK, 0)) < 0) {
        g_warning("Cannot open audio device: %s\n", snd_strerror(err));
        return;
    }

    err = snd_pcm_set_params(handle,
                            SND_PCM_FORMAT_S16_LE,
                            SND_PCM_ACCESS_RW_INTERLEAVED,
                            1,  // mono
                            SAMPLE_RATE,
                            1,  // allow resampling
                            500000);  // 0.5s latency
    
    if (err < 0) {
        g_warning("Cannot set audio parameters: %s\n", snd_strerror(err));
        snd_pcm_close(handle);
        return;
    }

    // Generate samples
    int samples = (SAMPLE_RATE * DURATION_MS) / 1000;
    short *buffer = g_malloc(samples * sizeof(short));
    
    if (!buffer) {
        g_warning("Cannot allocate memory for audio buffer\n");
        snd_pcm_close(handle);
        return;
    }

    // Get volume from slider
    int volume = gtk_range_get_value(GTK_RANGE(app.volume_slider));
    double volume_factor = (double)volume / 100.0;

    // Generate sine wave
    for (int i = 0; i < samples; i++) {
        double t = (double)i / SAMPLE_RATE;
        buffer[i] = (short)(32767.0 * sin(2.0 * M_PI * FREQUENCY * t) * volume_factor);
    }
    
    // Play sound
    if ((err = snd_pcm_writei(handle, buffer, samples)) < 0) {
        g_warning("Write error: %s\n", snd_strerror(err));
    }
    
    // Cleanup
    g_free(buffer);
    snd_pcm_drain(handle);
    snd_pcm_close(handle);
}

static void update_label(void) {
    char text[64];
    int minutes = app.remaining_time / 60;
    int seconds = app.remaining_time % 60;
    
    if (minutes > 0) {
        snprintf(text, sizeof(text), "Time remaining: %d:%02d", minutes, seconds);
    } else {
        snprintf(text, sizeof(text), "Time remaining: %d seconds", seconds);
    }
    gtk_label_set_text(GTK_LABEL(app.label), text);
}

static int validate_time_input(const char *text) {
    char *endptr;
    long value = strtol(text, &endptr, 10);
    
    // Check for conversion errors
    if (*endptr != '\0' || value < MIN_TIMER_SECONDS || value > MAX_TIMER_SECONDS) {
        char error_msg[128];
        snprintf(error_msg, sizeof(error_msg), 
                "Please enter a number between %d and %d seconds",
                MIN_TIMER_SECONDS, MAX_TIMER_SECONDS);
        show_error_dialog(error_msg);
        return DEFAULT_TIMER_SECONDS;
    }
    
    return (int)value;
}

static gboolean timer_tick(gpointer data) {
    if (app.remaining_time > 0) {
        app.remaining_time--;
        update_label();
    } else {
        play_beep();
        // Get duration from entry
        const char *text = gtk_entry_get_text(GTK_ENTRY(app.entry));
        app.remaining_time = validate_time_input(text);
        update_label();
    }
    return G_SOURCE_CONTINUE;
}

static void toggle_timer(GtkWidget *widget, gpointer data) {
    if (app.is_running) {
        // Stop timer
        if (app.timer_id > 0) {
            g_source_remove(app.timer_id);
            app.timer_id = 0;
        }
        gtk_button_set_label(GTK_BUTTON(app.button), "Start");
        app.is_running = FALSE;
    } else {
        // Start timer
        const char *text = gtk_entry_get_text(GTK_ENTRY(app.entry));
        app.remaining_time = validate_time_input(text);
        app.timer_id = g_timeout_add(UPDATE_INTERVAL_MS, timer_tick, NULL);
        gtk_button_set_label(GTK_BUTTON(app.button), "Stop");
        app.is_running = TRUE;
        update_label();
    }
}

static void setup_css(void) {
    app.css_provider = gtk_css_provider_new();
    const char *css =
        "entry { font-size: 14px; padding: 5px; }"
        "label { font-size: 16px; padding: 5px; }"
        "button { font-size: 14px; padding: 8px 16px; }"
        "scale { padding: 5px; }";
    
    gtk_css_provider_load_from_data(app.css_provider, css, -1, NULL);
    gtk_style_context_add_provider_for_screen(gdk_screen_get_default(),
                                            GTK_STYLE_PROVIDER(app.css_provider),
                                            GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
}

static void cleanup(void) {
    if (app.css_provider) {
        g_object_unref(app.css_provider);
    }
    if (app.timer_id > 0) {
        g_source_remove(app.timer_id);
    }
}

static void activate(GtkApplication *app_gtk, gpointer user_data) {
    // Create window
    app.window = gtk_application_window_new(app_gtk);
    gtk_window_set_title(GTK_WINDOW(app.window), "Focus Timer");
    
    // Load the application icon
    GError *error = NULL;
    GdkPixbuf *icon = gdk_pixbuf_new_from_file("assets/icons/alarm-clock.png", &error);
    if (error != NULL) {
        g_print("Error loading icon: %s\n", error->message);
        g_error_free(error);
    } else {
        gtk_window_set_icon(GTK_WINDOW(app.window), icon);
        g_object_unref(icon);
    }
    
    gtk_window_set_default_size(GTK_WINDOW(app.window), WINDOW_WIDTH, WINDOW_HEIGHT);
    gtk_container_set_border_width(GTK_CONTAINER(app.window), 10);
    
    // Create a vertical box with spacing
    GtkWidget *box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 10);
    gtk_container_add(GTK_CONTAINER(app.window), box);
    
    // Create duration entry
    app.entry = gtk_entry_new();
    char default_value[16];
    snprintf(default_value, sizeof(default_value), "%d", DEFAULT_TIMER_SECONDS);
    gtk_entry_set_text(GTK_ENTRY(app.entry), default_value);
    gtk_entry_set_placeholder_text(GTK_ENTRY(app.entry), "Enter duration in seconds");
    gtk_box_pack_start(GTK_BOX(box), app.entry, FALSE, FALSE, 0);
    
    // Create timer label
    app.label = gtk_label_new(NULL);
    update_label();
    gtk_box_pack_start(GTK_BOX(box), app.label, FALSE, FALSE, 0);
    
    // Create volume slider
    app.volume_slider = gtk_scale_new_with_range(GTK_ORIENTATION_HORIZONTAL, 0, 100, 1);
    gtk_scale_set_value_pos(GTK_SCALE(app.volume_slider), GTK_POS_RIGHT);
    gtk_box_pack_start(GTK_BOX(box), app.volume_slider, FALSE, FALSE, 0);
    gtk_widget_set_valign(app.volume_slider, GTK_ALIGN_CENTER);
    gtk_widget_show(app.volume_slider);
    
    // Create start/stop button
    app.button = gtk_button_new_with_label("Start");
    g_signal_connect(app.button, "clicked", G_CALLBACK(toggle_timer), NULL);
    gtk_box_pack_start(GTK_BOX(box), app.button, FALSE, FALSE, 0);
    
    // Apply CSS styling
    setup_css();
    
    gtk_widget_show_all(app.window);
}

int main(int argc, char *argv[]) {
    GtkApplication *app_gtk;
    int status;
    
    app_gtk = gtk_application_new("org.gtk.focus_timer", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app_gtk, "activate", G_CALLBACK(activate), NULL);
    
    status = g_application_run(G_APPLICATION(app_gtk), argc, argv);
    
    cleanup();
    g_object_unref(app_gtk);
    
    return status;
}
