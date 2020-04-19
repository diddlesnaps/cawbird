local snapcraft = import 'snapcraft.libsonnet';

local alsa = import 'https://raw.githubusercontent.com/diddlesnaps/snapcraft-alsa/master/alsa.libsonnet';

local gtk_theming = import 'https://raw.githubusercontent.com/diddlesnaps/snapcraft-utils-library/master/lib/wayland-gtk-theming.libsonnet';
local gtk_locales = import 'https://raw.githubusercontent.com/diddlesnaps/snapcraft-utils-library/master/lib/gtk-locales.libsonnet';
local cleanup = import 'https://raw.githubusercontent.com/diddlesnaps/snapcraft-utils-library/master/lib/cleanup.libsonnet';

snapcraft {
    name: "cawbird",
    base: "core18",
    grade: "stable",
    confinement: "strict",
    "adopt-info": "cawbird",

    summary: "Cawbird Twitter Client (Corebird fork)",
    description: |||
        Cawbird is a modern and lightweight Twitter client for the GNOME 3 desktop. It
        features inline image and video preview, creation of lists and favorites,
        filtering of tweets and full text search. Cawbird is able to manage multiple
        Twitter accounts.

        Cawbird is a fork of Corebird, which became unsupported after Twitter disabled
        the streaming API. Cawbird works with the new APIs and includes a few fixes
        and modifications that have historically been patched in to IBBoard's custom
        Corebird build on his personal Open Build Service account[1].

        Due to changes in the Twitter API[2], Cawbird has the following limitations:

        - Cawbird will update every two minutes
        - Cawbird does not get notified of the following, which will be refreshed on restart:
            - Unfavourite
            - Follow/Unfollow
            - Block/Unblock
            - Mute/Unmute
            - DM deletion
            - Some list changes

        All limitations are limitations imposed by Twitter and are not the fault of the
        Cawbird client.

        [1]: https://build.opensuse.org/project/show/home:IBBoard:desktop
        [2]: https://developer.twitter.com/en/docs/accounts-and-users/subscribe-account-activity/migration/introduction
    |||,

    slots: {
        "dbus-cawbird": {
            interface: "dbus",
            bus: "session",
            name: "uk.co.ibboard.cawbird",
        }
    },

    layout: {
        "/etc/ld.so.cache": {
            "bind-file": "$SNAP_DATA/etc/ld.so.cache",
        },
        "/usr/lib/$SNAPCRAFT_ARCH_TRIPLET/gstreamer-1.0": {
            bind: "$SNAP/usr/lib/$SNAPCRAFT_ARCH_TRIPLET/gstreamer-1.0",
        }
    },

    environment: {
        FINAL_BINARY: "$SNAP/usr/bin/cawbird",
        LD_LIBRARY_PATH: "$LD_LIBRARY_PATH:$SNAP/gnome-platform/usr/lib/$SNAPCRAFT_ARCH_TRIPLET/alsa-lib",
    },

    apps: {
        cawbird: {
            extensions: ["gnome-3-28"],
            command: "bin/check-ld-cache $SNAP/usr/bin/cawbird",
            desktop: "usr/share/applications/cawbird.desktop",
            "common-id": "uk.co.ibboard.cawbird.desktop",
            plugs: [
                "audio-playback",
                "desktop",
                "desktop-legacy",
                "gsettings",
                "home",
                "network",
                "opengl",
                "pulseaudio",
                "unity7",
                "wayland",
                "x11",
            ],
        },
    },

    parts: {
        "scripts": {
            plugin: "dump",
            source: "scripts",
            organize: {
                "build-ld-cache": "bin/build-ld-cache",
                "check-ld-cache": "bin/check-ld-cache",
            },
        },

        cawbird: {
            "parse-info": ["usr/share/metainfo/uk.co.ibboard.cawbird.appdata.xml"],
            plugin: "meson",
            source: "https://github.com/ibboard/cawbird.git",
            "meson-parameters": [
                "-Dprefix=/usr",
            ],
            "override-pull": |||
                snapcraftctl pull

                git checkout "$(git describe --tags --abbrev=0 --match 'v*')"
                snapcraftctl set-version "$(git describe --tags | sed -e 's|^v||')"

                sed -i 's|^Icon=.*|Icon=/usr/share/icons/hicolor/scalable/apps/uk.co.ibboard.cawbird.svg|' data/uk.co.ibboard.cawbird.desktop.in
            |||,
            "build-packages": [
                "gettext",
                "libasound2-dev",
                "libgstreamer-plugins-bad1.0-dev",
                "libgstreamer-plugins-good1.0-dev",
                "libgspell-1-dev",
                "libgstreamer1.0-dev",
                "libjson-glib-dev",
                "libsoup2.4-dev",
                "libsqlite3-dev",
                "libxml2-utils",
                "locales-all",
                "valac",
            ],
            "stage-packages": [
                "gstreamer1.0-gtk3",
                "gstreamer1.0-libav",
                "gstreamer1.0-plugins-bad",
                "gstreamer1.0-plugins-base",
                "gstreamer1.0-plugins-good",
                "gstreamer1.0-pulseaudio",
                "gstreamer1.0-tools",
                "gstreamer1.0-vaapi",
                "libgstreamer1.0-0",
            ],
        },
    },
}
+ gtk_theming()
+ gtk_locales()
+ alsa()
+ cleanup(["gtk-common-themes", "gnome-3-28-1804"])
