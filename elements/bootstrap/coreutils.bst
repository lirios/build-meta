kind: autotools
description: GNU coreutils

depends:
- filename: bootstrap/coreutils-build-deps.bst
  type: build
- filename: bootstrap/acl.bst
  type: runtime

(@):
- elements/bootstrap/include/target.yml
- elements/bootstrap/include/coreutils-source.yml

environment:
  FORCE_UNSAFE_CONFIGURE: "1"

variables:
  conf-local: >-
    --enable-install-program=hostname,arch
    --enable-no-install-program=kill,uptime,groups
    --enable-acl

  make-install: make -j1 install DESTDIR="%{install-root}" INSTALL=install

config:
  build-commands:
    (<):
    - |
      mkdir -p "%{builddir}/man"
      cp /coreutils-manpages/man1/* "%{builddir}/man/"

  install-commands:
    (>):
    - |
      rm "%{install-root}%{infodir}/dir"

sources:
  (>):
  - kind: patch
    path: patches/coreutils/coreutils-no-man-deps.patch
