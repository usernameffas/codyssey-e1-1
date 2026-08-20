#!/usr/bin/env bash
# macOS용 최소 환경 준비 스크립트
# 개인 Mac 또는 관리자 권한이 있는 Mac용입니다.
# 관리자 권한이 없는 공용·교육장 Mac에서는 setup_shared_mac.sh를 사용하세요.
# 필요한 것: Homebrew, Git, OrbStack
set -Eeuo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "[ERROR] 이 스크립트는 macOS용입니다."
  exit 1
fi

# Homebrew가 없으면 공식 설치 스크립트로 설치합니다.
if ! command -v brew >/dev/null 2>&1; then
  echo "[INFO] Homebrew가 없어 설치합니다."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Apple Silicon과 Intel Mac의 대표 Homebrew 경로를 모두 확인합니다.
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# Git 설치/업데이트
if ! command -v git >/dev/null 2>&1; then
  brew install git
fi

# OrbStack이 설치되어 있지 않으면 설치합니다.
if [[ ! -d "/Applications/OrbStack.app" ]]; then
  brew install --cask orbstack
fi

# OrbStack 앱을 실행합니다.
open -a OrbStack

echo "[INFO] OrbStack 시작을 기다립니다."
for _ in {1..30}; do
  if docker info >/dev/null 2>&1; then
    echo "[OK] Docker Engine 연결 성공"
    docker --version
    git --version
    exit 0
  fi
  sleep 2
done

echo "[ERROR] 60초 안에 Docker Engine이 준비되지 않았습니다."
echo "OrbStack 앱 화면에서 실행 상태를 확인한 뒤 다시 실행하세요."
exit 1
