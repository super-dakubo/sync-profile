param(
    [Parameter(Mandatory=$true)]
    [string]$SeedPath
)

# 计算种子包内所有文件的 MD5，输出为 YAML 格式
Write-Host "files:"
Get-ChildItem $SeedPath -Recurse -File | Where-Object {
    $_.Extension -match '^\.(md|json|yaml|ps1|hbs)$' -and $_.DirectoryName -notmatch '\\.git$'
} | Sort-Object { $_.FullName.Replace($SeedPath, '').TrimStart('/\') } | ForEach-Object {
    $relative = $_.FullName.Replace($SeedPath, '').TrimStart('/\').TrimStart('\')
    if ($relative -eq 'seed.yaml') {
        Write-Host "  seed.yaml: SKIP_SELF_HASH"
    } else {
        $hash = (Get-FileHash $_.FullName -Algorithm MD5).Hash.ToLower()
        Write-Host "  $relative: $hash"
    }
}
