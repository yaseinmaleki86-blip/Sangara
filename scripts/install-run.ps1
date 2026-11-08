$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root
$transcript = $false
try {
    Start-Transcript -Path (Join-Path $root 'install-run.log') -Append | Out-Null
    $transcript = $true
    $node = Get-Command node.exe -ErrorAction SilentlyContinue
    $supported = $false
    if ($node) {
        $version = & $node.Source -p 'process.versions.node'
        $supported = ([version]$version -ge [version]'22.13.0')
    }
    if (-not $supported) {
        $nodeVersion = '22.13.1'
        $arch = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'arm64' } else { 'x64' }
        $folder = "node-v$nodeVersion-win-$arch"
        $runtime = Join-Path $root '.runtime'
        $nodePath = Join-Path $runtime "$folder\node.exe"
        if (-not (Test-Path $nodePath)) {
            Write-Host 'Downloading portable Node.js (first run only)...'
            New-Item -ItemType Directory -Force -Path $runtime | Out-Null
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $archive = Join-Path $runtime 'node.zip'
            $base = "https://nodejs.org/dist/v$nodeVersion"
            Invoke-WebRequest "$base/$folder.zip" -OutFile $archive -UseBasicParsing
            $checksums = (Invoke-WebRequest "$base/SHASUMS256.txt" -UseBasicParsing).Content
            $line = ($checksums -split "`n" | Where-Object { $_.Trim().EndsWith("  $folder.zip") })
            if (-not $line) { throw 'Node.js checksum entry was not found.' }
            $expected = ($line.Trim() -split '\s+')[0]
            if ((Get-FileHash $archive -Algorithm SHA256).Hash -ne $expected) { throw 'Node.js checksum verification failed.' }
            Expand-Archive -Path $archive -DestinationPath $runtime -Force
            Remove-Item $archive
        }
        $env:PATH = "$(Split-Path $nodePath);$env:PATH"
    }
    $env:NEXT_TELEMETRY_DISABLED = '1'
    $npm = (Get-Command npm.cmd -ErrorAction Stop).Source
    $hash = (Get-FileHash 'package.json' -Algorithm SHA256).Hash
    $marker = Join-Path $root 'node_modules\.sangara-installed'
    if (-not (Test-Path $marker) -or (Get-Content $marker -Raw).Trim() -ne $hash) {
        Write-Host 'Installing dependencies. Internet is required on first run...'
        & $npm install --no-audit --no-fund
        if ($LASTEXITCODE -ne 0) { throw 'Dependency installation failed. Check your internet connection and rerun INSTALL_RUN.bat.' }
        Set-Content -Path $marker -Value $hash
    }
    $port = 3000
    while ($port -lt 3020) {
        $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, $port)
        try { $listener.Start(); $listener.Stop(); break } catch { $port++ }
    }
    if ($port -ge 3020) { throw 'Ports 3000-3019 are occupied. Close previous servers and retry.' }
    Write-Host "Starting Sangara: http://127.0.0.1:$port"
    Write-Host 'Keep this window open. Press Ctrl+C to stop.'
    $url = "http://127.0.0.1:$port"
    $browser = Start-Job -ArgumentList $url -ScriptBlock {
        param($url)
        for ($attempt = 0; $attempt -lt 120; $attempt++) {
            try {
                $response = Invoke-WebRequest $url -UseBasicParsing -TimeoutSec 2
                if ($response.StatusCode -eq 200) { Start-Process $url; return }
            } catch {}
            Start-Sleep -Seconds 1
        }
    }
    try {
        & node '.\node_modules\next\dist\bin\next' dev --hostname 127.0.0.1 --port $port
        if ($LASTEXITCODE -ne 0) { throw 'The local server stopped with an error.' }
    } finally { Stop-Job $browser -ErrorAction SilentlyContinue; Remove-Job $browser -Force -ErrorAction SilentlyContinue }
} catch { Write-Host $_ -ForegroundColor Red; exit 1 }
finally { if ($transcript) { Stop-Transcript | Out-Null } }
