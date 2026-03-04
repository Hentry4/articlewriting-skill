param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $FilePath)) {
    Write-Host "File not found: $FilePath"
    exit 1
}

function Show-Matches {
    param(
        [string]$Title,
        [string]$Pattern
    )

    Write-Host ""
    Write-Host $Title

    $matches = Select-String -Path $FilePath -Pattern $Pattern
    if ($null -eq $matches) {
        Write-Host "OK"
    } else {
        foreach ($m in $matches) {
            Write-Host ("{0}:{1}" -f $m.LineNumber, $m.Line)
        }
    }
}

Write-Host ("Checking: {0}" -f $FilePath)

Show-Matches "[1] Unnecessary bold markers (** or __):" '\*\*|__'
Show-Matches "[2] List lines (正文需谨慎使用):" '^\s*([-*+]\s+|[0-9]+\.\s+)'
Show-Matches "[3] Banned transition/emphasis phrases:" '首先|其次|最后|此外|另外|接下来|值得注意的是|需要指出的是|重要的是|必须强调的是'
Show-Matches "[4] Banned English transition/emphasis phrases:" 'first and foremost|to begin with|moreover|furthermore|last but not least|it is worth noting that|importantly'
Show-Matches "[5] Subjective first-person phrases (论文正文慎用):" '我认为|我觉得|我个人(认为|看法)|我的研究|in my opinion|i believe'

Write-Host ""
Write-Host "[6] Consecutive non-empty lines (可能缺少段间空行，人工复核):"

$lines = Get-Content -LiteralPath $FilePath
for ($i = 1; $i -lt $lines.Count; $i++) {
    $prev = $lines[$i - 1]
    $curr = $lines[$i]

    $isCandidate = (
        $prev -notmatch '^\s*$' -and
        $curr -notmatch '^\s*$' -and
        $prev -notmatch '^\s*```' -and
        $curr -notmatch '^\s*```' -and
        $prev -notmatch '^\s*[#>\-]' -and
        $curr -notmatch '^\s*[#>\-]' -and
        $prev -notmatch '^\s*[0-9]+\.' -and
        $curr -notmatch '^\s*[0-9]+\.'
    )

    if ($isCandidate) {
        Write-Host ("{0}:{1}" -f $i, $prev)
        Write-Host ("{0}:{1}" -f ($i + 1), $curr)
        Write-Host "---"
    }
}

Write-Host ""
Write-Host "Done."
