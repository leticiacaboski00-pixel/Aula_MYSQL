create database db_views_class;
USE db_views_class;
select* from db_views_class;

-- ============================================================================
-- TECHMARKET: TRANSFORMANDO DADOS OPERACIONAIS EM INTELIGÊNCIA DE NEGÓCIO
-- Script SQL com Criação de Views, Consultas Gerenciais e Análise Técnica
-- SGBD Compatível: MySQL 8.0+
-- ============================================================================

USE techmarket; -- Garantir contexto do banco de dados

-- ============================================================================
-- ETAPA 2 — CONSTRUÇÃO DAS VIEWS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- MISSÃO 1 — A VISÃO CONSOLIDADA DAS VENDAS
-- ----------------------------------------------------------------------------

DROP VIEW IF EXISTS vw_vendas_detalhadas;

CREATE VIEW vw_vendas_detalhadas AS
SELECT 
    p.id AS pedido_id,
    p.data_pedido,
    p.situacao,
    c.id AS cliente_id,
    c.nome AS cliente_nome,
    c.cidade AS cliente_cidade,
    c.estado AS cliente_estado,
    v.id AS vendedor_id,
    v.nome AS vendedor_nome,
    v.equipe AS vendedor_equipe,
    pr.id AS produto_id,
    pr.descricao AS produto_descricao,
    pr.categoria AS produto_categoria,
    ip.quantidade,
    ip.preco_praticado AS preco_unitario,
    ip.desconto AS desconto_percentual,
    (ip.quantidade * ip.preco_praticado) AS valor_bruto,
    ((ip.quantidade * ip.preco_praticado) * (ip.desconto / 100.0)) AS desconto_reais,
    ((ip.quantidade * ip.preco_praticado) * (1 - (ip.desconto / 100.0))) AS valor_faturado
FROM pedidos p
INNER JOIN clientes c ON p.cliente_id = c.id
INNER JOIN vendedores v ON p.vendedor_id = v.id
INNER JOIN itens_pedido ip ON p.id = ip.pedido_id
INNER JOIN produtos pr ON ip.produto_id = pr.id
WHERE LOWER(p.situacao) IN ('faturado', 'pago', 'entregue', 'concluido');

-- M1.1: Todas as vendas organizadas do maior para o menor valor faturado
SELECT * 
FROM vw_vendas_detalhadas
ORDER BY valor_faturado DESC;

-- M1.2: Cinco itens de venda com maior valor faturado (exibindo cliente e produto)
SELECT 
    pedido_id,
    cliente_nome,
    produto_descricao,
    quantidade,
    valor_faturado
FROM vw_vendas_detalhadas
ORDER BY valor_faturado DESC
LIMIT 5;

-- M1.3: Vendas realizadas para clientes do Paraná organizadas por data
SELECT * 
FROM vw_vendas_detalhadas
WHERE UPPER(cliente_estado) = 'PR'
ORDER BY data_pedido ASC;


-- ----------------------------------------------------------------------------
-- MISSÃO 2 — A VISÃO DE DESEMPENHO DOS VENDEDORES
-- ----------------------------------------------------------------------------

DROP VIEW IF EXISTS vw_desempenho_vendedores;

CREATE VIEW vw_desempenho_vendedores AS
SELECT 
    v.id AS vendedor_id,
    v.nome AS vendedor_nome,
    v.equipe AS vendedor_equipe,
    COUNT(DISTINCT p.id) AS qtd_pedidos_faturados,
    COALESCE(SUM(ip.quantidade), 0) AS qtd_unidades_vendidas,
    COALESCE(SUM((ip.quantidade * ip.preco_praticado) * (1 - (ip.desconto / 100.0))), 0) AS faturamento_efetivo
FROM vendedores v
LEFT JOIN pedidos p ON v.id = p.vendedor_id 
    AND LOWER(p.situacao) IN ('faturado', 'pago', 'entregue', 'concluido')
LEFT JOIN itens_pedido ip ON p.id = ip.pedido_id
GROUP BY v.id, v.nome, v.equipe;

-- M2.1: Ranking dos vendedores com maior faturamento e ticket médio por pedido
SELECT 
    vendedor_id,
    vendedor_nome,
    vendedor_equipe,
    qtd_pedidos_faturados,
    faturamento_efetivo,
    CASE 
        WHEN qtd_pedidos_faturados > 0 THEN (faturamento_efetivo / qtd_pedidos_faturados)
        ELSE 0 
    END AS ticket_medio_pedido
FROM vw_desempenho_vendedores
ORDER BY faturamento_efetivo DESC;

-- M2.2: Relatório gerencial com faturamento total e pedidos por equipe comercial
SELECT 
    vendedor_equipe AS equipe,
    SUM(qtd_pedidos_faturados) AS total_pedidos,
    SUM(faturamento_efetivo) AS faturamento_total
FROM vw_desempenho_vendedores
GROUP BY vendedor_equipe
ORDER BY faturamento_total DESC;


-- ----------------------------------------------------------------------------
-- MISSÃO 3 — A VISÃO ESTRATÉGICA DE PRODUTOS
-- ----------------------------------------------------------------------------

DROP VIEW IF EXISTS vw_desempenho_produtos;

CREATE VIEW vw_desempenho_produtos AS
SELECT 
    pr.id AS produto_id,
    pr.descricao AS produto_descricao,
    pr.categoria AS produto_categoria,
    COALESCE(SUM(ip.quantidade), 0) AS qtd_unidades_vendidas,
    COUNT(DISTINCT p.id) AS qtd_pedidos_faturados,
    COALESCE(SUM((ip.quantidade * ip.preco_praticado) * (1 - (ip.desconto / 100.0))), 0) AS receita_gerada
FROM produtos pr
LEFT JOIN itens_pedido ip ON pr.id = ip.produto_id
LEFT JOIN pedidos p ON ip.pedido_id = p.id 
    AND LOWER(p.situacao) IN ('faturado', 'pago', 'entregue', 'concluido')
GROUP BY pr.id, pr.descricao, pr.categoria;

-- M3.1: Produtos com maior receita (quantidade vendida e faturamento)
SELECT 
    produto_id,
    produto_descricao,
    produto_categoria,
    qtd_unidades_vendidas,
    receita_gerada
FROM vw_desempenho_produtos
ORDER BY receita_gerada DESC;

-- M3.2: Categorias com faturamento superior a R$ 2.000,00 e total de unidades
SELECT 
    produto_categoria AS categoria,
    SUM(qtd_unidades_vendidas) AS total_unidades_vendidas,
    SUM(receita_gerada) AS faturamento_total
FROM vw_desempenho_produtos
GROUP BY produto_categoria
HAVING SUM(receita_gerada) > 2000.00
ORDER BY faturamento_total DESC;

-- M3.3: Três produtos com maior valor médio faturado por unidade comercializada
SELECT 
    produto_id,
    produto_descricao,
    produto_categoria,
    qtd_unidades_vendidas,
    receita_gerada,
    CASE 
        WHEN qtd_unidades_vendidas > 0 THEN (receita_gerada / qtd_unidades_vendidas)
        ELSE 0 
    END AS valor_medio_por_unidade
FROM vw_desempenho_produtos
WHERE qtd_unidades_vendidas > 0
ORDER BY valor_medio_por_unidade DESC
LIMIT 3;


-- ----------------------------------------------------------------------------
-- MISSÃO 4 — A VISÃO DE COMPORTAMENTO DOS CLIENTES
-- ----------------------------------------------------------------------------

DROP VIEW IF EXISTS vw_resumo_clientes;

CREATE VIEW vw_resumo_clientes AS
SELECT 
    c.id AS cliente_id,
    c.nome AS cliente_nome,
    c.cidade AS cliente_cidade,
    c.estado AS cliente_estado,
    COUNT(DISTINCT p.id) AS qtd_pedidos_faturados,
    COALESCE(SUM((ip.quantidade * ip.preco_praticado) * (1 - (ip.desconto / 100.0))), 0) AS valor_total_gasto
FROM clientes c
LEFT JOIN pedidos p ON c.id = p.cliente_id 
    AND LOWER(p.situacao) IN ('faturado', 'pago', 'entregue', 'concluido')
LEFT JOIN itens_pedido ip ON p.id = ip.pedido_id
GROUP BY c.id, c.nome, c.cidade, c.estado;

-- M4.1: Ranking dos clientes com maior compras acumuladas e ticket médio
SELECT 
    cliente_id,
    cliente_nome,
    cliente_cidade,
    cliente_estado,
    qtd_pedidos_faturados,
    valor_total_gasto,
    CASE 
        WHEN qtd_pedidos_faturados > 0 THEN (valor_total_gasto / qtd_pedidos_faturados)
        ELSE 0 
    END AS ticket_medio_cliente
FROM vw_resumo_clientes
ORDER BY valor_total_gasto DESC;

-- M4.2: Classificação dos clientes em VIP, Regular e Sem compras
SELECT 
    cliente_id,
    cliente_nome,
    valor_total_gasto,
    CASE 
        WHEN valor_total_gasto >= 5000.00 THEN 'VIP'
        WHEN valor_total_gasto > 0.00 THEN 'Regular'
        ELSE 'Sem compras'
    END AS categoria_cliente
FROM vw_resumo_clientes
ORDER BY valor_total_gasto DESC;

-- M4.3: Faturamento total, clientes cadastrados e média por cliente por estado
SELECT 
    cliente_estado AS estado,
    COUNT(cliente_id) AS total_clientes_cadastrados,
    SUM(valor_total_gasto) AS faturamento_total,
    ROUND(SUM(valor_total_gasto) / COUNT(cliente_id), 2) AS media_faturamento_por_cliente
FROM vw_resumo_clientes
GROUP BY cliente_estado
ORDER BY faturamento_total DESC;


-- ============================================================================
-- ETAPA 3 — INTEGRAÇÃO DE VIEWS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- MISSÃO 5 — O PAINEL EXECUTIVO
-- ----------------------------------------------------------------------------

-- M5.1: Desempenho por equipe comercial (Reutilizando vw_vendas_detalhadas)
SELECT 
    vendedor_equipe AS equipe,
    COUNT(DISTINCT pedido_id) AS total_pedidos_faturados,
    SUM(valor_faturado) AS faturamento_total,
    ROUND(SUM(valor_faturado) / COUNT(DISTINCT pedido_id), 2) AS ticket_medio_equipe
FROM vw_vendas_detalhadas
GROUP BY vendedor_equipe
ORDER BY faturamento_total DESC;

-- M5.2: Participação percentual de cada categoria no faturamento total
SELECT 
    produto_categoria AS categoria,
    SUM(valor_faturado) AS faturamento_categoria,
    ROUND((SUM(valor_faturado) / (SELECT SUM(valor_faturado) FROM vw_vendas_detalhadas)) * 100.0, 2) AS pct_participacao
FROM vw_vendas_detalhadas
GROUP BY produto_categoria
ORDER BY faturamento_categoria DESC;

-- M5.3: Clientes acima da média de compras efetivadas
SELECT 
    cliente_nome,
    cliente_estado,
    valor_total_gasto,
    ROUND(valor_total_gasto - (SELECT AVG(valor_total_gasto) FROM vw_resumo_clientes WHERE valor_total_gasto > 0), 2) AS diferenca_para_media
FROM vw_resumo_clientes
WHERE valor_total_gasto > (SELECT AVG(valor_total_gasto) FROM vw_resumo_clientes WHERE valor_total_gasto > 0)
ORDER BY valor_total_gasto DESC;


-- ============================================================================
-- ETAPA 4 — MANUTENÇÃO E ANÁLISE TÉCNICA
-- ============================================================================

-- ----------------------------------------------------------------------------
-- MISSÃO 6 — UMA NOVA EXIGÊNCIA DA DIRETORIA
-- ----------------------------------------------------------------------------

-- Modificação da VIEW para incluir o desconto total concedido em reais
CREATE OR REPLACE VIEW vw_desempenho_vendedores AS
SELECT 
    v.id AS vendedor_id,
    v.nome AS vendedor_nome,
    v.equipe AS vendedor_equipe,
    COUNT(DISTINCT p.id) AS qtd_pedidos_faturados,
    COALESCE(SUM(ip.quantidade), 0) AS qtd_unidades_vendidas,
    COALESCE(SUM(((ip.quantidade * ip.preco_praticado) * (ip.desconto / 100.0))), 0) AS desconto_total_concedido,
    COALESCE(SUM((ip.quantidade * ip.preco_praticado) * (1 - (ip.desconto / 100.0))), 0) AS faturamento_efetivo
FROM vendedores v
LEFT JOIN pedidos p ON v.id = p.vendedor_id 
    AND LOWER(p.situacao) IN ('faturado', 'pago', 'entregue', 'concluido')
LEFT JOIN itens_pedido ip ON p.id = ip.pedido_id
GROUP BY v.id, v.nome, v.equipe;

-- Reexecução das consultas da Missão 2 para validação:
SELECT 
    vendedor_id,
    vendedor_nome,
    vendedor_equipe,
    qtd_pedidos_faturados,
    desconto_total_concedido,
    faturamento_efetivo,
    CASE 
        WHEN qtd_pedidos_faturados > 0 THEN (faturamento_efetivo / qtd_pedidos_faturados)
        ELSE 0 
    END AS ticket_medio_pedido
FROM vw_desempenho_vendedores
ORDER BY faturamento_efetivo DESC;

SELECT 
    vendedor_equipe AS equipe,
    SUM(qtd_pedidos_faturados) AS total_pedidos,
    SUM(desconto_total_concedido) AS desconto_total_equipe,
    SUM(faturamento_efetivo) AS faturamento_total
FROM vw_desempenho_vendedores
GROUP BY vendedor_equipe
ORDER BY faturamento_total DESC;


-- ============================================================================
-- QUESTÕES DE ANÁLISE TÉCNICA
-- ============================================================================
/*
1. Vantagem de modificar uma VIEW em vez de alterar relatórios individuais:
   R: A alteração centralizada garante consistência das regras de negócio em um único ponto. 
      Evita refatorar dezenas de scripts, reduz riscos de divergência de cálculos e simplifica a manutenção.

2. Diferença entre consultar uma tabela original e consultar uma VIEW:
   R: A tabela armazena dados brutos fisicamente no disco. A VIEW é um objeto lógico (uma consulta armazenada)
      que sintetiza, filtra, calcula e combina dados dinamicamente a partir de tabelas base.

3. Armazenamento físico de VIEWs tradicionais e atualização de dados:
   R: VIEWs tradicionais NÃO armazenam dados fisicamente. Toda vez que uma VIEW é consultada, a query SQL 
      subjacente é executada. Qualquer alteração nos dados das tabelas base reflete-se imediatamente na VIEW.

4. Impacto da exclusão de uma VIEW em relatórios dependentes:
   R: Todos os relatórios, consultas ou relatórios de BI dependentes falharão imediatamente com erro de 
      tabela/visão inexistente (ex: Table 'techmarket.vw_vendas_detalhadas' doesn't exist).

5. Riscos do uso excessivo/aninhado de VIEWs:
   R: Aninhar várias VIEWs sobre VIEWs pode causar queda acentuada de desempenho, impedindo o otimizador do 
      SGBD de utilizar índices de forma eficiente, gerando varreduras de tabela (table scans) desnecessárias.
*/


-- ============================================================================
-- PARECER GERENCIAL
-- ============================================================================
/*
PARECER GERENCIAL: DIAGNÓSTICO COMERCIAL TECHMARKET

A implementação da camada de inteligência com VIEWs permitiu consolidar a visão
operacional da TechMarket, revelando que a maior parte da receita concentra-se
em produtos de categorias periféricas e eletrônicos de alto valor unitário. 
Observou-se uma assimetria no desempenho das equipes comerciais, com destaque
positivo para equipes que mantêm um ticket médio por pedido elevado, ainda que com
menor volume de itens. A análise geográfica indicou que estados como São Paulo e
Paraná lideram em volume de faturamento e densidade de clientes ativos. A nova
segmentação de clientes (VIP vs. Regular vs. Sem Compras) evidenciou uma oportunidade
estratégica para campanhas de reativação da base inativa e ações de fidelização para
o cluster VIP, garantindo previsibilidade de receita e otimização das margens líquidas.
*/