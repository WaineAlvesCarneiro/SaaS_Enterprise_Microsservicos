# Copilot Instructions

## Diretrizes de projeto
- Os scripts *.ps1 estão todos localizados na raiz do repositório: D:\Projetos\SaaS_Enterprise_Microsservicos\*.ps1.
- O projeto Authentication deve funcionar tanto localmente no Visual Studio quanto em containers Docker/Docker Swarm, preservando a leitura de Docker Secrets no ambiente Docker e usando configuração/variáveis locais fora do Docker. O fluxo do projeto deve evitar scripts PowerShell duplicados; a criação e inicialização dos Docker Secrets deve permanecer consolidada em Fase-1-Criar-Secrets.ps1.
- O script de deploy da Authentication usa o nome Fase-11-Deploy-Authentication.ps1; a documentação e referências devem manter essa nomenclatura.