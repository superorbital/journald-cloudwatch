# Systemd Journald Cloud Watch Log Forwarder

Debian package to forward journald to cloud watch.  Heavily borrowed (stolen) from the [juxt/rock](https://github.com/juxt/rock/tree/master/share/journald-cloud-watch-script) project and made into a Debian/Ubuntu package.

### Todo:

* [ ] Write service file
* [ ] Use `fpm` to create `.deb` packages
* [ ] Automate tagging and uploading releases
* [ ] Document instance tagging requirements
* [ ] Make instance tagging optional
* [ ] Update to latest code

### Open questions:

Seems you need to be root to run `journalctl` and see all entries.  Would be good to figure out how to run as a regular user.
