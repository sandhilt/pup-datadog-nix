# AGENTS.md — Instruções para atualização do flake

Este arquivo descreve como atualizar o `flake.nix` quando uma nova versão do `pup` for lançada.

## Passos para atualizar

### 1. Descobrir a versão mais recente

```bash
curl -s https://api.github.com/repos/DataDog/pup/releases/latest | jq -r '.tag_name'
```

### 2. Baixar o arquivo de checksums da nova versão

Substituir `<VERSION>` pelo número sem o `v` (ex: `1.2.1`):

```bash
curl -sL https://github.com/DataDog/pup/releases/download/v<VERSION>/pup_<VERSION>_checksums.txt
```

### 3. Converter os hashes SHA256 para o formato SRI

O Nix usa hashes no formato SRI (`sha256-<base64>`). Para cada plataforma:

```bash
nix hash convert --hash-algo sha256 --from base16 --to base64 <HEX_HASH>
# Prefixar o resultado com "sha256-"
```

Plataformas relevantes e seus arquivos no checksums:

| Sistema Nix       | Arquivo no release              |
|-------------------|---------------------------------|
| `x86_64-linux`    | `pup_<VERSION>_Linux_x86_64.tar.gz`  |
| `aarch64-linux`   | `pup_<VERSION>_Linux_arm64.tar.gz`   |
| `x86_64-darwin`   | `pup_<VERSION>_Darwin_x86_64.tar.gz` |
| `aarch64-darwin`  | `pup_<VERSION>_Darwin_arm64.tar.gz`  |

### 4. Editar o `flake.nix`

Atualizar os seguintes campos em `flake.nix`:

- `version`: novo número de versão (sem o `v`)
- `srcs.<sistema>.url`: nova URL com a nova versão
- `srcs.<sistema>.hash`: novo hash SRI para cada plataforma

As URLs seguem o padrão:
```
https://github.com/DataDog/pup/releases/download/v${version}/pup_${version}_<OS>_<ARCH>.tar.gz
```

### 5. Atualizar o `flake.lock`

```bash
nix flake update
```

### 6. Verificar

```bash
git add flake.nix flake.lock
nix flake check
nix build
./result/bin/pup --version  # deve mostrar a nova versão
```

### 7. Atualizar o README.md

Alterar a linha "Versão atual" no `README.md` para refletir a nova versão.

## Exemplo de script de atualização

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION=$(curl -s https://api.github.com/repos/DataDog/pup/releases/latest | jq -r '.tag_name | ltrimstr("v")')
echo "Nova versão: $VERSION"

CHECKSUMS=$(curl -sL "https://github.com/DataDog/pup/releases/download/v${VERSION}/pup_${VERSION}_checksums.txt")

for pair in "x86_64-linux:Linux_x86_64" "aarch64-linux:Linux_arm64" "x86_64-darwin:Darwin_x86_64" "aarch64-darwin:Darwin_arm64"; do
  nix_system="${pair%%:*}"
  asset_suffix="${pair##*:}"
  hex=$(echo "$CHECKSUMS" | grep "pup_${VERSION}_${asset_suffix}.tar.gz$" | awk '{print $1}')
  sri="sha256-$(nix hash convert --hash-algo sha256 --from base16 --to base64 "$hex")"
  echo "$nix_system: $sri"
done
```

Execute o script, copie os hashes gerados para o `flake.nix` e siga os passos 5–7.
