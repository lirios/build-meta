kind: manual

depends:
- bootstrap-import.bst
- components/flatpak.bst

config:
  install-commands:
  - |
    install -Dm644 -t "%{install-root}%{indep-libdir}/systemd/system" add-flathub.service
    install -Dm644 -t "%{install-root}%{indep-libdir}/systemd/system-preset" add-flathub.preset

sources:
- kind: local
  path: files/vm/flathub-config
