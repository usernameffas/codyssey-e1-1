# E1-1 내 컴퓨터에 개발자용 작업실 꾸미기

이 저장소는 **필수 과제만** 수행합니다. Bonus(보너스)는 포함하지 않습니다.

## 1. 목표

- CLI(Command Line Interface, 명령줄 인터페이스): 터미널 명령 사용
- Docker: 컨테이너(Container, 격리 실행 환경) 실행
- Dockerfile: Docker Image(이미지)를 만드는 설명서 작성
- Port Mapping(포트 매핑): Mac의 포트와 컨테이너의 포트 연결
- Bind Mount(바인드 마운트): Mac 폴더를 컨테이너 폴더에 직접 연결
- Volume(볼륨): 컨테이너를 삭제해도 데이터 유지
- Git/GitHub: 로컬 버전 관리와 원격 저장소 연결

## 2. 실행 환경

- Host OS(호스트 운영체제): macOS
- Container Engine(컨테이너 엔진): OrbStack
- Linux Container: Ubuntu 24.04
- Shell(쉘): zsh 또는 bash

실제 버전은 자동 스크립트가 `docs/logs/01-environment.log`에 기록합니다.

## 3. 가장 빠른 실행 순서

저장소를 Mac에 clone(복제)한 뒤 실행합니다.

```bash
git clone https://github.com/usernameffas/codyssey-e1-1.git
cd codyssey-e1-1
chmod +x scripts/*.sh
./scripts/setup_mac.sh
./scripts/run_required.sh
```

`setup_mac.sh`는 필요한 최소 환경을 확인하고 OrbStack을 실행합니다.
`run_required.sh`는 미션 필수 실습을 순서대로 실행하고 로그를 `docs/logs/`에 저장합니다.

## 4. 수행 체크리스트

- [x] 터미널 기본 조작
- [x] 파일/디렉터리 권한 변경
- [x] Docker 버전 및 Engine 동작 확인
- [x] `hello-world` 실행
- [x] Ubuntu 24.04 컨테이너 실행
- [x] Docker 이미지/컨테이너/로그/리소스 확인
- [x] Dockerfile 기반 웹 서버 이미지 빌드
- [x] Port Mapping(포트 매핑) 접속 확인
- [x] Bind Mount(바인드 마운트) 변경 반영 확인
- [x] Named Volume(이름 있는 볼륨) 영속성 확인
- [x] Git 설정/원격 저장소 상태 기록
- [x] 브라우저 주소창이 보이는 접속 화면 캡처
- [x] VSCode GitHub 로그인/연동 화면 캡처

마지막 두 항목은 GUI(Graphical User Interface, 화면 인터페이스) 증거라 자동화할 수 없으므로 직접 캡처합니다.

## 5. 자동 생성 로그

| 파일 | 확인 내용 |
|---|---|
| `docs/logs/01-environment.log` | macOS, Shell, Git, Docker 정보 |
| `docs/logs/02-terminal.log` | pwd, ls, mkdir, touch, cp, mv, rm 등 |
| `docs/logs/03-permissions.log` | Ubuntu 24.04에서 파일/폴더 권한 변경 전후 |
| `docs/logs/04-docker-basic.log` | hello-world, image, container 목록 |
| `docs/logs/04b-container-exec-attach.log` | 컨테이너 exec/attach 관찰 내용 |
| `docs/logs/05-web-and-port.log` | Docker build/run, curl, logs, stats |
| `docs/logs/06-bind-mount.log` | Host 파일 변경이 컨테이너에 반영되는지 확인 |
| `docs/logs/07-volume.log` | 컨테이너 삭제 뒤에도 데이터가 남는지 확인 |
| `docs/logs/08-git.log` | Git 설정, remote, status |

## 6. 핵심 용어 쉽게 설명

### CLI
CLI = Command Line Interface. 마우스 대신 글자로 명령하는 방식입니다.

### Image와 Container
- Image(이미지): 컨테이너를 만들기 위한 실행 환경의 설계도
- Container(컨테이너): 이미지를 실제로 실행한 인스턴스

흐름은 `Dockerfile -> build -> Image -> run -> Container`입니다.

### Port Mapping

```text
Mac localhost:8080  --->  Container:80
```

명령 예:

```bash
docker run -d --name e1-web -p 8080:80 codyssey-e1-1-web:1.0
```

`-p 8080:80`에서 앞은 Mac의 Host Port(호스트 포트), 뒤는 컨테이너 내부 포트입니다.
컨테이너는 호스트와 분리된 네트워크 환경에서 동작하므로, Mac 브라우저에서 컨테이너의 웹 서버에 접근하려면 이런 포트 연결이 필요합니다.

### Bind Mount
Mac의 실제 폴더를 컨테이너에 연결합니다. Mac 파일을 바꾸면 컨테이너에서도 바로 바뀝니다.

```bash
docker run -d -p 8081:80 \
  -v "$PWD/site:/usr/share/nginx/html:ro" \
  nginx:alpine
```

### Volume
Docker가 관리하는 저장 공간입니다. 컨테이너를 삭제해도 Volume을 삭제하지 않으면 데이터가 남습니다.
이번 실습에서는 `e1-data` 볼륨에 `persistent-data`를 저장한 뒤 첫 컨테이너를 삭제하고, 새 컨테이너에 같은 볼륨을 연결하여 데이터가 그대로 남아 있음을 확인했습니다.

## 7. Dockerfile 설명

```dockerfile
FROM nginx:alpine
COPY site/ /usr/share/nginx/html/
EXPOSE 80
```

- `FROM`: 어떤 Base Image(기본 이미지)를 사용할지 지정
- `COPY`: 내 파일을 이미지 안으로 복사
- `EXPOSE`: 웹 서버가 사용하는 포트가 80임을 문서화

이 미션에서는 NGINX 기반 방식 한 가지를 선택하여 커스텀 이미지를 빌드했습니다.

## 8. 직접 다시 검증하는 명령

```bash
docker build -t codyssey-e1-1-web:1.0 .
docker run -d --name e1-web -p 8080:80 codyssey-e1-1-web:1.0
curl http://localhost:8080
docker logs e1-web
docker stats --no-stream e1-web
docker rm -f e1-web
```

## 9. 권한(permission) 설명

Linux 권한은 `r`, `w`, `x`로 표현합니다.

- r = read(읽기) = 4
- w = write(쓰기) = 2
- x = execute(실행) = 1

예:

- `644` = owner(소유자) `rw-`, group `r--`, others `r--`
- `755` = owner `rwx`, group `r-x`, others `r-x`

이 저장소에서는 Ubuntu 24.04 컨테이너 안에서 파일과 디렉터리의 권한을 실제 변경하고 변경 전후를 확인했습니다.

## 10. 프로젝트 디렉터리 구조와 기준

```text
codyssey-e1-1/
├── Dockerfile
├── README.md
├── site/                  # 웹 서버가 제공할 HTML 파일
├── scripts/               # 환경 설정 및 필수 실습 자동화 스크립트
└── docs/
    ├── logs/              # 명령과 실행 결과 기록
    └── screenshots/       # 브라우저·VSCode 화면 증거
```

파일의 역할을 기준으로 분리했습니다. 웹 콘텐츠는 `site/`, 반복 실행할 명령은 `scripts/`, 수행 결과는 `docs/logs/`, 화면 증거는 `docs/screenshots/`에 두어 다른 사람이 저장소를 보더라도 목적을 쉽게 파악하고 같은 실습을 재현할 수 있도록 했습니다.

## 11. 절대 경로와 상대 경로

- Absolute Path(절대 경로): 파일 시스템의 시작 위치부터 전체 경로를 적습니다. 예: `/Users/사용자이름/codyssey-e1-1/docs`
- Relative Path(상대 경로): 현재 작업 위치를 기준으로 적습니다. 예: `docs/screenshots`

위치를 확실하게 지정해야 할 때는 절대 경로가 편하고, 프로젝트 내부에서 현재 위치가 명확할 때는 상대 경로를 사용하면 경로가 짧고 다른 환경에서도 재사용하기 쉽습니다.

실습 중에는 `open ~/codyssey-e1-1/docs/screenshots`처럼 경로를 직접 지정해 Finder에서 증거 폴더를 열기도 했습니다.

## 12. Git과 GitHub 차이

- Git: 내 컴퓨터에서 변경 이력을 관리하는 Version Control System(VCS, 버전 관리 시스템)
- GitHub: Git 저장소를 인터넷에서 보관하고 공유하는 원격 플랫폼

이 미션에서는 저장소를 clone한 뒤 변경사항을 `git add`, `git commit`, `git push`로 GitHub의 `main` 브랜치에 반영했고, VSCode에서도 GitHub 계정 로그인을 확인했습니다.

확인:

```bash
git config --list
git remote -v
git status
```

## 13. 트러블슈팅

아래 내용은 실습 과정에서 실제로 겪은 문제와 해결 또는 우회 과정입니다.

### 문제 1: OrbStack 아키텍처 불일치

**현상**
- 다운로드한 OrbStack 아이콘에 금지 표시(🚫)가 나타났고 실행되지 않았습니다.

**원인 가설**
- Apple Silicon(arm64)용 OrbStack을 받았는데 실제 실습 장비는 Intel 기반일 가능성을 의심했습니다.

**확인**
- `사과 메뉴 > 이 Mac에 관하여`에서 Intel Core i5 장비임을 확인했습니다.

**해결**
- OrbStack 공식 사이트에서 Intel용(amd64) 빌드를 다시 다운로드했습니다.
- 다운로드한 파일명에 `amd64`가 포함되어 있는지 확인한 뒤 실행했습니다.

**배운 점**
- 같은 macOS라도 CPU 아키텍처가 Intel(amd64)인지 Apple Silicon(arm64)인지에 따라 맞는 프로그램 빌드를 선택해야 합니다.

### 문제 2: Applications 폴더 설치 시 관리자 암호 요구

**현상**
- OrbStack을 일반적인 macOS 설치 방식대로 Applications 폴더로 옮기려 하자 관리자 인증 창이 나타났습니다.

**원인 가설**
- 교육장 공용 Mac이라 관리자 또는 `sudo` 권한이 없었고, Applications 폴더가 시스템 전역에서 사용하는 위치이기 때문이라고 판단했습니다.

**확인**
- Finder에서 관리자 인증 창이 나타났으며, 관리자 암호 없이는 계속 진행할 수 없었습니다.

**해결/대안**
- OrbStack을 Applications 폴더에 넣지 않고 현재 사용자 권한으로 접근 가능한 Desktop에 두었습니다.
- Desktop에 있는 OrbStack 앱을 직접 실행하자 정상적으로 실행할 수 있었습니다.

**배운 점**
- macOS 앱은 반드시 Applications 폴더 안에 있어야만 실행되는 것은 아닙니다.
- 공용 장비에서는 시스템 전역 위치에 설치할 권한이 없을 수 있으므로 사용자 홈 영역처럼 권한이 있는 위치에서 실행하는 방법도 확인할 필요가 있습니다.

### 문제 3: OrbStack Helper 설치 시 관리자 암호 요구

**현상**
- OrbStack 초기 설정 중 Helper 설치 단계에서 다시 관리자 인증을 요구했습니다.

**원인 가설**
- Helper가 시스템 영역에 구성 요소를 설치하려 하기 때문에 공용 Mac의 관리자 권한 제한에 걸린 것으로 판단했습니다.

**확인**
- 해당 안내가 호환성 개선을 위한 항목이며 필수 설치 항목은 아니라는 점을 확인했습니다.

**해결/대안**
- Helper 설치는 취소하고 초기 설정을 계속 진행했습니다.
- 이후 `docker info`를 실행하여 Docker Engine이 정상 동작하는지 확인했습니다.

**배운 점**
- 설치 과정에서 권한을 요구하는 추가 구성 요소가 항상 핵심 기능의 필수 조건인 것은 아닙니다.
- 선택 항목인지 확인하고, 제한된 공용 환경에서는 필수 기능만으로 진행할 수 있는지 검증하는 것이 중요합니다.

### 문제 4: 셸이 `quote>` 상태에 갇힘

**현상**
- 터미널에서 명령어를 입력해도 실행되지 않고 `quote>` 프롬프트만 반복해서 나타났습니다.

**원인 가설**
- 따옴표가 열린 상태에서 닫히지 않아 셸이 문자열 입력이 끝나기를 계속 기다리는 상황으로 판단했습니다.
- 한글 입력 상태에서 명령을 입력하는 과정도 혼란을 키웠습니다.

**확인**
- 정상적인 `%` 프롬프트 대신 `quote>`가 표시되는 것을 확인했습니다.

**해결**
- `Control + C`를 눌러 현재 입력을 취소하고 정상 프롬프트로 돌아왔습니다.
- 이후 터미널 명령 입력 전 영문 입력 상태인지 확인했습니다.

**배운 점**
- 셸에서는 따옴표가 닫히지 않으면 명령을 실행하지 않고 추가 입력을 기다립니다.
- 입력이 잘못되어 프롬프트에서 빠져나오기 어려울 때 `Control + C`로 현재 명령을 취소할 수 있습니다.

### 문제 5: `docker --info` 실행 오류

**현상**
- Docker 상태를 확인하려고 `docker --info`를 입력했더니 `unknown flag: --info` 오류가 발생했습니다.

**원인 가설**
- `info`를 Docker의 옵션(option)처럼 `--`를 붙여 입력했지만 실제로는 하위 명령어(command)일 수 있다고 생각했습니다.

**확인**
- `docker --help`를 통해 Docker 명령어 체계를 확인했습니다.

**해결**
- `docker info`로 다시 실행했고 Docker Engine 정보를 정상적으로 확인했습니다.

**배운 점**
- `docker --version`처럼 `--`가 붙는 옵션도 있지만, `docker info`처럼 별도의 하위 명령어로 사용하는 명령도 있습니다.
- 오류가 발생하면 `--help`를 이용해 정확한 명령 형식을 확인할 수 있습니다.

### 문제 6: 다른 사용자 소유 OrbStack 프로세스가 남아 있어 제어되지 않음

**현상**
- OrbStack/Docker가 정상적으로 시작되지 않거나 제어되지 않았고 실행 과정에서 `operation not permitted` 오류가 발생했습니다.

**원인 가설**
- 처음에는 Docker 설치 또는 Docker Engine 자체의 문제라고 생각했습니다.

**확인**

```bash
ps aux | grep -i orb
```

프로세스 목록을 확인한 결과 현재 로그인한 사용자와 다른 사용자 소유의 OrbStack 관련 프로세스가 남아 있었습니다. 따라서 단순 설치 문제가 아니라 공유 PC에 남은 기존 프로세스의 소유권과 현재 사용자 권한이 충돌하는 문제로 판단했습니다.

**해결 시도 및 결과**
- 다른 사용자 소유 프로세스였기 때문에 현재 사용자 권한으로 해당 프로세스를 종료하거나 정리할 수 없었습니다.
- 시스템을 재부팅하면 상태를 초기화할 가능성이 있었지만 교육장 PC에서는 재부팅이 제한되어 있었습니다.
- 따라서 해당 PC에서는 문제를 완전히 해결하지 못했습니다.
- 최종적으로 다른 PC로 이동하여 OrbStack/Docker가 정상 동작하는 환경에서 실습을 계속했습니다.

**배운 점**
- 프로그램이 설치되어 있다는 것과 현재 사용자에게 정상적으로 실행·제어되고 있다는 것은 다른 문제입니다.
- 공유 PC에서는 이전 사용자의 프로세스가 남아 현재 사용자와 충돌할 수 있습니다.
- 프로세스 소유권 문제는 일반 사용자 권한만으로 해결할 수 없는 경우가 있으며, 관리자 조치나 재부팅이 불가능하면 정상적인 다른 환경으로 이동하는 것도 현실적인 대안입니다.

## 14. 포트와 볼륨을 재현 가능하게 만든 방법

포트 매핑과 볼륨 생성 명령을 README와 `scripts/run_required.sh`에 남겨 두어 같은 저장소를 clone한 사람이 다시 실행할 수 있도록 했습니다.

- 웹 서버: `8080:80`
- Bind Mount 확인용 웹 서버: `8081:80`
- Named Volume: `e1-data`

특히 Named Volume은 특정 Mac의 절대 경로를 데이터 저장 위치로 직접 지정하는 방식보다 Docker가 관리하는 이름으로 다시 연결할 수 있어, 컨테이너를 새로 만들어도 같은 데이터를 재사용하기 쉽습니다.

## 15. 제출 전 수동 캡처 2개

자동 스크립트가 끝난 뒤 아래를 직접 확인했습니다.

1. 웹 서버를 실행하고 브라우저 주소창과 화면을 함께 캡처
2. VSCode에서 GitHub 계정 로그인 + 이 저장소가 열린 화면 캡처

캡처에는 Token(토큰), Password(비밀번호), Private Key(개인키)를 노출하지 않습니다.

## 16. 실행 증거

### Port Mapping(포트 매핑) 브라우저 접속

아래 화면은 Docker 컨테이너의 80번 포트를 Mac의 8080번 포트에 연결한 뒤,
`http://localhost:8080`으로 정상 접속한 증거입니다.

![웹 서버 포트 매핑 접속 증거](docs/screenshots/web-port.png)

### VSCode + GitHub 연동

아래 화면은 VSCode에서 이 저장소를 열고 GitHub 계정으로 로그인한 상태를 보여줍니다.

![VSCode GitHub 연동 증거](docs/screenshots/vscode-github.png)
