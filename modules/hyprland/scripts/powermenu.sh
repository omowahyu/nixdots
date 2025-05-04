#!/bin/sh
options="Lock\nLogout\nSuspend\nHibernate\nReboot\nShutdown"
chosen=$(echo -e $options | rofi -dmenu -i -p "Power Menu")
case $chosen in
    Lock) slock ;;
    Logout) kill -9 -1 ;;
    Suspend) systemctl suspend ;;
    Hibernate) systemctl hibernate ;;
    Reboot) systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac
