Powershell in administrator mode is required

Prerequisite:
feltelepítetted ezt:

irm https://antigravity.google/cli/install.ps1 | iex


---

# Download and install Chocolatey:
powershell -c "irm https://community.chocolatey.org/install.ps1|iex"

# Download and install Node.js:
choco install nodejs --version="24.21.0"

# Verify the Node.js version:
node -v # Should print "v24.21.0".

# Download and install pnpm:
corepack enable pnpm

# Verify pnpm version:
pnpm -v

if not:

Invoke-WebRequest https://get.pnpm.io/install.ps1 -UseBasicParsing | Invoke-Expression





1.



 https://github.com/Comfy-Org/ComfyUI#manual-install-windows-linux

