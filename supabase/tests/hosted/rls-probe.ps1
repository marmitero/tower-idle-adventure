<#
    Tower Idle Adventure — sonda de validacao RLS no Supabase hospedado (G2)
    ---------------------------------------------------------------------
    Esta script NAO instala nada, NAO altera nada e NAO apaga nada no banco.
    Apenas faz leituras HTTP e mostra se o banco recusou ou nao.

    Como usar (Windows, sem instalar nada):
      1. Abra esta pasta no Explorador de Arquivos
      2. Clique na barra de endereco, digite "powershell" e aperte Enter
      3. No terminal que abriu, digite:
             powershell -ExecutionPolicy Bypass -File .\rls-probe.ps1
#>

param(
    [string]$ProjectUrl = "https://xzhdqjttmwdrtnilpktu.supabase.co",
    [string]$PublishableKey = "sb_publishable_aoL7L1R7asUE-9nZZxChAA_awnrJS4G",
    [string]$EmailA = "a+teste1@exemplo.invalid",
    [string]$EmailB = "b+teste1@exemplo.invalid",
    [switch]$SkipAuth
)

# O Windows 10 usa TLS 1.0 por padrao em scripts antigos; forcar 1.2.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ErrorActionPreference = "Continue"
$ProjectUrl = $ProjectUrl.TrimEnd("/")
$results = New-Object System.Collections.ArrayList

# ---------------------------------------------------------------- utilidades

function Cores {
    $ok = "`e[32m"; $fail = "`e[31m"; $warn = "`e[33m"; $info = "`e[36m"; $off = "`e[0m"
    Write-Host ""
    Write-Host "  Tower Idle Adventure - validacao de seguranca do banco (G2)" -ForegroundColor White
    Write-Host "  Projeto: $ProjectUrl" -ForegroundColor DarkGray
    Write-Host "  Este teste so LE. Nada sera alterado ou apagado." -ForegroundColor DarkGray
    Write-Host "  ------------------------------------------------------------" -ForegroundColor DarkGray
}

function Add-Resultado {
    param($Grupo, $Nome, $Esperado, $Obtido, $Veredito, $Detalhe)
    [void]$results.Add([pscustomobject]@{
        grupo = $Grupo; verificacao = $Nome; esperado = $Esperado
        obtido = $Obtido; veredito = $Veredito; detalhe = $Detalhe
    })
}

function Invoke-Probe {
    # Retorna @{ Status; Body } sem lancar excecao, mesmo em erro 4xx.
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [string]$Method = "GET",
        [string]$Token,
        $Body
    )
    $headers = @{ apikey = $PublishableKey; Prefer = "return=representation" }
    if ($Token) { $headers["Authorization"] = "Bearer $Token" }
    if ($Body)   { $headers["Content-Type"] = "application/json" }

    $uri = "$ProjectUrl/rest/v1/$Path"
    $params = @{
        Uri             = $uri
        Headers         = $headers
        Method          = $Method
        UseBasicParsing = $true
        ErrorAction     = "Stop"
    }
    if ($Body) { $params["Body"] = ($Body | ConvertTo-Json -Depth 6 -Compress) }

    try {
        $r = Invoke-WebRequest @params
        return @{ Status = [int]$r.StatusCode; Body = [string]$r.Content }
    } catch {
        $code = 0
        $content = ""
        $resp = $_.Exception.Response
        if ($resp) {
            $code = [int]$resp.StatusCode
            try {
                $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
                $content = $reader.ReadToEnd()
                $reader.Close()
            } catch { }
        }
        if ($code -eq 0) { $code = -1 }
        return @{ Status = $code; Body = $content }
    }
}

function Get-Traducao {
    # 200 = o banco entregou. 401/403 = o banco recusou. 404 = tabela fora do cache.
    param($r)
    if ($r.Status -eq 200) { return "PERMITIDO" }
    if ($r.Status -eq 401 -or $r.Status -eq 403) { return "NEGADO" }
    if ($r.Status -eq 404) { return "FORA-DO-CACHE" }
    if ($r.Status -eq -1) { return "SEM-CONEXAO" }
    return "HTTP-$($r.Status)"
}

function Resumo {
    param($Body)
    if (-not $Body) { return "" }
    $t = $Body -replace '\s+', ' '
    if ($t.Length -gt 90) { $t = $t.Substring(0, 90) + "..." }
    return $t
}

# ------------------------------------------------------------------ parte 1
# Visitante sem login: so a chave publica, que qualquer pessoa na internet tem.

function Testar-Anonimo {
    param($TabelasJogador, $TabelasSecretas, $TabelasRelease, $ViewPublica)

    $g = "PARTE 1 - visitante sem login"

    Add-Resultado $g "Leitura do catalogo publico ($ViewPublica)" "PERMITIDO" "?" "AGUARDANDO" ""

    foreach ($t in $TabelasJogador) {
        $r = Invoke-Probe -Path "$t`?select=*&limit=1"
        $o = Get-Traducao $r
        if ($o -eq "NEGADO") {
            Add-Resultado $g "Visitante le $t" "NEGADO" "NEGADO" "OK" "HTTP $($r.Status)"
        } elseif ($o -eq "PERMITIDO") {
            Add-Resultado $g "Visitante le $t" "NEGADO" "PERMITIDO" "FALHA" "VAZAMENTO: $($r.Body)"
        } else {
            Add-Resultado $g "Visitante le $t" "NEGADO" $o "INCONCLUSIVO" (Resumo $r.Body)
        }
        Mostrar
    }

    foreach ($t in $TabelasSecretas) {
        $r = Invoke-Probe -Path "$t`?select=*&limit=1"
        $o = Get-Traducao $r
        if ($o -eq "NEGADO") {
            Add-Resultado $g "Visitante le $t (secreta)" "NEGADO" "NEGADO" "OK" "HTTP $($r.Status)"
        } elseif ($o -eq "PERMITIDO") {
            Add-Resultado $g "Visitante le $t (secreta)" "NEGADO" "PERMITIDO" "FALHA" "VAZAMENTO: $($r.Body)"
        } else {
            Add-Resultado $g "Visitante le $t (secreta)" "NEGADO" $o "INCONCLUSIVO" (Resumo $r.Body)
        }
        Mostrar
    }

    foreach ($t in $TabelasRelease) {
        $r = Invoke-Probe -Path "$t`?select=*&limit=1"
        $o = Get-Traducao $r
        if ($o -eq "NEGADO") {
            Add-Resultado $g "Visitante le $t (tabela-base)" "NEGADO" "NEGADO" "OK" "HTTP $($r.Status)"
        } elseif ($o -eq "PERMITIDO") {
            Add-Resultado $g "Visitante le $t (tabela-base)" "NEGADO" "PERMITIDO" "FALHA" "VAZAMENTO: $($r.Body)"
        } else {
            Add-Resultado $g "Visitante le $t (tabela-base)" "NEGADO" $o "INCONCLUSIVO" (Resumo $r.Body)
        }
        Mostrar
    }

    $r = Invoke-Probe -Path "$ViewPublica`?select=*&limit=1"
    $o = Get-Traducao $r
    if ($o -eq "PERMITIDO") {
        Add-Resultado $g "Visitante le $ViewPublica" "PERMITIDO" "PERMITIDO" "OK" (Resumo $r.Body)
    } else {
        Add-Resultado $g "Visitante le $ViewPublica" "PERMITIDO" $o "INCONCLUSIVO" (Resumo $r.Body)
    }
    Mostrar

    foreach ($fn in @("reject_append_only_mutation", "reject_immutable_mutation")) {
        $r = Invoke-Probe -Path "rpc/$fn" -Method "POST" -Body @{}
        $detalhe = Resumo $r.Body
        if ($r.Status -eq 200) {
            Add-Resultado $g "Visitante chama a funcao $fn" "NAO-EXPOSTA" "EXECUTADA" "FALHA" $detalhe
        } else {
            Add-Resultado $g "Visitante chama a funcao $fn" "NAO-EXPOSTA" "NAO-EXPOSTA" "OK" $detalhe
        }
        Mostrar
    }
}

# ------------------------------------------------------------------ parte 2
# Jogador autenticado: a prova de que um jogador nao ve o outro.

function Testar-Jogador {
    param($Rotulo, $Email, $Senha, $TabelasJogador, $TabelasSecretas, $ViewPublica, $OutroRotulo)

    $g = "PARTE 2 - $Rotulo autenticado"

    $token = $null
    try {
        $resp = Invoke-RestMethod -Method Post -Uri "$ProjectUrl/auth/v1/token?grant_type=password" `
            -Headers @{ apikey = $PublishableKey; "Content-Type" = "application/json" } `
            -Body (@{ email = $Email; password = $Senha } | ConvertTo-Json -Compress) `
            -ErrorAction Stop
        $token = $resp.access_token
    } catch {
        $msg = $_.Exception.Message
        Add-Resultado $g "Login de $Rotulo" "AUTENTICADO" "FALHOU" "INCONCLUSIVO" $msg
        Mostrar
        return
    }
    Add-Resultado $g "Login de $Rotulo" "AUTENTICADO" "AUTENTICADO" "OK" "token guardado so na memoria deste processo"
    Mostrar

    # Le o proprio perfil
    $r = Invoke-Probe -Path "player_profiles?select=*&limit=5" -Token $token
    if ((Get-Traducao $r) -eq "PERMITIDO") {
        Add-Resultado $g "$Rotulo le o proprio perfil" "PERMITIDO" "PERMITIDO" "OK" (Resumo $r.Body)
    } else {
        Add-Resultado $g "$Rotulo le o proprio perfil" "PERMITIDO" (Get-Traducao $r) "FALHA" (Resumo $r.Body)
    }
    Mostrar

    # Tenta alterar dinheiro direto no banco (nao pode)
    foreach ($caso in @(
        @{ tab = "player_profiles"; nome = "moedas";  corpo = @{ coins = 999999 } },
        @{ tab = "bot_settings";     nome = "bot";    corpo = @{ potion_threshold = 10 } },
        @{ tab = "consumable_stacks"; nome = "itens"; corpo = @{ quantity = 99 } }
    )) {
        $r = Invoke-Probe -Path "$($caso.tab)?select=*" -Token $token -Method "PATCH" -Body $caso.corpo
        $o = Get-Traducao $r
        if ($o -eq "NEGADO") {
            Add-Resultado $g "$Rotulo altera $($caso.nome) direto no banco" "NEGADO" "NEGADO" "OK" "HTTP $($r.Status)"
        } elseif ($o -eq "PERMITIDO") {
            Add-Resultado $g "$Rotulo altera $($caso.nome) direto no banco" "NEGADO" "PERMITIDO" "FALHA" "GRAVE: $($r.Body)"
        } else {
            Add-Resultado $g "$Rotulo altera $($caso.nome) direto no banco" "NEGADO" $o "INCONCLUSIVO" (Resumo $r.Body)
        }
        Mostrar
    }

    # Tenta apagar a propria sessao de hunt
    $r = Invoke-Probe -Path "hunt_sessions?select=*" -Token $token -Method "DELETE"
    $o = Get-Traducao $r
    if ($o -eq "NEGADO" -or $r.Status -eq 204) {
        Add-Resultado $g "$Rotulo apaga sessao de hunt" "NEGADO" "NEGADO" "OK" "HTTP $($r.Status)"
    } else {
        Add-Resultado $g "$Rotulo apaga sessao de hunt" "NEGADO" $o "INCONCLUSIVO" (Resumo $r.Body)
    }
    Mostrar

    # Tabelas secretas continuam fechadas mesmo autenticado
    foreach ($t in $TabelasSecretas) {
        $r = Invoke-Probe -Path "$t`?select=*&limit=1" -Token $token
        $o = Get-Traducao $r
        if ($o -eq "NEGADO") {
            Add-Resultado $g "$Rotulo le $t (secreta)" "NEGADO" "NEGADO" "OK" "HTTP $($r.Status)"
        } elseif ($o -eq "PERMITIDO") {
            Add-Resultado $g "$Rotulo le $t (secreta)" "NEGADO" "PERMITIDO" "FALHA" "VAZAMENTO: $($r.Body)"
        } else {
            Add-Resultado $g "$Rotulo le $t (secreta)" "NEGADO" $o "INCONCLUSIVO" (Resumo $r.Body)
        }
        Mostrar
    }

    $r = Invoke-Probe -Path "$ViewPublica`?select=*&limit=1" -Token $token
    Add-Resultado $g "$Rotulo le $ViewPublica" "PERMITIDO" (Get-Traducao $r) "INFO" (Resumo $r.Body)
    Mostrar
}

# Cross-check: o filtro de dono realmente prende na conta? Feito comparando
# as linhas que cada token enxerga entre as duas contas.
function Testar-Propriedade {
    param($EmailA, $SenhaA, $EmailB, $SenhaB, $TabelasJogador, $Rotulo)

    $g = "PARTE 3 - $Rotulo tenta ver dados do outro jogador"

    $tokens = @{}
    foreach ($par in @(@{ k = "A"; e = $EmailA; s = $SenhaA }, @{ k = "B"; e = $EmailB; s = $SenhaB })) {
        try {
            $resp = Invoke-RestMethod -Method Post -Uri "$ProjectUrl/auth/v1/token?grant_type=password" `
                -Headers @{ apikey = $PublishableKey; "Content-Type" = "application/json" } `
                -Body (@{ email = $par.e; password = $par.s } | ConvertTo-Json -Compress) `
                -ErrorAction Stop
            $tokens[$par.k] = $resp
        } catch {
            Add-Resultado $g "Login de $($par.k)" "AUTENTICADO" "FALHOU" "INCONCLUSIVO" $_.Exception.Message
            Mostrar
            return
        }
    }

    $idA = $tokens["A"].user.id
    $idB = $tokens["B"].user.id
    Add-Resultado $g "Identidades confirmadas pelo token" "2 usuarios distintos" "A=$idA  B=$idB" "INFO" ""
    Mostrar

    foreach ($t in $TabelasJogador) {
        $rA = Invoke-Probe -Path "$t`?select=*&user_id=eq.$idB" -Token $tokens["A"].access_token
        $rB = Invoke-Probe -Path "$t`?select=*&user_id=eq.$idA" -Token $tokens["B"].access_token

        $vazouA = ($rA.Status -eq 200 -and $rA.Body -and $rA.Body.Trim() -ne "[]")
        $vazouB = ($rB.Status -eq 200 -and $rB.Body -and $rB.Body.Trim() -ne "[]")

        if ($vazouA -or $vazouB) {
            Add-Resultado $g "$Rotulo le dados do outro jogador em $t" "VAZIO" "VAZAMENTO" "FALHA" "A viu: $($rA.Body) | B viu: $($rB.Body)"
        } else {
            Add-Resultado $g "$Rotulo le dados do outro jogador em $t" "VAZIO" "VAZIO" "OK" "A: HTTP $($rA.Status) | B: HTTP $($rB.Status)"
        }
        Mostrar
    }
}

function Mostrar {
    $ultimo = $results[$results.Count - 1]
    if ($ultimo.veredito -eq "AGUARDANDO") { return }
    $cor = switch ($ultimo.veredito) {
        "OK"          { "`e[32m" }
        "FALHA"       { "`e[31m" }
        "INCONCLUSIVO"{ "`e[33m" }
        default       { "`e[37m" }
    }
    $marca = switch ($ultimo.veredito) { "OK" { "v" } "FALHA" { "X" } "INCONCLUSIVO" { "?" } default { "-" } }
    Write-Host ("  [$marca] " + $ultimo.verificacao.PadRight(52) + " esperado: " + $ultimo.esperado.PadRight(10) + " obtido: " + $ultimo.obtido) -ForegroundColor $cor
}

# ------------------------------------------------------------------- execucao

$tabelasJogador = @(
    "player_profiles", "player_roster", "player_items", "equipment_loadouts",
    "consumable_stacks", "coin_ledger", "bot_settings", "hunt_sessions", "hunt_events"
)
$tabelasSecretas = @(
    "content_drafts", "hunt_session_private_state", "idempotency_records",
    "admin_memberships", "admin_audit_log"
)
$tabelasRelease = @("content_releases", "release_entries", "active_content_release")
$viewPublica = "published_content"

Cores

Write-Host ""
Write-Host "  ETAPA 1 de 3 - visitante sem login" -ForegroundColor Cyan
Testar-Anonimo $tabelasJogador $tabelasSecretas $tabelasRelease $viewPublica

$senhaA = $null; $senhaB = $null
if (-not $SkipAuth) {
    Write-Host ""
    Write-Host "  ETAPA 2 de 3 - login dos dois jogadores de teste" -ForegroundColor Cyan
    Write-Host "  As senhas nao serao exibidas na tela, nao entram em arquivo e nao sao enviadas a ninguem." -ForegroundColor DarkGray
    Write-Host ""
    $senhaA = Read-Host -Prompt "  Senha do usuario A ($EmailA)" -AsSecureString
    $senhaB = Read-Host -Prompt "  Senha do usuario B ($EmailB)" -AsSecureString

    $pa = [System.Net.NetworkCredential]::new("", $senhaA).Password
    $pb = [System.Net.NetworkCredential]::new("", $senhaB).Password

    Testar-Jogador "Jogador A" $EmailA $pa $tabelasJogador $tabelasSecretas $viewPublica "B"
    Testar-Jogador "Jogador B" $EmailB $pb $tabelasJogador $tabelasSecretas $viewPublica "A"

    Write-Host ""
    Write-Host "  ETAPA 3 de 3 - jogador A tentando ler dados do jogador B" -ForegroundColor Cyan
    Testar-Propriedade $EmailA $pa $EmailB $pb $tabelasJogador "Jogador A"
} else {
    Write-Host ""
    Write-Host "  ETAPAS 2 e 3 puladas (parametro -SkipAuth)." -ForegroundColor DarkGray
}

# ------------------------------------------------------------------- relatorio

$ok = ($results | Where-Object { $_.veredito -eq "OK" }).Count
$falha = ($results | Where-Object { $_.veredito -eq "FALHA" }).Count
$inconclusivo = ($results | Where-Object { $_.veredito -eq "INCONCLUSIVO" }).Count

$relatorio = [pscustomobject]@{
    quando      = (Get-Date).ToString("o")
    projeto     = $ProjectUrl
    observacao  = "Somente leituras. Nenhum dado foi alterado."
    total       = $ok + $falha + $inconclusivo
    ok          = $ok
    falhas      = $falha
    inconclusivos = $inconclusivo
    resultados  = @($results)
}

Write-Host ""
Write-Host "  ------------------------------------------------------------" -ForegroundColor DarkGray
if ($falha -gt 0) {
    Write-Host "  RESULTADO: $falha FALHA(S) CRITICA(S) - $ok ok - $inconclusivo inconclusivo" -ForegroundColor Red
} elseif ($inconclusivo -gt 0) {
    Write-Host "  RESULTADO: nenhum vazamento, mas $inconclusivo inconclusivo(s) - $ok ok" -ForegroundColor Yellow
} else {
    Write-Host "  RESULTADO: TUDO OK - $ok verificacoes" -ForegroundColor Green
}
Write-Host "  ------------------------------------------------------------" -ForegroundColor DarkGray

$arquivo = Join-Path $PSScriptRoot "rls-result.json"
$relatorio | ConvertTo-Json -Depth 6 | Out-File -FilePath $arquivo -Encoding UTF8
Write-Host ""
Write-Host "  Relatorio completo salvo em:" -ForegroundColor White
Write-Host "  $arquivo" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Como enviar: abra esse arquivo .json, copie tudo (Ctrl+A, Ctrl+C)" -ForegroundColor DarkGray
Write-Host "  e cole na conversa. Nao contem senha nem token." -ForegroundColor DarkGray
Write-Host ""

Read-Host "  Aperte Enter para fechar"
