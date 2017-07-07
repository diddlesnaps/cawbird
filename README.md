# Corebird Snap Package

[![Snap Status](https://build.snapcraft.io/badge/diddledan/corebird-snap.svg)](https://build.snapcraft.io/user/diddledan/corebird-snap)

## Installing

If you haven't used the Snappy system before, you first need to ensure it is
installed correctly.

```bash
sudo apt install snapd snapd-xdg-open
```

If you have snapd already, you still need to ensure that `snapd-xdg-open` is
installed via APT until the upstream bug is fixed and the functionality rolled
into snapd directly.

Once you have snapd running, you just need to issue:

```bash
sudo snap install corebird
```
## Running

You can either run from the commandline by calling one of the following two
commands:

```bash
/snap/bin/corebird
```

OR

```bash
snap run corebird
```

Alternatively Corebird should appear in your desktop environment's menu or
dash.
