Estamos construindo uma plataforma SaaS em .NET.

IMPORTANTE:

- Não fixe versões de .NET.
- Não utilize Preview.
- Não utilize RC.
- Não utilize Nightly.
- Detecte automaticamente a versão estável mais recente do SDK .NET disponível.
- Gere o TargetFramework dinamicamente.
- Entity Framework Core e dotnet-ef devem utilizar automaticamente a mesma major version do TargetFramework.
- Nenhum script pode conter versões hardcoded.
- Nenhum script pode assumir que a versão atual seja 10, 11, 12 ou qualquer outra.
- Os exemplos de versão presentes na documentação servem apenas para ilustrar a regra e nunca devem ser utilizados como valores fixos.
- Antes de criar ou alterar qualquer script, revise o PROJECT_CONTEXT.md por completo.
- Caso encontre conflitos entre documentação e scripts, reporte o conflito antes de gerar novas fases.
- Não altere a arquitetura definida no PROJECT_CONTEXT.md sem justificar tecnicamente o motivo.
- Gere apenas a fase que está sendo revisada no momento. Não antecipe implementações de fases futuras.
- Não altere a arquitetura definida no PROJECT_CONTEXT.md sem justificar tecnicamente o motivo.
- Gere apenas a fase que está sendo revisada no momento. Não antecipe implementações de fases futuras.

Segue o PROJECT_CONTEXT.md.

.\Fase-0-Cleanup.ps1
.\Fase-1-Criar-Secrets.ps1
.\Fase-2-Criar-Infrastructure.ps1
.\Fase-3-Criar-Authentication.ps1
.\Fase-4-Authentication-Packages.ps1
.\Fase-5-Authentication-Core.ps1
.\Fase-6-Authentication-Database.ps1
.\