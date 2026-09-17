CREATE DATABASE IF NOT EXISTS loja;
USE loja;

SET SQL_SAFE_UPDATES = 0;

-- ============================================================
-- 1. ESTRUTURA DO BANCO DE DADOS (DDL) E DADOS DE TESTE (DML)
-- ============================================================

DROP TABLE IF EXISTS itens_venda;
DROP TABLE IF EXISTS vendas;
DROP TABLE IF EXISTS produtos;
DROP TABLE IF EXISTS vendedores;
DROP TABLE IF EXISTS clientes;

CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nome_cliente VARCHAR(100) NOT NULL,
    cidade VARCHAR(80) NOT NULL,
    estado CHAR(2) NOT NULL
);

CREATE TABLE vendedores (
    id_vendedor INT PRIMARY KEY AUTO_INCREMENT,
    nome_vendedor VARCHAR(100) NOT NULL,
    setor VARCHAR(50) NOT NULL
);

CREATE TABLE produtos (
    id_produto INT PRIMARY KEY AUTO_INCREMENT,
    nome_produto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    preco_padrao DECIMAL(10,2) NOT NULL
);

CREATE TABLE vendas (
    id_venda INT PRIMARY KEY AUTO_INCREMENT,
    data_venda DATE NOT NULL,
    id_cliente INT NOT NULL,
    id_vendedor INT NOT NULL,
    forma_pagamento VARCHAR(30) NOT NULL,
    status_venda VARCHAR(20) NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_vendas_clientes FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    CONSTRAINT fk_vendas_vendedores FOREIGN KEY (id_vendedor) REFERENCES vendedores(id_vendedor)
) ENGINE=InnoDB;

CREATE TABLE itens_venda (
    id_item INT PRIMARY KEY AUTO_INCREMENT,
    id_venda INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    valor_unitario DECIMAL(10,2) NOT NULL,
    desconto DECIMAL(5,2) DEFAULT 0.00,
    CONSTRAINT fk_itens_venda_vendas FOREIGN KEY (id_venda) REFERENCES vendas(id_venda),
    CONSTRAINT fk_itens_venda_produtos FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
) ENGINE=InnoDB;

-- Inserção de Clientes (com e sem compras)
INSERT INTO clientes (id_cliente, nome_cliente, cidade, estado) VALUES
(1, 'Ana Silva', 'Curitiba', 'PR'),
(2, 'Bruno Souza', 'Rio de Janeiro', 'RJ'),
(3, 'Carla Mendes', 'Curitiba', 'PR'),
(4, 'Daniel Rocha', 'São Paulo', 'SP'),
(5, 'Eduardo Paes', 'Belo Horizonte', 'MG'); -- Cliente sem vendas

-- Inserção de Vendedores (com e sem vendas)
INSERT INTO vendedores (id_vendedor, nome_vendedor, setor) VALUES
(1, 'Carlos Lima', 'Tecnologia'),
(2, 'Fernanda Alves', 'Móveis'),
(3, 'Mariana Costa', 'Eletro'),
(4, 'Roberto Mota', 'Tecnologia'); -- Vendedor sem vendas

-- Inserção de Produtos (com e sem vendas)
INSERT INTO produtos (id_produto, nome_produto, categoria, preco_padrao) VALUES
(1, 'Notebook Pro', 'Informática', 3500.00),
(2, 'Mouse Sem Fio', 'Informática', 80.00),
(3, 'Cadeira Ergonômica', 'Móveis', 1200.00),
(4, 'Teclado Mecânico', 'Informática', 250.00),
(5, 'Monitor 4K', 'Informática', 2200.00); -- Produto sem vendas

-- Inserção de Vendas
INSERT INTO vendas (id_venda, data_venda, id_cliente, id_vendedor, forma_pagamento, status_venda, valor_total) VALUES
(1, '2026-03-15', 1, 1, 'Pix', 'Concluída', 7000.00),
(2, '2026-04-01', 2, 1, 'Cartão de Crédito', 'Cancelada', 160.00),
(3, '2026-05-10', 3, 2, 'Pix', 'Concluída', 1200.00),
(4, '2026-06-20', 1, 3, 'Boleto', 'Concluída', 1000.00);

-- Inserção de Itens da Venda
INSERT INTO itens_venda (id_item, id_venda, id_produto, quantidade, valor_unitario, desconto) VALUES
(1, 1, 1, 2, 3500.00, 0.00),
(2, 2, 2, 2, 80.00, 0.00),
(3, 3, 3, 1, 1200.00, 5.00),
(4, 4, 4, 4, 250.00, 10.00);


-- ============================================================
-- 2. DASHBOARD EXECUTIVO - 15 KPIS ESTRATÉGICOS
-- ============================================================

-- ------------------------------------------------------------
-- KPI 01: Taxa de Inatividade e Retenção da Base de Clientes
-- Objetivo: Identificar clientes ativos e inativos (sem compras) e calcular a taxa de conversão da base de clientes.
-- Requisitos: CTE, LEFT JOIN, COUNT, DISTINCT.
-- ------------------------------------------------------------
WITH resumo_clientes AS (
    SELECT 
        c.id_cliente,
        c.nome_cliente,
        COUNT(v.id_venda) AS total_compras
    FROM clientes c
    LEFT JOIN vendas v ON c.id_cliente = v.id_cliente
    GROUP BY c.id_cliente, c.nome_cliente
)
SELECT 
    COUNT(id_cliente) AS total_clientes_cadastrados,
    COUNT(CASE WHEN total_compras > 0 THEN 1 END) AS clientes_ativos,
    COUNT(CASE WHEN total_compras = 0 THEN 1 END) AS clientes_inativos,
    ROUND((COUNT(CASE WHEN total_compras > 0 THEN 1 END) / COUNT(id_cliente)) * 100, 2) AS taxa_ativacao_pct
FROM resumo_clientes;
/*
Interpretação Esperada:
O indicador demonstra que parte da base cadastrada ainda não gerou nenhuma receita (inativos). 
A diretoria pode usar a taxa de ativação para direcionar campanhas de onboarding e reengajamento para os clientes inativos.
*/


-- ------------------------------------------------------------
-- KPI 02: Eficiência e Produtividade da Equipe Comercial
-- Objetivo: Identificar vendedores que não geraram faturamento e comparar a contribuição de cada um na receita total.
-- Requisitos: CTE, LEFT JOIN, COUNT, SUM, COALESCE, GROUP BY, ORDER BY.
-- ------------------------------------------------------------
WITH vendas_vendedor AS (
    SELECT 
        vend.id_vendedor,
        vend.nome_vendedor,
        vend.setor,
        COUNT(v.id_venda) AS qtd_vendas,
        COALESCE(SUM(CASE WHEN v.status_venda = 'Concluída' THEN v.valor_total ELSE 0 END), 0) AS faturamento_concluido
    FROM vendedores vend
    LEFT JOIN vendas v ON vend.id_vendedor = v.id_vendedor
    GROUP BY vend.id_vendedor, vend.nome_vendedor, vend.setor
)
SELECT 
    id_vendedor,
    nome_vendedor,
    setor,
    qtd_vendas,
    faturamento_concluido
FROM vendas_vendedor
ORDER BY faturamento_concluido DESC;
/*
Interpretação Esperada:
A consulta expõe disparidades na força de vendas, revelando vendedores zerados ou com baixo volume.
A diretoria obtém clareza para redistribuir metas, oferecer treinamentos ou reavaliar a alocação do time.
*/


-- ------------------------------------------------------------
-- KPI 03: Diagnóstico de Estoque Parado (Produtos Sem Vendas)
-- Objetivo: Mapear produtos que nunca foram comercializados e mensurar o capital imobilizado associado.
-- Requisitos: CTE, LEFT JOIN, SUM, GROUP BY, ORDER BY.
-- ------------------------------------------------------------
WITH produtos_sem_saida AS (
    SELECT 
        p.id_produto,
        p.nome_produto,
        p.categoria,
        p.preco_padrao
    FROM produtos p
    LEFT JOIN itens_venda iv ON p.id_produto = iv.id_produto
    WHERE iv.id_item IS NULL
)
SELECT 
    categoria,
    COUNT(id_produto) AS quantidade_produtos_parados,
    SUM(preco_padrao) AS valor_potencial_encalhado
FROM produtos_sem_saida
GROUP BY categoria
ORDER BY valor_potencial_encalhado DESC;
/*
Interpretação Esperada:
Identifica quais categorias possuem itens sem nenhuma tração comercial no mercado.
Permite à gestão de suprimentos aplicar promoções de liquidação ou descontinuar itens sem apelo comercial.
*/


-- ------------------------------------------------------------
-- KPI 04: Análise Recência, Frequência e Valor (RFV) por Cliente
-- Objetivo: Segmentar o comportamento dos compradores ativos através da primeira e última compra e valor acumulado.
-- Requisitos: CTE, INNER JOIN, COUNT, SUM, MIN, MAX, GROUP BY, ORDER BY.
-- ------------------------------------------------------------
WITH perfil_compras AS (
    SELECT 
        c.id_cliente,
        c.nome_cliente,
        COUNT(v.id_venda) AS frequencia_compras,
        SUM(v.valor_total) AS valor_acumulado,
        MIN(v.data_venda) AS primeira_compra,
        MAX(v.data_venda) AS ultima_compra
    FROM clientes c
    INNER JOIN vendas v ON c.id_cliente = v.id_cliente
    WHERE v.status_venda = 'Concluída'
    GROUP BY c.id_cliente, c.nome_cliente
)
SELECT 
    id_cliente,
    nome_cliente,
    frequencia_compras,
    valor_acumulado,
    primeira_compra,
    ultima_compra
FROM perfil_compras
ORDER BY valor_acumulado DESC;
/*
Interpretação Esperada:
Permite ranquear os clientes VIPs (maior valor e frequência) e monitorar a recência das compras.
Possibilita ao marketing criar estratégias de fidelização exclusivas para os melhores compradores.
*/


-- ------------------------------------------------------------
-- KPI 05: Faturamento Médio por Unidade Territorial (Estado/Cidade)
-- Objetivo: Mapear a representatividade geográfica e a média de valor gasto por cidade.
-- Requisitos: CTE, INNER JOIN, AVG, SUM, COUNT, GROUP BY, ORDER BY.
-- ------------------------------------------------------------
WITH faturamento_geografico AS (
    SELECT 
        c.estado,
        c.cidade,
        COUNT(v.id_venda) AS total_pedidos,
        SUM(v.valor_total) AS faturamento_total,
        AVG(v.valor_total) AS valor_medio_pedido
    FROM clientes c
    INNER JOIN vendas v ON c.id_cliente = v.id_cliente
    WHERE v.status_venda = 'Concluída'
    GROUP BY c.estado, c.cidade
)
SELECT 
    estado,
    cidade,
    total_pedidos,
    faturamento_total,
    ROUND(valor_medio_pedido, 2) AS ticket_medio_regiao
FROM faturamento_geografico
ORDER BY faturamento_total DESC;
/*
Interpretação Esperada:
Demonstra quais regiões entregam maior volume de caixa e maior valor por transação.
Ajuda a diretoria de expansão a focar em investimentos logísticos e de mídia onde o ticket médio é superior.
*/


-- ------------------------------------------------------------
-- KPI 06: Taxa de Cancelamento e Perda Financeira por Forma de Pagamento
-- Objetivo: Identificar quais formas de pagamento apresentam maior vulnerabilidade a cancelamentos.
-- Requisitos: INNER JOIN, COUNT, SUM, GROUP BY, ORDER BY.
-- ------------------------------------------------------------
SELECT 
    forma_pagamento,
    COUNT(id_venda) AS total_transacoes,
    COUNT(CASE WHEN status_venda = 'Cancelada' THEN 1 END) AS transacoes_canceladas,
    COALESCE(SUM(CASE WHEN status_venda = 'Cancelada' THEN valor_total ELSE 0 END), 0) AS receita_perdida,
    ROUND((COUNT(CASE WHEN status_venda = 'Cancelada' THEN 1 END) / COUNT(id_venda)) * 100, 2) AS taxa_cancelamento_pct
FROM vendas
GROUP BY forma_pagamento
ORDER BY receita_perdida DESC;
/*
Interpretação Esperada:
Expõe falhas operacionais ou de risco financeiro associadas a certos métodos de pagamento (ex: boleto não pago ou fraudes em cartão).
Permite ajustar regras de checkout e oferecer incentivos para meios de pagamento com menor atrito (ex: Pix).
*/


-- ------------------------------------------------------------
-- KPI 07: Impacto da Política de Descontos no Valor Unitário por Categoria
-- Objetivo: Analisar o desconto médio concedido e o volume de produtos vendidos por categoria.
-- Requisitos: INNER JOIN, AVG, SUM, GROUP BY, ORDER BY.
-- ------------------------------------------------------------
SELECT 
    p.categoria,
    SUM(iv.quantidade) AS volume_unidades_vendidas,
    ROUND(AVG(iv.desconto), 2) AS desconto_medio_porcento,
    ROUND(SUM(iv.quantidade * iv.valor_unitario * (iv.desconto / 100)), 2) AS total_concedido_desconto
FROM itens_venda iv
INNER JOIN produtos p ON iv.id_produto = p.id_produto
INNER JOIN vendas v ON iv.id_venda = v.id_venda
WHERE v.status_venda = 'Concluída'
GROUP BY p.categoria
ORDER BY total_concedido_desconto DESC;
/*
Interpretação Esperada:
Mede o quanto a empresa abre mão de margem para faturar em cada categoria.
Evita concessões exageradas de descontos pela equipe comercial sem o devido retorno em volume de vendas.
*/


-- ------------------------------------------------------------
-- KPI 08: Amplitude e Intervalo de Preços dos Pedidos Concluídos
-- Objetivo: Identificar os limites (mínimo, máximo e médio) dos valores transacionados na empresa.
-- Requisitos: INNER JOIN, MIN, MAX, AVG, SUM, COUNT.
-- ------------------------------------------------------------
SELECT 
    COUNT(id_venda) AS total_pedidos_concluidos,
    MIN(valor_total) AS menor_pedido_valor,
    MAX(valor_total) AS maior_pedido_valor,
    ROUND(AVG(valor_total), 2) AS valor_medio_pedido,
    SUM(valor_total) AS receita_bruta_total
FROM vendas
WHERE status_venda = 'Concluída';
/*
Interpretação Esperada:
Proporciona uma visão rápida sobre a dispersão do tamanho dos contratos/pedidos da empresa.
Oferece uma linha de base estratégica para o estabelecimento de metas de Upsell e Cross-sell.
*/


-- ------------------------------------------------------------
-- KPI 09: Participação da Categoria no Faturamento Total da Empresa
-- Objetivo: Calcular o faturamento bruto obtido em cada categoria de produtos comercializados.
-- Requisitos: INNER JOIN, SUM, GROUP BY, ORDER BY.
-- ------------------------------------------------------------
SELECT 
    p.categoria,
    SUM(iv.quantidade) AS itens_vendidos,
    ROUND(SUM(iv.quantidade * iv.valor_unitario * (1 - iv.desconto / 100)), 2) AS faturamento_liquido
FROM itens_venda iv
INNER JOIN produtos p ON iv.id_produto = p.id_produto
INNER JOIN vendas v ON iv.id_venda = v.id_venda
WHERE v.status_venda = 'Concluída'
GROUP BY p.categoria
ORDER BY faturamento_liquido DESC;
/*
Interpretação Esperada:
Mapeia o core business da empresa e a dependência financeira em relação a determinadas linhas de produtos.
Orienta decisões de portfólio e compras estratégicas junto aos fornecedores.
*/


-- ------------------------------------------------------------
-- KPI 10: Performance de Vendas por Setor Operacional
-- Objetivo: Avaliar o volume financeiro gerado por cada setor da equipe comercial.
-- Requisitos: INNER JOIN, SUM, COUNT, GROUP BY, ORDER BY.
-- ------------------------------------------------------------
SELECT 
    vend.setor,
    COUNT(DISTINCT vend.id_vendedor) AS total_vendedores,
    COUNT(v.id_venda) AS total_vendas_realizadas,
    SUM(v.valor_total) AS faturamento_gerado
FROM vendedores vend
INNER JOIN vendas v ON vend.id_vendedor = v.id_vendedor
WHERE v.status_venda = 'Concluída'
GROUP BY vend.setor
ORDER BY faturamento_gerado DESC;
/*
Interpretação Esperada:
Avalia quais divisões comerciais estão trazendo os melhores resultados para a organização.
Auxilia a diretoria a alocar orçamentos de contratação nos setores mais rentáveis.
*/


-- ------------------------------------------------------------
-- KPI 11: Média de Itens por Pedido (Basket Size) por Cliente
-- Objetivo: Identificar o número médio de itens comprados em cada transação por cliente.
-- Requisitos: INNER JOIN, AVG, SUM, COUNT, GROUP BY, ORDER BY.
-- ------------------------------------------------------------
SELECT 
    c.id_cliente,
    c.nome_cliente,
    COUNT(DISTINCT v.id_venda) AS total_pedidos,
    SUM(iv.quantidade) AS total_itens_comprados,
    ROUND(SUM(iv.quantidade) / COUNT(DISTINCT v.id_venda), 2) AS media_itens_por_pedido
FROM clientes c
INNER JOIN vendas v ON c.id_cliente = v.id_cliente
INNER JOIN itens_venda iv ON v.id_venda = iv.id_venda
WHERE v.status_venda = 'Concluída'
GROUP BY c.id_cliente, c.nome_cliente
ORDER BY media_itens_por_pedido DESC;
/*
Interpretação Esperada:
Determina a capacidade dos vendedores em realizar vendas casadas (múltiplos itens na mesma compra).
Indica o nível de diversificação do carrinho de compras dos clientes ativos.
*/


-- ------------------------------------------------------------
-- KPI 12: Ranking de Produtos por Volume de Venda e Preço Médio Praticado
-- Objetivo: Identificar os produtos mais populares e o preço real médio cobrado pós-desconto.
-- Requisitos: INNER JOIN, SUM, AVG, GROUP BY, ORDER BY.
-- ------------------------------------------------------------
SELECT 
    p.id_produto,
    p.nome_produto,
    p.categoria,
    SUM(iv.quantidade) AS unidades_vendidas,
    ROUND(AVG(iv.valor_unitario * (1 - iv.desconto / 100)), 2) AS preco_efetivo_medio
FROM produtos p
INNER JOIN itens_venda iv ON p.id_produto = iv.id_produto
INNER JOIN vendas v ON iv.id_venda = v.id_venda
WHERE v.status_venda = 'Concluída'
GROUP BY p.id_produto, p.nome_produto, p.categoria
ORDER BY unidades_vendidas DESC;
/*
Interpretação Esperada:
Destaca os produtos campeões de vendas e avalia se o preço praticado na ponta sofreu muita distorção em relação ao preço tabela.
Essencial para planejar reposição de estoque dos produtos de alta rotatividade.
*/


-- ------------------------------------------------------------
-- KPI 13: Volume de Faturamento Trimestral/Mensal e Histórico de Vendas
-- Objetivo: Acompanhar a evolução temporal do faturamento da empresa.
-- Requisitos: INNER JOIN, SUM, COUNT, GROUP BY, ORDER BY.
-- ------------------------------------------------------------
SELECT 
    DATE_FORMAT(v.data_venda, '%Y-%m') AS mes_ano,
    COUNT(v.id_venda) AS quantidade_vendas,
    SUM(v.valor_total) AS faturamento_mensal
FROM vendas v
WHERE v.status_venda = 'Concluída'
GROUP BY DATE_FORMAT(v.data_venda, '%Y-%m')
ORDER BY mes_ano ASC;
/*
Interpretação Esperada:
Demonstra o ritmo de crescimento e a sazonalidade do faturamento ao longo dos meses.
Fornece suporte para projeções financeiras e planejamento de fluxo de caixa futuro.
*/


-- ------------------------------------------------------------
-- KPI 14: Diversificação de Clientes por Vendedor (Capacidade de Prospectar)
-- Objetivo: Mensurar quantos clientes distintos cada vendedor atendeu no período.
-- Requisitos: INNER JOIN, COUNT, DISTINCT, GROUP BY, ORDER BY.
-- ------------------------------------------------------------
SELECT 
    vend.id_vendedor,
    vend.nome_vendedor,
    COUNT(DISTINCT v.id_cliente) AS clientes_unicos_atendidos,
    COUNT(v.id_venda) AS total_vendas_fechadas
FROM vendedores vend
INNER JOIN vendas v ON vend.id_vendedor = v.id_vendedor
WHERE v.status_venda = 'Concluída'
GROUP BY vend.id_vendedor, vend.nome_vendedor
ORDER BY clientes_unicos_atendidos DESC;
/*
Interpretação Esperada:
Avalia se a carteira de vendas do vendedor está concentrada em poucos clientes ou bem pulverizada.
Vendedores focados em poucos clientes geram maior risco de receita caso um cliente decida cancelar.
*/


-- ------------------------------------------------------------
-- KPI 15: Concentração de Vendas de Alto Valor (Pedidos Acima do Ticket Médio Geral)
-- Objetivo: Filtrar os pedidos de alto impacto financeiro (acima da média geral) para priorização de pós-venda.
-- Requisitos: INNER JOIN, AVG, SUM, GROUP BY, ORDER BY.
-- ------------------------------------------------------------
SELECT 
    v.id_venda,
    v.data_venda,
    c.nome_cliente,
    vend.nome_vendedor,
    v.valor_total
FROM vendas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN vendedores vend ON v.id_vendedor = vend.id_vendedor
WHERE v.status_venda = 'Concluída' 
  AND v.valor_total > (SELECT AVG(valor_total) FROM vendas WHERE status_venda = 'Concluída')
ORDER BY v.valor_total DESC;
/*
Interpretação Esperada:
Mapeia quais transações foram fundamentais para impulsionar a receita da empresa.
Permite ao time de CS (Customer Success) e pós-venda monitorar de perto esses grandes clientes para garantir retenção.
*/

SET SQL_SAFE_UPDATES = 1;