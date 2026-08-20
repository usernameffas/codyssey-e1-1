#!/usr/bin/env bash
# 관리자 권한이 없는 공용·교육장 Mac용 환경 확인 스크립트
# Homebrew, Git, OrbStack을 설치하지 않고 기존 환경만 확인합니다.
set -Eeuo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "[ERROR] 이 스크립트는 macOS용입니다."
  exit 1
fi

echo "[INFO] 공용 Mac 환경을 확인합니다."
echo "[INFO] 이 스크립트는 프로그램을 새로 설치하거나 관리자 권한을 요구하지 않습니다."

# Git은 과제 저장소를 사용하기 위해 이미 설치되어 있어야 합니다.
if ! command -v git >/dev/null 2>&1; then
  echo "[ERROR] Git을 찾을 수 없습니다."
  echo "공용 Mac 관리자 또는 교육 운영자에게 Git 설치를 요청하세요."
  exit 1
fi

# OrbStack이 있을 수 있는 대표적인 위치를 순서대로 확인합니다.
ORBSTACK_APP=""
for candidate in   "/Applications/OrbStack.app"   "$HOME/Applications/OrbStack.app"   "$HOME/Desktop/OrbStack.app"
do
  if [[ -d "$candidate" ]]; then
    ORBSTACK_APP="$candidate"
    break
  fi
done

if [[ -z "$ORBSTACK_APP" ]]; then
  echo "[ERROR] OrbStack 앱을 찾을 수 없습니다."
  echo "확인한 위치:"
  echo "  - /Applications/OrbStack.app"
  echo "  - $HOME/Applications/OrbStack.app"
  echo "  - $HOME/Desktop/OrbStack.app"
  echo "공용 Mac에서는 임의 설치를 진행하지 말고 관리자 또는 교육 운영자에게 문의하세요."
  exit 1
fi

echo "[OK] OrbStack 발견: $ORBSTACK_APP"
open "$ORBSTACK_APP"

echo "[INFO] Docker Engine 시작을 최대 60초 동안 기다립니다."
for _ in {1..30}; do
  if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    echo "[OK] Docker Engine 연결 성공"
    docker --version
    git --version
    exit 0
  fi
  sleep 2
done

echo "[ERROR] 60초 안에 Docker Engine에 연결하지 못했습니다."
echo "다른 사용자 소유 OrbStack 프로세스가 남아 있거나 공용 PC 권한이 충돌할 수 있습니다."
echo "다음 명령으로 OrbStack 프로세스 소유자를 확인할 수 있습니다:"
echo "  ps aux | grep -i orb"
echo "다른 사용자 프로세스라면 임의로 종료하지 말고 관리자 조치, 재부팅 또는 다른 PC 사용이 필요합니다."
exit 1
