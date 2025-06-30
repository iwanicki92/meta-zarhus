do_install:append() {
  # set hardware watchdog timeout to 15 seconds
  sed -e  's/.*RuntimeWatchdogSec=.*/RuntimeWatchdogSec=15/' -i ${D}${sysconfdir}/systemd/system.conf
}
