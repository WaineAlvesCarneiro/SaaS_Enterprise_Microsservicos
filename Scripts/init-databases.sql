-- Criando bancos isolados para garantir o padrão Database-per-Service
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Authentication') CREATE DATABASE [Db_Authentication]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Empresa')        CREATE DATABASE [Db_Empresa]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Pessoas')        CREATE DATABASE [Db_Pessoas]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Produtos')       CREATE DATABASE [Db_Produtos]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Pedidos')        CREATE DATABASE [Db_Pedidos]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Estoques')       CREATE DATABASE [Db_Estoques]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Faturamentos')   CREATE DATABASE [Db_Faturamentos]; GO
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Db_Notification')   CREATE DATABASE [Db_Notification]; GO
