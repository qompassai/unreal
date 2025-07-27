#!/usr/bin/env sh
# /qompassai/unreal/scripts/quickstart.sh
# Qompass AI Unreal Quickstart
# Copyright (C) 2025 Qompass AI, All rights reserved
####################################################
set -eu
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$OS" in
linux*)
	OS="linux"
	LOCAL="$HOME/.local"
	;;
darwin*)
	OS="macos"
	LOCAL="$HOME/.local"
	;;
msys* | mingw* | cygwin*)
	OS="windows"
	LOCAL="$USERPROFILE/.local"
	;;
*)
	echo "❌ Unsupported OS for this script."
	exit 1
	;;
esac
BIN="$LOCAL/bin"
mkdir -p "$BIN"
echo "╭─────────────────────────────────────────────╮"
echo "│   Qompass AI · Unreal Engine Quickstart     │"
echo "╰─────────────────────────────────────────────╯"
echo "  © 2025 Qompass AI. All rights reserved      "
echo
echo "Which Unreal Engine version do you want to set up?"
echo "  1) 5.6 (latest)"
echo "  2) 5.5"
echo "  3) 5.4"
echo "  4) Custom branch or tag"
echo "  q) Quit"
printf "Choose [1]: "
read -r verch
case "${verch:-1}" in
1 | "") UE_BRANCH="5.6" ;;
2) UE_BRANCH="5.5" ;;
3) UE_BRANCH="5.4" ;;
4)
	printf " Enter branch/tag: "
	read -r UE_BRANCH
	;;
q | Q) exit 0 ;;
*)
	echo "Invalid choice"
	exit 1
	;;
esac
UE_DIR="$LOCAL/UnrealEngine"
if [ ! -d "$UE_DIR" ]; then
	echo "==> Cloning Unreal Engine $UE_BRANCH into $UE_DIR ..."
	git clone -b "$UE_BRANCH" --single-branch "https://github.com/EpicGames/UnrealEngine.git" "$UE_DIR" ||
		git clone -b "$UE_BRANCH" --single-branch "git@github.com:EpicGames/UnrealEngine.git" "$UE_DIR"
else
	echo "==> Updating UE source for branch $UE_BRANCH ..."
	cd "$UE_DIR"
	git checkout "$UE_BRANCH"
	git fetch --all
fi
cd "$UE_DIR"
echo
echo "Pick platforms to build for (multi-select, e.g., 1 3 6)."
echo "  1) Linux (default)"
echo "  2) LinuxARM64"
echo "  3) Windows"
echo "  4) Mac"
echo "  5) Android"
echo "  6) iOS"
echo "  7) tvOS"
echo "  8) VisionOS"
echo "  a) All"
echo "  q) Quit"
printf "Which platform(s)? [1]: "
read -r plats
[ -z "${plats:-}" ] && plats="1"
[ "$plats" = "q" ] && exit 0
PLATFLAGS=""
PLATSDKS=""
for sel in $plats; do
	case "$sel" in
	1) PLATFLAGS="$PLATFLAGS Linux" ;;
	2) PLATFLAGS="$PLATFLAGS LinuxArm64" ;;
	3) PLATFLAGS="$PLATFLAGS Win64" ;;
	4) PLATFLAGS="$PLATFLAGS Mac" ;;
	5)
		PLATFLAGS="$PLATFLAGS Android"
		PLATSDKS="$PLATSDKS Android"
		;;
	6)
		PLATFLAGS="$PLATFLAGS IOS"
		PLATSDKS="$PLATSDKS IOS"
		;;
	7)
		PLATFLAGS="$PLATFLAGS TVOS"
		PLATSDKS="$PLATSDKS TVOS"
		;;
	8) PLATFLAGS="$PLATFLAGS VisionOS" ;;
	a | A)
		PLATFLAGS="Linux LinuxArm64 Win64 Mac Android IOS TVOS VisionOS"
		PLATSDKS="Android IOS TVOS"
		break
		;;
	*) ;;
	esac
done
echo
echo "Build system:"
echo "  1) Official Unreal Automation Tool (multi-platform, Installed Build) [default]"
echo "  2) Local developer Makefile build (for Linux devs, Editor only, fast)"
printf "Choose build system [1]: "
read -r buildsys
[ -z "$buildsys" ] && buildsys="1"
if [ "$buildsys" = "2" ]; then
	echo "==> Generating Makefiles for local developer build..."
	./GenerateProjectFiles.sh -makefiles
	echo
	echo "Makefile build menu:"
	echo "  1) Build Editor (default: Development)"
	echo "  2) Build Editor (Debug: much slower)"
	echo "  3) Build all essential tools (UnrealPak, ShaderCompileWorker, etc.)"
	echo "  4) Clean and full rebuild of Editor"
	echo "  5) Build UnrealGame"
	echo "  q) Quit"
	printf "Choose [1]: "
	read -r maketgt
	[ -z "$maketgt" ] && maketgt="1"
	case "$maketgt" in
	1 | "")
		echo "==> Building Unreal Editor (Development, StandardSet)..."
		make -j"$(nproc)" # "make" on its own builds the editor ("StandardSet")
		;;
	2)
		echo "==> Building Unreal Editor (Debug)..."
		make -j"$(nproc)" UnrealEditor-Linux-Debug
		;;
	3)
		echo "==> Building essential tools..."
		make -j"$(nproc)" CrashReportClient ShaderCompileWorker UnrealLightmass InterchangeWorker UnrealPak UnrealEditor
		;;
	4)
		echo "==> Cleaning and rebuilding the Editor..."
		make UnrealEditor ARGS="-clean" && make -j"$(nproc)" UnrealEditor
		;;
	5)
		echo "==> Building UnrealGame..."
		make -j"$(nproc)" UnrealGame
		;;
	q | Q)
		exit 0
		;;
	*)
		echo "Unknown choice, doing make (default)..."
		make -j"$(nproc)"
		;;
	esac
	if [ "$OS" = "linux" ]; then
		TOOLS="UnrealEditor UnrealPak ShaderCompileWorker CrashReportClient UnrealLightmass InterchangeWorker UnrealGame"
		TOOLROOT="$UE_DIR/Engine/Binaries/Linux"
		for tool in $TOOLS; do
			[ -f "$TOOLROOT/$tool" ] && ln -sf "$TOOLROOT/$tool" "$BIN/$tool" && echo "  → Symlinked $tool -> $BIN/$tool"
		done
		echo
		echo "==> Done. Run the editor with:"
		echo "cd $TOOLROOT"
		echo "./UnrealEditor"
		echo
		echo "To open a project:"
		echo "./UnrealEditor \"/path/to/YourProject.uproject\""
		echo
		echo "Append -game to run as a game, or see Unreal docs for more CLI options."
	else
		echo "Development makefile build is only implemented for Linux."
	fi
else
	echo
	echo "Choose configs (1 Development [default]   2 Debug   3 Test   4 Shipping   a All)"
	printf "Configs: "
	read -r buildconfs
	[ -z "${buildconfs:-}" ] && buildconfs="1"
	CONFVAL=""
	for sel in $buildconfs; do
		case "$sel" in
		1) CONFVAL="${CONFVAL}Development;" ;;
		2) CONFVAL="${CONFVAL}Debug;" ;;
		3) CONFVAL="${CONFVAL}Test;" ;;
		4) CONFVAL="${CONFVAL}Shipping;" ;;
		a | A)
			CONFVAL="Debug;Development;Test;Shipping"
			break
			;;
		*) ;;
		esac
	done
	CONFVAL=$(echo "$CONFVAL" | sed 's/;$//')
	echo "Enable extra build options:"
	echo "  1) Derived Data Cache (DDC)"
	echo "  2) CEF (Chromium Embedded Framework)"
	echo "  3) ISPC (Vectorization)"
	echo "  4) All"
	echo "  n) None [default]"
	printf "Features [n]: "
	read -r feat
	[ -z "$feat" ] && feat="n"
	WITH_DDC=false
	CEF3=false
	ISPC=false
	case "$feat" in
	4)
		WITH_DDC=true
		CEF3=true
		ISPC=true
		;;
	*)
		echo "$feat" | grep 1 >/dev/null && WITH_DDC=true
		echo "$feat" | grep 2 >/dev/null && CEF3=true
		echo "$feat" | grep 3 >/dev/null && ISPC=true
		;;
	esac
	echo "==> Updating submodules and prerequisites..."
	git submodule update --init --recursive
	./Setup.sh
	./GenerateProjectFiles.sh
	PLAT_SETS=""
	for pf in $PLATFLAGS; do
		PLAT_SETS="$PLAT_SETS -set:With${pf}=true"
	done
	CARGS=""
	[ "$CEF3" = "true" ] && CARGS="$CARGS -set:ExtraCompileArgs=-bCompileCEF3"
	[ "$ISPC" = "true" ] && CARGS="$CARGS -set:ExtraCompileArgs=-bCompileISPC"
	[ "$WITH_DDC" = "true" ] || WITH_DDC="false"
	echo "==> Building Unreal Engine with selected options..."
	./Engine/Build/BatchFiles/RunUAT.sh BuildGraph \
		-script=Engine/Build/InstalledEngineBuild.xml \
		-target="Make Installed Build Linux" \
		"$PLAT_SETS" \
		-set:GameConfigurations="$CONFVAL" \
		-set:WithDDC=$WITH_DDC \
		"$CARGS" \
		-set:CompileDatasmithPlugins=false \
		-set:AllowParallelExecutor=true
	echo "==> Build finished!"
	case "$OS" in
	linux)
		TOOLS="UnrealEditor UnrealPak ShaderCompileWorker"
		TOOLROOT="$UE_DIR/Engine/Binaries/Linux"
		;;
	macos)
		TOOLS="UnrealEditor UnrealPak ShaderCompileWorker UnrealVersionSelector"
		TOOLROOT="$UE_DIR/Engine/Binaries/Mac"
		;;
	windows)
		TOOLS="UnrealEditor.exe UnrealPak.exe ShaderCompileWorker.exe UnrealVersionSelector.exe"
		TOOLROOT="$UE_DIR/Engine/Binaries/Win64"
		;;
	esac
	for tool in $TOOLS; do
		src="$TOOLROOT/$tool"
		dest="$BIN/$(basename "$tool" .exe)"
		if [ -f "$src" ]; then
			ln -sf "$src" "$dest"
			echo "  → Symlinked $tool → $dest"
		else
			echo "  ⚠ Not found: $src (may not have been built for this platform)"
		fi
	done
	SETLINE="export PATH=\"$BIN:\$PATH\""
	for RCFILE in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
		[ -f "$RCFILE" ] || continue
		grep -F "$SETLINE" "$RCFILE" >/dev/null 2>&1 ||
			{ printf '\n# Unreal Quickstart: Add local bin to PATH\n%s\n' "$SETLINE" >>"$RCFILE"; }
	done
	echo
	if [ -n "${PLATSDKS:-}" ]; then
		echo "SDK check results:"
		for sdk in $PLATSDKS; do
			found=0
			case "$sdk" in
			Android)
				(command -v sdkmanager >/dev/null 2>&1 || [ -d "$HOME/Android/Sdk" ]) && found=1
				;;
			IOS | TVOS)
				command -v xcodebuild >/dev/null 2>&1 && found=1
				;;
			esac
			if [ "$found" -eq 1 ]; then
				echo "  ✓ $sdk SDK found."
			else
				case "$sdk" in
				Android)
					echo "  ⚠ Android SDK not found. Install Android Studio and ensure ANDROID_HOME is set."
					;;
				IOS | TVOS)
					echo "  ⚠ Xcode or iOS/tvOS SDK not found. Install Xcode and Xcode command line tools."
					;;
				esac
			fi
		done
	fi
	echo
	echo "✅ Unreal Engine setup complete!"
	echo "  → Main editor: $BIN/UnrealEditor"
	for tool in UnrealPak ShaderCompileWorker UnrealVersionSelector; do
		[ -x "$BIN/$tool" ] && echo "  → $tool: $BIN/$tool"
	done
	echo "  → Source: $UE_DIR"
	echo "  → $BIN is in your PATH (after terminal restart)."
	echo
	echo "To launch Unreal Editor:"
	echo "  UnrealEditor"
	echo
	echo "★ You might need to install additional SDKs/platform tools as described above."
	echo "★ For advanced platform packaging/configuration, confirm in official Unreal documentation."
	echo
fi
exit 0
