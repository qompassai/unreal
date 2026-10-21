<!------------/qompassai/unreal/README.md ---------------->
<!-- ----------Qompass AI on Unreal ---------------------->
<!-- Copyright (C) 2026 Qompass AI, All rights reserved -->
<!-------------------------------------------------------->

<h3> Qompass AI on Unreal Game Engine </h3>

<h2> Qompass AI Unreal Solutions: A more humane UX for AI </h2>

![Repository Views](https://komarev.com/ghpvc/?username=qompassai-unreal)
![GitHub all releases](https://img.shields.io/github/downloads/qompassai/unreal/total?style=flat-square)
<p align="center">
<a href="https://www.unrealengine.com/">
  <img src="https://img.shields.io/badge/Unreal_Engine-0E1128?style=for-the-badge&logo=unrealengine&logoColor=white" alt="Unreal Engine">
</a>
<br>
<a href="https://docs.unrealengine.com/">
  <img src="https://img.shields.io/badge/UE_Documentation-blue?style=flat-square" alt="Unreal Engine Documentation">
</a>
<a href="https://github.com/topics/unreal-engine">
  <img src="https://img.shields.io/badge/UE_Tutorials-green?style=flat-square" alt="Unreal Engine Tutorials">
</a>
<br>
<a href="https://doi.org/10.5281/zenodo.16170575">
  <img src="https://zenodo.org/badge/DOI/10.5281/zenodo.16170575.svg" alt="DOI">
</a>

  <a href="./LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" alt="License: Apache 2.0"></a>

</p>


<details>
  <summary style="font-size: 1.4em; font-weight: bold; padding: 15px; background: #667eea; color: white; border-radius: 10px; cursor: pointer; margin: 10px 0;">
    <strong>▶️ Qompass AI Quick Start</strong>
  </summary>
  <div style="background: #f8f9fa; padding: 15px; border-radius: 5px; margin-top: 10px; font-family: monospace;">

```bash  
curl -fsSL https://raw.githubusercontent.com/qompassai/unreal/main/scripts/quickstart.sh | sh
```
  </div>
  <blockquote style="font-size: 1.2em; line-height: 1.8; padding: 25px; background: #f8f9fa; border-left: 6px solid #667eea; border-radius: 8px; margin: 15px 0; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
    <details>
      <summary style="font-size: 1em; font-weight: bold; padding: 10px; background: #e9ecef; color: #333; border-radius: 5px; cursor: pointer; margin: 10px 0;">
        <strong>📄 We advise you read the script BEFORE running it 😉</strong>
      </summary>
      <pre style="background: #fff; padding: 15px; border-radius: 5px; border: 1px solid #ddd; overflow-x: auto;">
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
	echo "==> Ensuring ASP.NET Core HTTPS dev certificate is trusted for local development (if required)..."
dotnet dev-certs https --trust || {
  echo "❌ Could not trust HTTPS certificate. See https://aka.ms/dev-certs-trust for manual steps."
}
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
exit 0</pre>
</details>
<p>Or, <a href="https://github.com/qompassai/unreal/blob/main/scripts/quickstart.sh" target="_blank">View the quickstart script directly</a>.</p>
</blockquote>
</details>

</blockquote>
</details>

<details>
<summary style="font-size: 1.4em; font-weight: bold; padding: 15px; background: #667eea; color: white; border-radius: 10px; cursor: pointer; margin: 10px 0;"><strong>🧭 About Qompass AI</strong></summary>
<blockquote style="font-size: 1.2em; line-height: 1.8; padding: 25px; background: #f8f9fa; border-left: 6px solid #667eea; border-radius: 8px; margin: 15px 0; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">

<div align="center">
  <p>Owner<br>
  Former Intelligence Officer<br>
  Educator & Learner<br>
  DeepTech Founder & CEO</p>
</div>

<h3>Publications</h3>
  <p>
    <a href="https://orcid.org/0000-0002-0302-4812">
      <img src="https://img.shields.io/badge/ORCID-0000--0002--0302--4812-green?style=flat-square&logo=orcid" alt="ORCID">
    </a>
    <a href="https://www.researchgate.net/profile/Matt-Porter-7">
      <img src="https://img.shields.io/badge/ResearchGate-Open--Research-blue?style=flat-square&logo=researchgate" alt="ResearchGate">
    </a>
    <a href="https://zenodo.org/communities/qompassai">
      <img src="https://img.shields.io/badge/Zenodo-Publications-blue?style=flat-square&logo=zenodo" alt="Zenodo">
    </a>
  </p>

<h3>Developer Programs</h3>

[![NVIDIA Developer](https://img.shields.io/badge/NVIDIA-Developer_Program-76B900?style=for-the-badge\&logo=nvidia\&logoColor=white)](https://developer.nvidia.com/)
[![Meta Developer](https://img.shields.io/badge/Meta-Developer_Program-0668E1?style=for-the-badge\&logo=meta\&logoColor=white)](https://developers.facebook.com/)
[![HackerOne](https://img.shields.io/badge/-HackerOne-%23494649?style=for-the-badge\&logo=hackerone\&logoColor=white)](https://hackerone.com/phaedrusflow)
[![HuggingFace](https://img.shields.io/badge/HuggingFace-qompass-yellow?style=flat-square\&logo=huggingface)](https://huggingface.co/qompass)
[![Epic Games Developer](https://img.shields.io/badge/Epic_Games-Developer_Program-313131?style=for-the-badge\&logo=epic-games\&logoColor=white)](https://dev.epicgames.com/)

<h3>Professional Profiles</h3>
  <p>
    <a href="https://www.linkedin.com/in/matt-a-porter-103535224/">
      <img src="https://img.shields.io/badge/LinkedIn-Owner-blue?style=flat-square&logo=linkedin" alt="Personal LinkedIn">
    </a>
    <a href="https://www.linkedin.com/company/95058568/">
      <img src="https://img.shields.io/badge/LinkedIn-Qompass--AI-blue?style=flat-square&logo=linkedin" alt="Startup LinkedIn">
    </a>
  </p>

<h3>Social Media</h3>
  <p>
    <a href="https://twitter.com/PhaedrusFlow">
      <img src="https://img.shields.io/badge/Twitter-@PhaedrusFlow-blue?style=flat-square&logo=twitter" alt="X/Twitter">
    </a>
    <a href="https://www.instagram.com/phaedrusflow">
      <img src="https://img.shields.io/badge/Instagram-phaedrusflow-purple?style=flat-square&logo=instagram" alt="Instagram">
    </a>
    <a href="https://www.youtube.com/@qompassai">
      <img src="https://img.shields.io/badge/YouTube-QompassAI-red?style=flat-square&logo=youtube" alt="Qompass AI YouTube">
    </a>
  </p>

</blockquote>
</details>

<details>
<summary style="font-size: 1.4em; font-weight: bold; padding: 15px; background: #ff6b6b; color: white; border-radius: 10px; cursor: pointer; margin: 10px 0;"><strong>🔥 How Do I Support</strong></summary>
<blockquote style="font-size: 1.2em; line-height: 1.8; padding: 25px; background: #fff5f5; border-left: 6px solid #ff6b6b; border-radius: 8px; margin: 15px 0; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">

<div align="center">

<table>
<tr>
<th align="center">🏛️ Qompass AI Pre-Seed Funding 2023-2025</th>
<th align="center">🏆 Amount</th>
<th align="center">📅 Date</th>
</tr>
<tr>
<td><a href="https://github.com/qompassai/r4r" title="RJOS/Zimmer Biomet Research Grant Repository">RJOS/Zimmer Biomet Research Grant</a></td>
<td align="center">$30,000</td>
<td align="center">March 2024</td>
</tr>
<tr>
<td><a href="https://github.com/qompassai/PathFinders" title="GitHub Repository">Pathfinders Intern Program</a><br>
<small><a href="https://www.linkedin.com/posts/evergreenbio_bioscience-internships-workforcedevelopment-activity-7253166461416812544-uWUM/" target="_blank">View on LinkedIn</a></small></td>
<td align="center">$2,000</td>
<td align="center">October 2024</td>
</tr>
</table>

<br>
<h4>🤝 How To Support Our Mission</h4>

[![GitHub Sponsors](https://img.shields.io/badge/GitHub-Sponsor-EA4AAA?style=for-the-badge\&logo=github-sponsors\&logoColor=white)](https://github.com/sponsors/phaedrusflow)
[![Patreon](https://img.shields.io/badge/Patreon-Support-F96854?style=for-the-badge\&logo=patreon\&logoColor=white)](https://patreon.com/qompassai)
[![Liberapay](https://img.shields.io/badge/Liberapay-Donate-F6C915?style=for-the-badge\&logo=liberapay\&logoColor=black)](https://liberapay.com/qompassai)
[![Open Collective](https://img.shields.io/badge/Open%20Collective-Support-7FADF2?style=for-the-badge\&logo=opencollective\&logoColor=white)](https://opencollective.com/qompassai)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Support-FFDD00?style=for-the-badge\&logo=buy-me-a-coffee\&logoColor=black)](https://www.buymeacoffee.com/phaedrusflow)

<details markdown="1">
<summary><strong>🔐 Cryptocurrency Donations</strong></summary>

**Monero (XMR):**

<div align="center">
  <img src="https://raw.githubusercontent.com/qompassai/svg/main/assets/monero-qr.svg" alt="Monero QR Code" width="180">
</div>

<div style="margin: 10px 0;">
    <code>42HGspSFJQ4MjM5ZusAiKZj9JZWhfNgVraKb1eGCsHoC6QJqpo2ERCBZDhhKfByVjECernQ6KeZwFcnq8hVwTTnD8v4PzyH</code>
  </div>

<button onclick="navigator.clipboard.writeText('42HGspSFJQ4MjM5ZusAiKZj9JZWhfNgVraKb1eGCsHoC6QJqpo2ERCBZDhhKfByVjECernQ6KeZwFcnq8hVwTTnD8v4PzyH')" style="padding: 6px 12px; background: #FF6600; color: white; border: none; border-radius: 4px; cursor: pointer;">
    📋 Copy Address
  </button>
<p><i>Funding helps us continue our research at the intersection of AI, healthcare, and education</i></p>

</blockquote>
</details>
</details>

<details id="FAQ">
  <summary><strong>Frequently Asked Questions</strong></summary>

### Q: How do you mitigate against bias?

**TLDR - we do math to make AI ethically useful**

### A: We delineate between mathematical bias (MB) - a fundamental parameter in neural network equations - and algorithmic/social bias (ASB). While MB is optimized during model training through backpropagation, ASB requires careful consideration of data sources, model architecture, and deployment strategies. We implement attention mechanisms for improved input processing and use legal open-source data and secure web-search APIs to help mitigate ASB.

[AAMC AI Guidelines | One way to align AI against ASB](https://www.aamc.org/about-us/mission-areas/medical-education/principles-ai-use)

### AI Math at a glance

## Forward Propagation Algorithm

$$
y = w_1x_1 + w_2x_2 + ... + w_nx_n + b
$$

Where:

- $y$ represents the model output
- $(x_1, x_2, ..., x_n)$ are input features
- $(w_1, w_2, ..., w_n)$ are feature weights
- $b$ is the bias term

### Neural Network Activation

For neural networks, the bias term is incorporated before activation:

$$
z = \sum_{i=1}^{n} w_ix_i + b
$$
$$
a = \sigma(z)
$$

Where:

- $z$ is the weighted sum plus bias
- $a$ is the activation output
- $\sigma$ is the activation function

### Attention Mechanism- aka what makes the Transformer (The "T" in ChatGPT) powerful

- [Attention High level overview video](https://www.youtube.com/watch?v=fjJOgb-E41w)

- [Attention Is All You Need Arxiv Paper](https://arxiv.org/abs/1706.03762)

The Attention mechanism equation is:

$$
Attention(Q, K, V) = softmax(\frac{QK^T}{\sqrt{d_k}})V
$$

Where:

- $Q$ represents the Query matrix
- $K$ represents the Key matrix
- $V$ represents the Value matrix
- $d_k$ is the dimension of the key vectors
- $\text{softmax}(\cdot)$ normalizes scores to sum to 1

### Q: Do I have to buy a Linux computer to use this? I don't have time for that!

### A: No. You can run Linux and/or the tools we share alongside your existing operating system:

- Windows users can use Windows Subsystem for Linux [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)
- Mac users can use [Homebrew](https://brew.sh/)
- The code-base instructions were developed with both beginners and advanced users in mind.

### Q: Do you have to get a masters in AI?

### A: Not if you don't want to. To get competent enough to get past ChatGPT dependence at least, you just need a computer and a beginning's mindset. Huggingface is a good place to start.

- [Huggingface](https://docs.google.com/presentation/d/1IkzESdOwdmwvPxIELYJi8--K3EZ98_cL6c5ZcLKSyVg/edit#slide=id.p)

### Q: What makes a "small" AI model?

### A: AI models ~=10 billion(10B) parameters and below. For comparison, OpenAI's GPT4o contains approximately 200B parameters.

</details>

## License

This project is licensed under the [Apache License, Version 2.0](./LICENSE).
