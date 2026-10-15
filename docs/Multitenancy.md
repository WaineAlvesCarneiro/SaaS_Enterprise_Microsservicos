# Multi-Tenancy

## Objetivo

Isolar os dados e as operações de cada empresa (tenant) na plataforma SaaS.

---

# Identidade do tenant

Authentication emite JWT. Quando uma identidade estiver associada a um tenant, o token deve carregar o identificador do tenant para que os serviços possam determinar o contexto da requisição.

```text
Usuário autenticado
    ↓
JWT validado
    ↓
TenantId obtido das claims
    ↓
Operação limitada ao tenant
```

A representação e o ciclo de vida dos tenants pertencem ao serviço Tenancy. O relacionamento concreto entre usuários e tenants será definido ao implementar os modelos; não se deve presumir que um valor fornecido pelo cliente seja confiável.

---

# Regra de segurança

Nunca use um `TenantId` enviado no corpo, query string ou cabeçalho pelo cliente como fonte de autorização. Os serviços devem validar o JWT e obter o tenant das claims validadas. Caso a operação aceite um identificador de tenant no recurso, compare-o com o contexto autenticado e rejeite incompatibilidades.

---

# Isolamento de dados

Cada microsserviço possui seu próprio banco e é responsável por aplicar o isolamento em suas consultas e alterações. Entidades que armazenam dados pertencentes a um tenant devem carregar a associação necessária para filtragem e autorização. Nenhum serviço consulta diretamente o banco de outro.

---

# Implementação por etapas

A resolução do TenantId e os filtros de persistência serão implementados nos serviços que precisarem deles, respeitando a separação entre Application e Infrastructure. O projeto ainda não fixa uma interface ou implementação compartilhada de `ITenantProvider`; esse contrato deve ser criado quando houver um caso de uso concreto, sem introduzir dependências entre microsserviços.

---

# Objetivos da primeira versão

- Transportar o TenantId nas claims JWT para usuários associados a um tenant.
- Resolver o contexto do tenant a partir de um token validado.
- Filtrar e autorizar operações por tenant em cada serviço aplicável.
- Testar que dados de um tenant não são visíveis nem alteráveis por outro.