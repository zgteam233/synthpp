$ErrorActionPreference = "Stop"

# ==============================
# 配置
# ==============================
$BuildType = "Debug"
$BuildDir = "build"
$Generator = "Ninja"
$Triplet = "x64-windows"

# ==============================
# 查找 Visual Studio
# ==============================
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

if (!(Test-Path $vswhere)) {
    throw "找不到 vswhere.exe，请确认已安装 Visual Studio。"
}

$vsPath = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath

if (!$vsPath) {
    throw "找不到安装了 C++ 工具链的 Visual Studio。"
}

# ==============================
# 加载 VS 开发环境
# ==============================
$devShell = Join-Path $vsPath "Common7\Tools\Launch-VsDevShell.ps1"

if (!(Test-Path $devShell)) {
    throw "找不到 Launch-VsDevShell.ps1"
}

Write-Host "[INFO] 加载 Visual Studio 开发环境..." -ForegroundColor Cyan

& $devShell -Arch amd64 -HostArch amd64 -SkipAutomaticLocation

# ==============================
# 检查依赖
# ==============================
if (!$env:VCPKG_ROOT) {
    throw "未设置 VCPKG_ROOT 环境变量。"
}

$vcpkgToolchain = Join-Path $env:VCPKG_ROOT "scripts/buildsystems/vcpkg.cmake"

if (!(Test-Path $vcpkgToolchain)) {
    throw "找不到 vcpkg 工具链文件：$vcpkgToolchain"
}

# ==============================
# CMake 配置
# ==============================
Write-Host "[INFO] 配置 CMake..." -ForegroundColor Cyan

cmake -S . -B $BuildDir `
    -G $Generator `
    "-DCMAKE_BUILD_TYPE=$BuildType" `
    "-DCMAKE_TOOLCHAIN_FILE=$vcpkgToolchain" `
    "-DVCPKG_TARGET_TRIPLET=$Triplet"

if ($LASTEXITCODE -ne 0) {
    throw "CMake 配置失败。"
}

# ==============================
# 编译
# ==============================
Write-Host "[INFO] 开始编译..." -ForegroundColor Cyan

cmake --build $BuildDir

if ($LASTEXITCODE -ne 0) {
    throw "编译失败。"
}

Write-Host "[SUCCESS] 构建完成！" -ForegroundColor Green
