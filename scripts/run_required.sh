#!/usr/bin/env bash
# Codyssey E1-1 필수 항목 자동 실행 스크립트
# macOS + OrbStack + Ubuntu 24.04 환경 기준
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG_DIR="$ROOT_DIR/docs/logs"
WORK_DIR="$ROOT_DIR/.practice"
mkdir -p "$LOG_DIR" "$WORK_DIR"

log_run() {
  local log_file="$1"; shift
  {
    echo
    printf '$ '
    printf '%q ' "$@"
    echo
    "$@"
  } 2>&1 | tee -a "$log_file"
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[ERROR] '$1' 명령을 찾을 수 없습니다. 먼저 scripts/setup_mac.sh 를 실행하세요." >&2
    exit 1
  fi
}

require_command git
require_command docker
require_command curl

# OrbStack/Docker Engine이 실제로 실행 중인지 확인합니다.
if ! docker info >/dev/null 2>&1; then
  echo "[ERROR] Docker Engine에 연결할 수 없습니다. OrbStack 앱을 먼저 실행하세요." >&2
  exit 1
fi

# 이전 실행 잔여 컨테이너가 있으면 안전하게 정리합니다.
for name in e1-web e1-bind e1-volume-1 e1-volume-2 e1-ubuntu; do
  docker rm -f "$name" >/dev/null 2>&1 || true
done

echo "[1/8] 실행 환경 기록"
ENV_LOG="$LOG_DIR/01-environment.log"
: > "$ENV_LOG"
log_run "$ENV_LOG" sw_vers
log_run "$ENV_LOG" uname -a
log_run "$ENV_LOG" sh -c 'echo "$SHELL"'
log_run "$ENV_LOG" git --version
log_run "$ENV_LOG" docker --version
log_run "$ENV_LOG" docker info

echo "[2/8] 터미널 기본 조작 기록"
TERM_LOG="$LOG_DIR/02-terminal.log"
: > "$TERM_LOG"
rm -rf "$WORK_DIR/terminal"
mkdir -p "$WORK_DIR/terminal"
cd "$WORK_DIR/terminal"
log_run "$TERM_LOG" pwd
log_run "$TERM_LOG" ls -la
log_run "$TERM_LOG" mkdir demo-dir
log_run "$TERM_LOG" touch empty.txt
log_run "$TERM_LOG" sh -c 'echo "hello terminal" > note.txt'
log_run "$TERM_LOG" cat note.txt
log_run "$TERM_LOG" cp note.txt note-copy.txt
log_run "$TERM_LOG" mv note-copy.txt renamed.txt
log_run "$TERM_LOG" mv renamed.txt demo-dir/renamed.txt
log_run "$TERM_LOG" ls -la
log_run "$TERM_LOG" ls -la demo-dir
log_run "$TERM_LOG" rm demo-dir/renamed.txt
log_run "$TERM_LOG" rmdir demo-dir
cd "$ROOT_DIR"

echo "[3/8] Ubuntu 24.04 권한 실습"
PERM_LOG="$LOG_DIR/03-permissions.log"
: > "$PERM_LOG"
log_run "$PERM_LOG" docker run --name e1-ubuntu ubuntu:24.04 bash -lc \
  'mkdir -p /practice/sample-dir; touch /practice/sample.txt; echo before; ls -ld /practice/sample.txt /practice/sample-dir; chmod 600 /practice/sample.txt; chmod 700 /practice/sample-dir; echo after; ls -ld /practice/sample.txt /practice/sample-dir'
docker rm -f e1-ubuntu >/dev/null

echo "[4/8] Docker 기본 명령 + hello-world"
DOCKER_LOG="$LOG_DIR/04-docker-basic.log"
: > "$DOCKER_LOG"
log_run "$DOCKER_LOG" docker run --rm hello-world
log_run "$DOCKER_LOG" docker pull nginx:alpine
log_run "$DOCKER_LOG" docker images
log_run "$DOCKER_LOG" docker ps
log_run "$DOCKER_LOG" docker ps -a

echo "[5/8] Dockerfile 빌드 + 포트 매핑"
WEB_LOG="$LOG_DIR/05-web-and-port.log"
: > "$WEB_LOG"
cd "$ROOT_DIR"
log_run "$WEB_LOG" docker build -t codyssey-e1-1-web:1.0 .
log_run "$WEB_LOG" docker run -d --name e1-web -p 8080:80 codyssey-e1-1-web:1.0
sleep 1
log_run "$WEB_LOG" curl -fsS http://localhost:8080
log_run "$WEB_LOG" docker logs e1-web
log_run "$WEB_LOG" docker stats --no-stream e1-web

echo "[6/8] 바인드 마운트(bind mount) 반영 확인"
BIND_LOG="$LOG_DIR/06-bind-mount.log"
: > "$BIND_LOG"
log_run "$BIND_LOG" docker run -d --name e1-bind -p 8081:80 -v "$ROOT_DIR/site:/usr/share/nginx/html:ro" nginx:alpine
sleep 1
log_run "$BIND_LOG" curl -fsS http://localhost:8081
printf '<!doctype html><meta charset="utf-8"><h1>Bind Mount Updated</h1>\n' > "$ROOT_DIR/site/bind-proof.html"
log_run "$BIND_LOG" curl -fsS http://localhost:8081/bind-proof.html

echo "[7/8] Named Volume(이름 있는 볼륨) 영속성 확인"
VOL_LOG="$LOG_DIR/07-volume.log"
: > "$VOL_LOG"
docker volume rm e1-data >/dev/null 2>&1 || true
log_run "$VOL_LOG" docker volume create e1-data
log_run "$VOL_LOG" docker run --name e1-volume-1 -v e1-data:/data ubuntu:24.04 bash -lc 'echo persistent-data > /data/proof.txt && cat /data/proof.txt'
log_run "$VOL_LOG" docker rm e1-volume-1
log_run "$VOL_LOG" docker run --name e1-volume-2 -v e1-data:/data ubuntu:24.04 cat /data/proof.txt
log_run "$VOL_LOG" docker rm e1-volume-2

echo "[8/8] Git/GitHub 설정 기록"
GIT_LOG="$LOG_DIR/08-git.log"
: > "$GIT_LOG"
log_run "$GIT_LOG" git config --list
log_run "$GIT_LOG" git remote -v || true
log_run "$GIT_LOG" git status

# 컨테이너는 증거 확인 후에도 PC 자원을 잡지 않도록 종료합니다.
docker rm -f e1-web e1-bind >/dev/null 2>&1 || true

echo
echo "완료: 필수 실습 로그가 docs/logs/ 에 저장되었습니다."
echo "남은 수동 증거: 브라우저에서 localhost:8080 접속 화면과 VSCode GitHub 로그인 화면을 캡처하세요."
