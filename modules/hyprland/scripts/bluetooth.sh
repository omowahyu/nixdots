#!/usr/bin/env bash
#             __ _       _     _            _              _   _
#  _ __ ___  / _(_)     | |__ | |_   _  ___| |_ ___   ___ | |_| |__
# | '__/ _ \| |_| |_____| '_ \| | | | |/ _ \ __/ _ \ / _ \| __| '_ \
# | | | (_) |  _| |_____| |_) | | |_| |  __/ || (_) | (_) | |_| | | |
# |_|  \___/|_| |_|     |_.__/|_|\__,_|\___|\__\___/ \___/ \__|_| |_|

# Author: Nick Clyde (clydedroid)
# A script that generates a rofi menu that uses bluetoothctl to
# connect to bluetooth devices and display status info.

# Depends on:
#   rofi, bluez-utils (bluetoothctl), bc

# Constants
divider="---------"
goback="Back"

# Checks if bluetooth controller is powered on
power_on() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        return 0
    else
        return 1
    fi
}

# Toggles power state
toggle_power() {
    if power_on; then
        bluetoothctl power off
        show_menu
    else
        if rfkill list bluetooth | grep -q 'blocked: yes'; then
            rfkill unblock bluetooth && sleep 3
        fi
        bluetoothctl power on
        show_menu
    fi
}

# Checks if controller is scanning for new devices
scan_on() {
    if bluetoothctl show | grep -q "Discovering: yes"; then
        echo "Scan: on"
        return 0
    else
        echo "Scan: off"
        return 1
    fi
}

# Toggles scanning state
toggle_scan() {
    if scan_on; then
        kill $(pgrep -f "bluetoothctl --timeout 5 scan on")
        bluetoothctl scan off
        show_menu
    else
        bluetoothctl --timeout 5 scan on &
        echo "Scanning..."
        sleep 5
        show_menu
    fi
}

# Checks if controller is discoverable
discoverable_on() {
    if bluetoothctl show | grep -q "Discoverable: yes"; then
        echo "Discoverable: on"
        return 0
    else
        echo "Discoverable: off"
        return 1
    fi
}

# Toggles discoverable state
toggle_discoverable() {
    if discoverable_on; then
        bluetoothctl discoverable off
        show_menu
    else
        bluetoothctl discoverable on
        show_menu
    fi
}

# Checks if controller is pairable
pairable_on() {
    if bluetoothctl show | grep -q "Pairable: yes"; then
        echo "Pairable: on"
        return 0
    else
        echo "Pairable: off"
        return 1
    fi
}

# Toggles pairable state
toggle_pairable() {
    if pairable_on; then
        bluetoothctl pairable off
        show_menu
    else
        bluetoothctl pairable on
        show_menu
    fi
}

# Checks if a device is connected
device_connected() {
    device_info=$(bluetoothctl info "$1")
    if echo "$device_info" | grep -q "Connected: yes"; then
        return 0
    else
        return 1
    fi
}

# Toggles device connection
toggle_connection() {
    if device_connected "$1"; then
        bluetoothctl disconnect "$1"
        show_menu
    else
        bluetoothctl connect "$1"
        show_menu
    fi
}

# Prints a short string with the current bluetooth status
print_status() {
    if power_on; then
        printf ''

        paired_devices_cmd="devices Paired"
        mapfile -t paired_devices < <(bluetoothctl $paired_devices_cmd | grep Device | cut -d ' ' -f 2)
        connected_devices=0
        for device in "${paired_devices[@]}"; do
            if device_connected "$device"; then
                ((connected_devices++))
            fi
        done

        if [[ $connected_devices -gt 0 ]]; then
            printf " %s" "$connected_devices"
        fi
    else
        echo ""
    fi
}

# A submenu for a specific device that allows connecting, pairing, trusting, and blocking
device_menu() {
    device=$1

    # Get device name and mac address
    mac=$(echo "$device" | cut -d ' ' -f 2)
    name=$(echo "$device" | cut -d ' ' -f 3-)

    # Get connection status
    if device_connected "$mac"; then
        connected="Connected: yes"
    else
        connected="Connected: no"
    fi

    # Get paired status
    if bluetoothctl info "$mac" | grep -q "Paired: yes"; then
        paired="Paired: yes"
    else
        paired="Paired: no"
    fi

    # Get trusted status
    if bluetoothctl info "$mac" | grep -q "Trusted: yes"; then
        trusted="Trusted: yes"
    else
        trusted="Trusted: no"
    fi

    # Get blocked status
    if bluetoothctl info "$mac" | grep -q "Blocked: yes"; then
        blocked="Blocked: yes"
    else
        blocked="Blocked: no"
    fi

    # Build options
    if device_connected "$mac"; then
        connect="Disconnect"
    else
        connect="Connect"
    fi

    if bluetoothctl info "$mac" | grep -q "Paired: yes"; then
        pair="Unpair"
    else
        pair="Pair"
    fi

    if bluetoothctl info "$mac" | grep -q "Trusted: yes"; then
        trust="Untrust"
    else
        trust="Trust"
    fi

    if bluetoothctl info "$mac" | grep -q "Blocked: yes"; then
        block="Unblock"
    else
        block="Block"
    fi

    # Open rofi menu
    options="$connect\n$pair\n$trust\n$block\n$divider\n$goback"
    chosen="$(echo -e "$options" | $rofi_command "Bluetooth device: $name")"

    # Match chosen option
    case "$chosen" in
        "" | "$divider")
            echo "No option chosen."
            ;;
        "$connect")
            toggle_connection "$mac"
            ;;
        "$pair")
            if bluetoothctl info "$mac" | grep -q "Paired: yes"; then
                bluetoothctl remove "$mac"
                show_menu
            else
                bluetoothctl pair "$mac"
                show_menu
            fi
            ;;
        "$trust")
            if bluetoothctl info "$mac" | grep -q "Trusted: yes"; then
                bluetoothctl untrust "$mac"
                show_menu
            else
                bluetoothctl trust "$mac"
                show_menu
            fi
            ;;
        "$block")
            if bluetoothctl info "$mac" | grep -q "Blocked: yes"; then
                bluetoothctl unblock "$mac"
                show_menu
            else
                bluetoothctl block "$mac"
                show_menu
            fi
            ;;
        "$goback")
            show_menu
            ;;
    esac
}

# Opens a rofi menu with current bluetooth status and options
show_menu() {
    # Get power status
    if power_on; then
        power="Power: on"
    else
        power="Power: off"
    fi

    # Get scan status
    scan=$(scan_on)

    # Get discoverable status
    discoverable=$(discoverable_on)

    # Get pairable status
    pairable=$(pairable_on)

    # Get paired devices
    paired_devices_cmd="devices Paired"
    mapfile -t paired_devices < <(bluetoothctl $paired_devices_cmd | grep Device | cut -d ' ' -f 2)
    devices=""
    for device in "${paired_devices[@]}"; do
        device_info=$(bluetoothctl info "$device")
        name=$(echo "$device_info" | grep "Name: " | cut -d ' ' -f 2-)
        if device_connected "$device"; then
            devices="$devices$divider\n$name (connected)"
        else
            devices="$devices$divider\n$name"
        fi
    done

    # Build options
    options="$power\n$scan\n$discoverable\n$pairable$devices\n$divider"

    # Open rofi menu
    rofi_command="rofi -dmenu -i -p 'Bluetooth'"
    chosen="$(echo -e "$options" | $rofi_command)"

    # Match chosen option to command
    case "$chosen" in
        "" | "$divider")
            echo "No option chosen."
            ;;
        "$power")
            toggle_power
            ;;
        "$scan")
            toggle_scan
            ;;
        "$discoverable")
            toggle_discoverable
            ;;
        "$pairable")
            toggle_pairable
            ;;
        *)
            device=$(bluetoothctl devices | grep "$chosen")
            if [[ $device ]]; then device_menu "$device"; fi
            ;;
    esac
}

# Rofi command to pipe into, can add any options here
rofi_command="rofi -dmenu $* -p"

case "$1" in
    --status)
        print_status
        ;;
    *)
        show_menu
        ;;
esac
