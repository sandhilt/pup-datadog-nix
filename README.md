# pup-datadog-nix

Nix flake para instalar o [`pup`](https://github.com/DataDog/pup), a CLI oficial do Datadog.

## Plataformas suportadas

| Sistema         | Arquitetura |
|----------------|-------------|
| Linux          | x86_64, aarch64 |
| macOS (Darwin) | x86_64, aarch64 (Apple Silicon) |

## Uso

### Executar diretamente

```bash
nix run github:sandhilt/pup-datadog-nix
```

### Instalar com `nix profile`

```bash
nix profile install github:sandhilt/pup-datadog-nix
```

### NixOS / home-manager (via flake input)

```nix
# flake.nix
inputs.pup.url = "github:sandhilt/pup-datadog-nix";
```

```nix
# Em environment.systemPackages ou home.packages:
inputs.pup.packages.${system}.default
```

### Overlay

```nix
nixpkgs.overlays = [ inputs.pup.overlays.default ];

# Depois disponível como:
pkgs.pup
```

## Versão atual

`v1.2.2` — ver [releases do pup](https://github.com/DataDog/pup/releases).

## Atualizar para uma nova versão

Veja [AGENTS.md](./AGENTS.md) para instruções de atualização.
