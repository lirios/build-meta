kind: filter

build-depends:
- components/dbus-base.bst

runtime-depends:
- components/expat.bst
- components/systemd-libs.bst
- components/dbus-manifest.bst

config:
  include:
  - dbus-libs
  include-orphans: false

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libdbus-1.so'
        - '%{libdir}/dbus-1.0/include'
        - '%{libdir}/dbus-1.0/include/**'
