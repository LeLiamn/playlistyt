# Petit serveur local pour Boucle Playlists.
# YouTube refuse de lire les vidéos dans une page ouverte en double-clic (file://),
# d'où ce serveur minimal sur http://localhost. Il ne sert que index.html, et seulement à ce PC.
param([switch]$SansNavigateur)
$port = 8765
$dossier = Split-Path -Parent $MyInvocation.MyCommand.Path
$page = Join-Path $dossier "index.html"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
try { $listener.Start() } catch {
    Write-Host "Le port $port est déjà utilisé : l'app tourne peut-être déjà. Ouverture du navigateur."
    Start-Process "http://localhost:$port/"
    exit
}
Write-Host "Boucle Playlists : http://localhost:$port/"
Write-Host "Laisse cette fenêtre ouverte tant que la musique tourne. Ferme-la pour arrêter."
if (-not $SansNavigateur) { Start-Process "http://localhost:$port/" }

while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $res = $ctx.Response
    try {
        if ($ctx.Request.Url.AbsolutePath -eq "/" -or $ctx.Request.Url.AbsolutePath -eq "/index.html") {
            $bytes = [System.IO.File]::ReadAllBytes($page)
            $res.ContentType = "text/html; charset=utf-8"
            $res.Headers.Add("Cache-Control", "no-cache")
        } else {
            $res.StatusCode = 404
            $bytes = [System.Text.Encoding]::UTF8.GetBytes("Introuvable")
        }
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } finally { $res.Close() }
}
