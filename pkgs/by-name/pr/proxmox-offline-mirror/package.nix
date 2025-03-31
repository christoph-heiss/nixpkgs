{
  lib,
  fetchgit,
  rustPlatform,
  pkg-config,
  openssl,
  nettle,
}:

rustPlatform.buildRustPackage rec {
  pname = "proxmox-offline-mirror";
  version = "0.6.7";

  srcs = [
    (fetchgit {
      name = "proxmox";
      url = "git://git.proxmox.com/git/proxmox.git";
      rev = "da8fdea63287ae45bf7f2180bd365c8c4ccba2a3";
      hash = "sha256-2qjFw7HzS2V9sFZWPrdZ4RuScx935jvbpzTs0fl1EKI=";
    })
    (fetchgit {
      name = "proxmox-offline-mirror";
      url = "git://git.proxmox.com/git/proxmox-offline-mirror.git";
      rev = "a5f6a9c191d85e887442e8c0ce36df3a9deffeca";
      hash = "sha256-o3QJvhjqTv/vJziVBdmhpj8BHfZwrw4BxC78nhD9upM=";
    })
  ];

  sourceRoot = "proxmox-offline-mirror";

  patches = [
    ./0001-cargo-re-route-dependencies-not-available-on-crates..patch
  ];

  postPatch = ''
    rm -v .cargo/config.toml
    cp -v ${./Cargo.lock} Cargo.lock
  '';

  cargoLock.lockFile = ./Cargo.lock;

  cargoBuildFlags = [
    "--bin=proxmox-offline-mirror"
    "--bin=proxmox-offline-mirror-helper"
  ];

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl.dev
    nettle.dev
  ];

  meta = {
    description = "Proxmox offline repository mirror and subscription key manager";
    homepage = "https://pom.proxmox.com";
    changelog = "https://git.proxmox.com/?p=proxmox-offline-mirror.git;a=blob;f=debian/changelog";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ christoph-heiss ];
    platforms = lib.platforms.linux;
    mainProgram = "proxmox-offline-mirror";
  };
}
