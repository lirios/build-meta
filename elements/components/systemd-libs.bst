kind: filter

build-depends:
- components/systemd-base.bst

runtime-depends:
- bootstrap-import.bst
- components/libcap.bst
- components/libgcrypt.bst
- components/util-linux.bst
- components/systemd-manifest.bst
- components/lz4.bst

config:
  include:
  - systemd-libs

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libsystemd.so'
        - '%{libdir}/libudev.so'
