local snapcraft = import 'snapcraft.libsonnet';

local gtk_locales = import 'https://raw.githubusercontent.com/diddlesnaps/snapcraft-utils-library/master/lib/gtk-locales.libsonnet';
local cleanup = import 'https://raw.githubusercontent.com/diddlesnaps/snapcraft-utils-library/master/lib/cleanup.libsonnet';

snapcraft {
    name: "cawbird",
    base: "core22",
    grade: "stable",
    confinement: "strict",
    compression: "lzo",
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

    architectures: [
        {"build-on": "amd64"},
        {"build-on": "armhf"},
        {"build-on": "arm64"},
    ],

    slots: {
        "dbus-cawbird": {
            interface: "dbus",
            bus: "session",
            name: "uk.co.ibboard.cawbird",
        }
    },

    layout: {
        "/usr/lib/$SNAPCRAFT_ARCH_TRIPLET/gstreamer-1.0": {
            bind: "$SNAP/usr/lib/$SNAPCRAFT_ARCH_TRIPLET/gstreamer-1.0",
        }
    },

    environment: {
        GSETTINGS_SCHEMA_DIR: "$SNAP/usr/share/glib-2.0/schemas",
        GTK_USE_PORTAL: "0",
    },

    apps: {
        cawbird: {
            extensions: ["gnome"],
            command: "usr/bin/cawbird",
            desktop: "usr/share/applications/uk.co.ibboard.cawbird.desktop",
            "common-id": "uk.co.ibboard.cawbird.desktop",
            plugs: [
                "audio-playback",
                "gsettings",
                "home",
                "network",
                "network-manager-observe",
            ],
        },
    },

    parts: {
        cawbird: {
            "parse-info": ["usr/share/metainfo/uk.co.ibboard.cawbird.appdata.xml"],
            plugin: "meson",
            source: "https://github.com/ibboard/cawbird.git",
            "build-environment": [
                { CFLAGS: "-Ofast -g -pipe" },
                { CXXFLAGS: "-Ofast -g -pipe" },
            ],
            "meson-parameters": [
                "-Dbuildtype=release",
                "-Dprefix=/usr",
                "-Db_lto=true",
                "-Db_pie=true",
                "-Dconsumer_key_base64=VmY5dG9yRFcyWk93MzJEZmhVdEk5Y3NMOA==",
                "-Dconsumer_secret_base64=MThCRXIxbWRESDQ2Y0podzVtVU13SGUyVGlCRXhPb3BFRHhGYlB6ZkpybG5GdXZaSjI=",
            ],
            "override-pull": |||
                craftctl default

                git checkout "$(git describe --tags --abbrev=0 --exclude '*-flatpak' --match 'v*')"
                craftctl set version="$(git describe --tags | sed -e 's|^v||')"

                sed -i 's|^Icon=.*|Icon=/usr/share/icons/hicolor/scalable/apps/uk.co.ibboard.cawbird.svg|' data/uk.co.ibboard.cawbird.desktop.in
            |||,
            "build-packages": [
                "gettext",
                "libgstreamer1.0-dev",
                "libgstreamer-plugins-bad1.0-dev",
                "libgstreamer-plugins-base1.0-dev",
                "libgstreamer-plugins-good1.0-dev",
                "liboauth-dev",
                "valac",
            ],
            "stage-packages": [
                "freeglut3",
                "gstreamer1.0-gtk3",
                "gstreamer1.0-libav",
                "gstreamer1.0-plugins-bad",
                "gstreamer1.0-plugins-base",
                "gstreamer1.0-plugins-good",
                "gstreamer1.0-plugins-ugly",
                "gstreamer1.0-pulseaudio",
                "gstreamer1.0-tools",
                "gstreamer1.0-vaapi",
                "libglu1-mesa",
                "libgstreamer-plugins-bad1.0-0",
                "libgstreamer-plugins-base1.0-0",
                "libgstreamer-plugins-good1.0-0",
                "liboauth0",
            ],
            stage: [
                "-usr/lib/$SNAPCRAFT_ARCH_TRIPLET/libharfbuzz*",
            ],
        },
    },
}
+ cleanup(["gtk-common-themes", "gnome-42-2204"])
