CREATE DATABASE IF NOT EXISTS loja;
USE loja;

SET SQL_SAFE_UPDATES = 0;

-- ============================================================
-- 1. ESTRUTURA DO BANCO DE DADOS (DDL) E DADOS DE TESTE (DML)
-- ============================================================

DROP TABLE IF EXISTS clientes_empresa_adquirida;
DROP TABLE IF EXISTS clientes_techvendas;
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

-- Tabelas auxiliares para os Exercícios 12 e 13 (Integração e Fusão)
CREATE TABLE clientes_techvendas (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nome_cliente VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL
);

CREATE TABLE clientes_empresa_adquirida (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nome_cliente VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL
);

-- Inserção de Dados - Clientes
INSERT INTO clientes (id_cliente, nome_cliente, cidade, estado) VALUES
(1, 'Ana Silva', 'Curitiba', 'PR'),
(2, 'Bruno Souza', 'Rio de Janeiro', 'RJ'),
(3, 'Carla Mendes', 'Curitiba', 'PR'),
(4, 'Daniel Rocha', 'São Paulo', 'SP'),
(5, 'Eduardo Paes', 'Belo Horizonte', 'MG'); -- Cliente sem compras

-- Inserção de Dados - Vendedores
INSERT INTO vendedores (id_vendedor, nome_vendedor, setor) VALUES
(1, 'Carlos Lima', 'Tecnologia'),
(2, 'Fernanda Alves', 'Móveis'),
(3, 'Mariana Costa', 'Eletro'),
(4, 'Roberto Mota', 'Tecnologia'); -- Vendedor sem vendas

-- Inserção de Dados - Produtos
INSERT INTO produtos (id_produto, nome_produto, categoria, preco_padrao) VALUES
(1, 'Notebook Pro', 'Informática', 3500.00),
(2, 'Mouse Sem Fio', 'Informática', 80.00),
(3, 'Cadeira Ergonômica', 'Móveis', 1200.00),
(4, 'Teclado Mecânico', 'Informática', 250.00),
(5, 'Monitor 4K', 'Informática', 2200.00); -- Produto sem vendas

-- Inserção de Dados - Vendas
INSERT INTO vendas (id_venda, data_venda, id_cliente, id_vendedor, forma_pagamento, status_venda, valor_total) VALUES
(1, '2026-03-15', 1, 1, 'Pix', 'Concluída', 7000.00),
(2, '2026-04-01', 2, 1, 'Cartão de Crédito', 'Cancelada', 160.00),
(3, '2026-05-10', 3, 2, 'Pix', 'Concluída', 1200.00),
(4, '2026-06-20', 1, 3, 'Boleto', 'Concluída', 1000.00);

-- Inserção de Dados - Itens de Venda
INSERT INTO itens_venda (id_item, id_venda, id_produto, quantidade, valor_unitario, desconto) VALUES
(1, 1, 1, 2, 3500.00, 0.00),
(2, 2, 2, 2, 80.00, 0.00),
(3, 3, 3, 1, 1200.00, 5.00),
(4, 4, 4, 4, 250.00, 10.00);

-- Dados para Exercícios de Integração de Sistemas (12 e 13)
INSERT INTO clientes_techvendas (id_cliente, nome_cliente, email) VALUES
(1, 'Ana Silva', 'ana@tech.com'),
(2, 'Bruno Souza', 'bruno@tech.com'),
(3, 'Carla Mendes', 'carla@tech.com');

INSERT INTO clientes_empresa_adquirida (id_cliente, nome_cliente, email) VALUES
(1, 'Bruno Souza', 'bruno@tech.com'), -- Presente em ambas
(2, 'Daniel Rocha', 'daniel@adquirida.com'), -- Apenas na adquirida
(3, 'Eduardo Paes', 'eduardo@adquirida.com'); -- Apenas na adquirida


-- ============================================================
-- 2. EXERCÍCIOS DE FIXAÇÃO - CHALLENGE NIGHT II
-- ============================================================

-- ------------------------------------------------------------
-- Exercício 01 – Clientes e Compras
-- ------------------------------------------------------------
SELECT 
    c.nome_cliente,
    c.cidade,
    COUNT(v.id_venda) AS quantidade_compras,
    COALESCE(SUM(CASE WHEN v.status_venda = 'Concluída' THEN v.valor_total ELSE 0 END), 0.00) AS valor_total_comprado
FROM clientes c
LEFT JOIN vendas v ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nome_cliente, c.cidade;

-- ------------------------------------------------------------
-- Exercício 02 – Produtos Comercializados
-- ------------------------------------------------------------
SELECT 
    p.nome_produto,
    p.categoria,
    COALESCE(SUM(iv.quantidade), 0) AS quantidade_vendida,
    COALESCE(SUM(iv.quantidade * iv.valor_unitario * (1 - iv.desconto / 100)), 0.00) AS faturamento
FROM produtos p
LEFT JOIN itens_venda iv ON p.id_produto = iv.id_produto
LEFT JOIN vendas v ON iv.id_venda = v.id_venda AND v.status_venda = 'Concluída'
GROUP BY p.id_produto, p.nome_produto, p.categoria;

-- ------------------------------------------------------------
-- Exercício 03 – Desempenho dos Vendedores
-- ------------------------------------------------------------
SELECT 
    vend.nome_vendedor,
    vend.setor,
    COUNT(v.id_venda) AS quantidade_vendas,
    COALESCE(SUM(CASE WHEN v.status_venda = 'Concluída' THEN v.valor_total ELSE 0 END), 0.00) AS faturamento
FROM vendedores vend
LEFT JOIN vendas v ON vend.id_vendedor = v.id_vendedor
GROUP BY vend.id_vendedor, vend.nome_vendedor, vend.setor;

-- ------------------------------------------------------------
-- Exercício 04 – Auditoria de Clientes
-- ------------------------------------------------------------
WITH cte_clientes_compras AS (
    SELECT DISTINCT id_cliente
    FROM vendas
)
SELECT 
    c.id_cliente,
    c.nome_cliente,
    c.cidade
FROM clientes c
LEFT JOIN cte_clientes_compras cc ON c.id_cliente = cc.id_cliente
WHERE cc.id_cliente IS NULL;

-- ------------------------------------------------------------
-- Exercício 05 – Auditoria de Produtos
-- ------------------------------------------------------------
WITH cte_produtos_vendidos AS (
    SELECT DISTINCT id_produto
    FROM itens_venda
)
SELECT 
    p.id_produto,
    p.nome_produto,
    p.categoria
FROM produtos p
LEFT JOIN cte_produtos_vendidos pv ON p.id_produto = pv.id_produto
WHERE pv.id_produto IS NULL;

-- ------------------------------------------------------------
-- Exercício 06 – Ranking Comercial
-- ------------------------------------------------------------
WITH cte_faturamento_vendedor AS (
    SELECT 
        vend.id_vendedor,
        vend.nome_vendedor,
        COALESCE(SUM(CASE WHEN v.status_venda = 'Concluída' THEN v.valor_total ELSE 0 END), 0) AS faturamento
    FROM vendedores vend
    LEFT JOIN vendas v ON vend.id_vendedor = v.id_vendedor
    GROUP BY vend.id_vendedor, vend.nome_vendedor
)
SELECT 
    nome_vendedor,
    faturamento,
    CASE 
        WHEN faturamento >= 5000 THEN 'Excelente'
        WHEN faturamento >= 1000 THEN 'Bom'
        WHEN faturamento > 0 THEN 'Regular'
        ELSE 'Sem vendas'
    END AS classificacao
FROM cte_faturamento_vendedor
ORDER BY faturamento DESC;

-- ------------------------------------------------------------
-- Exercício 07 – Produtos acima da Média
-- ------------------------------------------------------------
WITH cte_faturamento_produto AS (
    SELECT 
        p.id_produto,
        p.nome_produto,
        COALESCE(SUM(iv.quantidade * iv.valor_unitario * (1 - iv.desconto / 100)), 0) AS faturamento
    FROM produtos p
    LEFT JOIN itens_venda iv ON p.id_produto = iv.id_produto
    LEFT JOIN vendas v ON iv.id_venda = v.id_venda AND v.status_venda = 'Concluída'
    GROUP BY p.id_produto, p.nome_produto
),
cte_media_geral AS (
    SELECT AVG(faturamento) AS media_faturamento FROM cte_faturamento_produto
)
SELECT 
    fp.nome_produto,
    fp.faturamento
FROM cte_faturamento_produto fp, cte_media_geral mg
WHERE fp.faturamento > mg.media_faturamento;

-- ------------------------------------------------------------
-- Exercício 08 – Categorias Estratégicas
-- ------------------------------------------------------------
SELECT 
    p.categoria,
    COUNT(DISTINCT p.id_produto) AS quantidade_produtos,
    COUNT(DISTINCT CASE WHEN iv.id_item IS NOT NULL THEN p.id_produto END) AS produtos_vendidos,
    COUNT(DISTINCT CASE WHEN iv.id_item IS NULL THEN p.id_produto END) AS produtos_nunca_vendidos,
    COALESCE(SUM(CASE WHEN v.status_venda = 'Concluída' THEN iv.quantidade * iv.valor_unitario * (1 - iv.desconto / 100) ELSE 0 END), 0.00) AS faturamento
FROM produtos p
LEFT JOIN itens_venda iv ON p.id_produto = iv.id_produto
LEFT JOIN vendas v ON iv.id_venda = v.id_venda
GROUP BY p.categoria;

-- ------------------------------------------------------------
-- Exercício 09 – Dashboard de Clientes
-- ------------------------------------------------------------
WITH cte_dados_clientes AS (
    SELECT 
        c.id_cliente,
        c.nome_cliente,
        COUNT(v.id_venda) AS quantidade_compras,
        COALESCE(SUM(CASE WHEN v.status_venda = 'Concluída' THEN v.valor_total ELSE 0 END), 0) AS valor_total
    FROM clientes c
    LEFT JOIN vendas v ON c.id_cliente = v.id_cliente
    GROUP BY c.id_cliente, c.nome_cliente
)
SELECT 
    nome_cliente,
    quantidade_compras,
    valor_total,
    ROUND(CASE WHEN quantidade_compras > 0 THEN valor_total / quantidade_compras ELSE 0 END, 2) AS ticket_medio,
    CASE 
        WHEN valor_total > 5000 THEN 'Cliente VIP'
        WHEN valor_total > 0 THEN 'Cliente Ativo'
        ELSE 'Sem Compras'
    END AS classificacao
FROM cte_dados_clientes;

-- ------------------------------------------------------------
-- Exercício 10 – Dashboard de Produtos
-- ------------------------------------------------------------
WITH cte_vendas_produtos AS (
    SELECT 
        p.id_produto,
        p.nome_produto,
        COALESCE(SUM(iv.quantidade), 0) AS quantidade_vendida,
        COALESCE(SUM(CASE WHEN v.status_venda = 'Concluída' THEN iv.quantidade * iv.valor_unitario * (1 - iv.desconto / 100) ELSE 0 END), 0) AS valor_vendido
    FROM produtos p
    LEFT JOIN itens_venda iv ON p.id_produto = iv.id_produto
    LEFT JOIN vendas v ON iv.id_venda = v.id_venda
    GROUP BY p.id_produto, p.nome_produto
),
cte_total_geral AS (
    SELECT SUM(valor_vendido) AS total_vendas FROM cte_vendas_produtos
)
SELECT 
    vp.nome_produto,
    vp.quantidade_vendida,
    vp.valor_vendido,
    ROUND(COALESCE((vp.valor_vendido / NULLIF(tg.total_vendas, 0)) * 100, 0), 2) AS percentual_participacao
FROM cte_vendas_produtos vp, cte_total_geral tg;

-- ------------------------------------------------------------
-- Exercício 11 – Auditoria Completa
-- ------------------------------------------------------------
SELECT 
    p.id_produto,
    p.nome_produto,
    CASE 
        WHEN iv.id_item IS NOT NULL THEN 'Produto Vendido'
        ELSE 'Produto Nunca Vendido'
    END AS status_auditoria
FROM produtos p
LEFT JOIN itens_venda iv ON p.id_produto = iv.id_produto
GROUP BY p.id_produto, p.nome_produto, status_auditoria;
/*
Explicação: Utilizou-se o LEFT JOIN partindo da tabela 'produtos' (lista de cadastrados) 
em direção à tabela 'itens_venda' (lista de vendidos). O LEFT JOIN garante que todos os produtos 
cadastrados permaneçam no resultado, atribuindo NULL aos dados da tabela da direita quando não houver 
correspondência de vendas.
*/

-- ------------------------------------------------------------
-- Exercício 12 – Integração de Sistemas (Simulação de FULL OUTER JOIN)
-- ------------------------------------------------------------
SELECT 
    t.email AS email_tech,
    a.email AS email_adquirida,
    COALESCE(t.nome_cliente, a.nome_cliente) AS nome_cliente,
    CASE 
        WHEN t.email IS NOT NULL AND a.email IS NOT NULL THEN 'Presente em Ambas'
        WHEN t.email IS NOT NULL THEN 'Apenas na TechVendas'
        ELSE 'Apenas na Empresa Adquirida'
    END AS status_integracao
FROM clientes_techvendas t
LEFT JOIN clientes_empresa_adquirida a ON t.email = a.email

UNION

SELECT 
    t.email AS email_tech,
    a.email AS email_adquirida,
    COALESCE(t.nome_cliente, a.nome_cliente) AS nome_cliente,
    CASE 
        WHEN t.email IS NOT NULL AND a.email IS NOT NULL THEN 'Presente em Ambas'
        WHEN t.email IS NOT NULL THEN 'Apenas na TechVendas'
        ELSE 'Apenas na Empresa Adquirida'
    END AS status_integracao
FROM clientes_techvendas t
RIGHT JOIN clientes_empresa_adquirida a ON t.email = a.email;

-- ------------------------------------------------------------
-- Exercício 13 – Auditoria de Cadastros
-- ------------------------------------------------------------
WITH cte_base_unificada AS (
    SELECT 
        t.email AS email_tech,
        a.email AS email_adquirida
    FROM clientes_techvendas t
    LEFT JOIN clientes_empresa_adquirida a ON t.email = a.email
    UNION
    SELECT 
        t.email AS email_tech,
        a.email AS email_adquirida
    FROM clientes_techvendas t
    RIGHT JOIN clientes_empresa_adquirida a ON t.email = a.email
)
SELECT 
    COUNT(CASE WHEN email_tech IS NOT NULL AND email_adquirida IS NULL THEN 1 END) AS apenas_base_antiga,
    COUNT(CASE WHEN email_tech IS NULL AND email_adquirida IS NOT NULL THEN 1 END) AS apenas_base_nova,
    COUNT(CASE WHEN email_tech IS NOT NULL AND email_adquirida IS NOT NULL THEN 1 END) AS presentes_em_ambas
FROM cte_base_unificada;

-- ------------------------------------------------------------
-- Exercício 14 – Dashboard Executivo (Múltiplas CTEs)
-- ------------------------------------------------------------
WITH cte_desempenho_vendedor AS (
    SELECT 
        v.id_vendedor,
        COUNT(DISTINCT v.id_cliente) AS qtd_clientes,
        COUNT(v.id_venda) AS qtd_vendas,
        COALESCE(SUM(CASE WHEN v.status_venda = 'Concluída' THEN v.valor_total ELSE 0 END), 0) AS faturamento_total,
        ROUND(COALESCE(AVG(CASE WHEN v.status_venda = 'Concluída' THEN v.valor_total END), 0), 2) AS ticket_medio
    FROM vendas v
    GROUP BY v.id_vendedor
),
cte_melhor_produto_vendedor AS (
    SELECT 
        v.id_vendedor,
        p.nome_produto,
        RANK() OVER (PARTITION BY v.id_vendedor ORDER BY SUM(iv.quantidade) DESC) AS rnk
    FROM vendas v
    INNER JOIN itens_venda iv ON v.id_venda = iv.id_venda
    INNER JOIN produtos p ON iv.id_produto = p.id_produto
    WHERE v.status_venda = 'Concluída'
    GROUP BY v.id_vendedor, p.nome_produto
),
cte_melhor_categoria_vendedor AS (
    SELECT 
        v.id_vendedor,
        p.categoria,
        RANK() OVER (PARTITION BY v.id_vendedor ORDER BY SUM(iv.quantidade * iv.valor_unitario) DESC) AS rnk
    FROM vendas v
    INNER JOIN itens_venda iv ON v.id_venda = iv.id_venda
    INNER JOIN produtos p ON iv.id_produto = p.id_produto
    WHERE v.status_venda = 'Concluída'
    GROUP BY v.id_vendedor, p.categoria
)
SELECT 
    vend.nome_vendedor,
    COALESCE(dv.qtd_clientes, 0) AS quantidade_clientes,
    COALESCE(dv.qtd_vendas, 0) AS quantidade_vendas,
    COALESCE(dv.ticket_medio, 0.00) AS ticket_medio,
    COALESCE(mp.nome_produto, 'N/A') AS melhor_produto,
    COALESCE(mc.categoria, 'N/A') AS melhor_categoria
FROM vendedores vend
LEFT JOIN cte_desempenho_vendedor dv ON vend.id_vendedor = dv.id_vendedor
LEFT JOIN cte_melhor_produto_vendedor mp ON vend.id_vendedor = mp.id_vendedor AND mp.rnk = 1
LEFT JOIN cte_melhor_categoria_vendedor mc ON vend.id_vendedor = mc.id_vendedor AND mc.rnk = 1;

-- ------------------------------------------------------------
-- Exercício 15 – Painel de Auditoria Geral
-- ------------------------------------------------------------
WITH cte_auditoria_clientes AS (
    SELECT 
        COUNT(c.id_cliente) AS total_clientes,
        COUNT(DISTINCT v.id_cliente) AS clientes_ativos,
        COUNT(c.id_cliente) - COUNT(DISTINCT v.id_cliente) AS clientes_sem_compras
    FROM clientes c
    LEFT JOIN vendas v ON c.id_cliente = v.id_cliente
),
cte_auditoria_produtos AS (
    SELECT 
        COUNT(p.id_produto) AS total_produtos,
        COUNT(DISTINCT iv.id_produto) AS produtos_vendidos,
        COUNT(p.id_produto) - COUNT(DISTINCT iv.id_produto) AS produtos_sem_vendas
    FROM produtos p
    LEFT JOIN itens_venda iv ON p.id_produto = iv.id_produto
),
cte_auditoria_vendedores AS (
    SELECT 
        COUNT(vend.id_vendedor) AS total_vendedores,
        COUNT(DISTINCT v.id_vendedor) AS vendedores_ativos,
        COUNT(vend.id_vendedor) - COUNT(DISTINCT v.id_vendedor) AS vendedores_sem_vendas
    FROM vendedores vend
    LEFT JOIN vendas v ON vend.id_vendedor = v.id_vendedor
),
cte_faturamento_global AS (
    SELECT 
        COALESCE(SUM(valor_total), 0) AS faturamento_acumulado
    FROM vendas
    WHERE status_venda = 'Concluída'
),
cte_painel_unificado AS (
    SELECT * 
    FROM cte_auditoria_clientes
    CROSS JOIN cte_auditoria_produtos
    CROSS JOIN cte_auditoria_vendedores
    CROSS JOIN cte_faturamento_global
)
SELECT 
    total_clientes AS clientes_cadastrados,
    clientes_ativos,
    clientes_sem_compras,
    total_produtos AS produtos_cadastrados,
    produtos_vendidos,
    produtos_sem_vendas,
    total_vendedores AS vendedores_cadastrados,
    vendedores_ativos,
    vendedores_sem_vendas,
    faturamento_acumulado
FROM cte_painel_unificado
HAVING total_clientes > 0;

SET SQL_SAFE_UPDATES = 1;