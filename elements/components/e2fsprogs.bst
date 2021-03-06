kind: autotools

depends:
- filename: bootstrap-import.bst
- filename: public-stacks/buildsystem-autotools.bst
  type: build
- filename: components/util-linux.bst

variables:
  conf-local: |
    --enable-elf-shlibs \
    --disable-libblkid \
    --disable-libuuid \
    --disable-fsck \
    --disable-uuidd

  make-install: make -j1 DESTDIR="%{install-root}" install install-libs

config:
  install-commands:
    (>):
    - |
      rm "%{install-root}%{bindir}/dumpe2fs"
      ln -s e2mmpstatus "%{install-root}%{bindir}/dumpe2fs"

    - |
      rm "%{install-root}%{bindir}/e2label"
      ln -s tune2fs "%{install-root}%{bindir}/e2label"

    - |
      for ext in ext2 ext3 ext4; do
        rm "%{install-root}%{bindir}/mkfs.${ext}"
        ln -s mke2fs "%{install-root}%{bindir}/mkfs.${ext}"
      done

    - |
      for ext in ext2 ext3 ext4; do
        rm "%{install-root}%{bindir}/fsck.${ext}"
        ln -s e2fsck "%{install-root}%{bindir}/fsck.${ext}"
      done

    - |
      find "%{install-root}" -name "lib*.a" -exec rm {} ";"

public:
  bst:
    split-rules:
      devel:
        (>):
        - '%{libdir}/libss.so'
        - '%{libdir}/libcom_err.so'
        - '%{libdir}/libe2p.so'
        - '%{libdir}/libext2fs.so'
      vm-only:
      - '%{bindir}/*'

sources:
- kind: git_tag
  url: kernel:fs/ext2/e2fsprogs.git
  track: master
  ref: v1.45.6-0-g29d22c467547f11f4db31331549ee4e304eeb220
