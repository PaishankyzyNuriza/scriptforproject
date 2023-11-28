#!/bin/bash

# Set up inotifywait to monitor the /etc directory for events
inotifywait -m /etc -e create,delete,modify -o /tmp/etc_changes.log

# GPIO pin for the LED (replace with the actual pin number)
LED_PIN=17

# Initialize GPIO pin for the LED
echo $LED_PIN > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio$LED_PIN/direction

# Function to turn on the LED
function turn_on_led {
    echo "1" > /sys/class/gpio/gpio$LED_PIN/value
}

# Function to turn off the LED
function turn_off_led {
    echo "0" > /sys/class/gpio/gpio$LED_PIN/value
}

# Initial timestamp for the last check
last_check=0

# Check for changes and control the LED
while true; do
  if [[ -f /tmp/etc_changes.log ]]; then
    if [[ $(stat -c %Y /tmp/etc_changes.log) -gt $last_check ]]; then
      # LED on when changes are detected
      turn_on_led

      # Update the last check timestamp
      last_check=$(stat -c %Y /tmp/etc_changes.log)

      # Sleep for a moment to avoid rapid changes
      sleep 2

      # LED off after a short duration
      turn_off_led
    fi
  fi

  # Sleep for a second to avoid excessive CPU usage
  sleep 1
done
