
-- =====================================================
-- PIZZARIA TECH - DATA WAREHOUSE
-- MODELO STAR SCHEMA
-- =====================================================

CREATE DATABASE IF NOT EXISTS bd_pizzaria_tech
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE bd_pizzaria_tech;

-- =====================================================
-- MISSAO 01 - CRIACAO DAS TABELAS
-- =====================================================

-- 1. DIMENSAO CLIENTE

CREATE TABLE IF NOT EXISTS dim_cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome_cliente VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado CHAR(2) NOT NULL
) ENGINE=InnoDB;

-- 2. DIMENSAO PRODUTO

CREATE TABLE IF NOT EXISTS dim_produto (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL
) ENGINE=InnoDB;

-- 3. DIMENSAO VENDEDOR

CREATE TABLE IF NOT EXISTS dim_vendedor (
    id_vendedor INT AUTO_INCREMENT PRIMARY KEY,
    nome_vendedor VARCHAR(100) NOT NULL,
    turno VARCHAR(20) NOT NULL,
    filial VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- 4. DIMENSAO TEMPO

CREATE TABLE IF NOT EXISTS dim_tempo (
    id_tempo INT AUTO_INCREMENT PRIMARY KEY,
    data_venda DATE NOT NULL,
    dia INT NOT NULL,
    mes INT NOT NULL,
    nome_mes VARCHAR(20) NOT NULL,
    ano INT NOT NULL,
    dia_semana VARCHAR(20) NOT NULL
) ENGINE=InnoDB;

-- 5. TABELA FATO VENDA

CREATE TABLE IF NOT EXISTS fact_venda (
    id_venda INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_produto INT NOT NULL,
    id_vendedor INT NOT NULL,
    id_tempo INT NOT NULL,
    quantidade INT NOT NULL,
    valor_total DECIMAL(12,2) NOT NULL,

    CONSTRAINT fk_venda_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES dim_cliente(id_cliente)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_venda_produto
        FOREIGN KEY (id_produto)
        REFERENCES dim_produto(id_produto)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_venda_vendedor
        FOREIGN KEY (id_vendedor)
        REFERENCES dim_vendedor(id_vendedor)
        ON DELETE RESTRICT ON UPDATE CASCADE,

    CONSTRAINT fk_venda_tempo
        FOREIGN KEY (id_tempo)
        REFERENCES dim_tempo(id_tempo)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;


-- =====================================================
-- MISSAO 02 - CONFERENCIA DAS TABELAS
-- =====================================================

SHOW TABLES;

-- CONFERENCIA DOS REGISTROS

SELECT 'dim_cliente' AS tabela, COUNT(*) AS registros
FROM dim_cliente

UNION ALL

SELECT 'dim_produto', COUNT(*)
FROM dim_produto

UNION ALL

SELECT 'dim_vendedor', COUNT(*)
FROM dim_vendedor

UNION ALL

SELECT 'dim_tempo', COUNT(*)
FROM dim_tempo

UNION ALL

SELECT 'fact_venda', COUNT(*)
FROM fact_venda;


-- =====================================================
-- MISSAO 03
-- QUAIS PIZZAS MAIS VENDEM EM CADA FILIAL?
-- =====================================================

SELECT
    v.filial,
    p.nome_produto AS nome_pizza,
    SUM(f.quantidade) AS total_unidades_vendidas

FROM fact_venda f

INNER JOIN dim_vendedor v
    ON f.id_vendedor = v.id_vendedor

INNER JOIN dim_produto p
    ON f.id_produto = p.id_produto

GROUP BY
    v.filial,
    p.nome_produto

ORDER BY
    v.filial ASC,
    total_unidades_vendidas DESC;


-- =====================================================
-- MISSAO 04
-- QUAIS DIAS DA SEMANA APRESENTAM MAIOR FATURAMENTO?
-- =====================================================

SELECT
    t.dia_semana,
    SUM(f.quantidade) AS total_unidades_vendidas,
    SUM(f.valor_total) AS faturamento_total

FROM fact_venda f

INNER JOIN dim_tempo t
    ON f.id_tempo = t.id_tempo

GROUP BY
    t.dia_semana

ORDER BY
    faturamento_total DESC;


-- =====================================================
-- MISSAO 05
-- QUAL VENDEDOR APRESENTA O MELHOR DESEMPENHO?
-- =====================================================

SELECT
    ve.nome_vendedor,
    ve.filial,
    ve.turno,
    SUM(f.quantidade) AS total_unidades_vendidas,
    SUM(f.valor_total) AS faturamento_total

FROM fact_venda f

INNER JOIN dim_vendedor ve
    ON f.id_vendedor = ve.id_vendedor

GROUP BY
    ve.id_vendedor,
    ve.nome_vendedor,
    ve.filial,
    ve.turno

ORDER BY
    faturamento_total DESC;


-- =====================================================
-- MISSAO 06
-- COMO O TICKET MEDIO VARIA ENTRE CIDADES?
-- =====================================================

SELECT
    c.cidade,
    COUNT(f.id_venda) AS quantidade_registros_venda,
    SUM(f.valor_total) AS faturamento_total,
    AVG(f.valor_total) AS ticket_medio

FROM fact_venda f

INNER JOIN dim_cliente c
    ON f.id_cliente = c.id_cliente

GROUP BY
    c.cidade

ORDER BY
    ticket_medio DESC;