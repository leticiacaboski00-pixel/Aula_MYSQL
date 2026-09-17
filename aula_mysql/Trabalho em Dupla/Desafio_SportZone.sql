-- RESET DO BANCO DE DADOS (Evita erro 1050)
DROP TABLE IF EXISTS item_venda;
DROP TABLE IF EXISTS venda;
DROP TABLE IF EXISTS produto;
DROP TABLE IF EXISTS vendedor;
DROP TABLE IF EXISTS cliente;

-- DDL
CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    renda DECIMAL(10,2) NOT NULL
);

CREATE TABLE produto (
    id_produto INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    estoque INT NOT NULL
);

CREATE TABLE vendedor (
    id_vendedor INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE venda (
    id_venda INT PRIMARY KEY AUTO_INCREMENT,
    data_venda DATE NOT NULL,
    id_cliente INT NOT NULL,
    id_vendedor INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_vendedor) REFERENCES vendedor(id_vendedor)
);

CREATE TABLE item_venda (
    id_item INT PRIMARY KEY AUTO_INCREMENT,
    id_venda INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_venda) REFERENCES venda(id_venda),
    FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);

-- DML
INSERT INTO cliente (nome, cidade, renda) VALUES
('Lucas Mendes', 'Curitiba', 4500.00),
('Beatriz Souza', 'Curitiba', 8500.00),
('Camila Rodrigues', 'São José dos Pinhais', 3200.00),
('Daniel Alves', 'Colombo', 2900.00),
('Eduardo Pereira', 'Curitiba', 12000.00),
('Fernanda Lima', 'Pinhais', 5100.00),
('Gabriel Santos', 'Colombo', 6400.00),
('Helena Castro', 'Curitiba', 9300.00);

INSERT INTO produto (nome, preco, estoque) VALUES
('Tênis de Corrida Pro', 499.90, 45),
('Camiseta DryFit', 89.90, 120),
('Bola de Futebol Match', 129.90, 30),
('Mochila Esportiva 30L', 199.90, 15),
('Smartwatch Fitness', 899.90, 8),
('Caneleira Futsal', 45.00, 60),
('Garrafa Térmica 1L', 79.90, 0);

INSERT INTO vendedor (nome) VALUES
('Carlos Eduardo'),
('Mariana Lima'),
('Roberto Alves'),
('Patricia Gomez');

INSERT INTO venda (data_venda, id_cliente, id_vendedor) VALUES
('2025-01-10', 1, 1),
('2025-01-15', 2, 2),
('2025-02-01', 5, 1),
('2025-02-18', 2, 3),
('2025-03-02', 3, 2),
('2025-03-20', 5, 1),
('2025-04-05', 7, 2);

INSERT INTO item_venda (id_venda, id_produto, quantidade, preco_unitario) VALUES
(1, 1, 1, 499.90),
(1, 2, 2, 89.90),
(2, 5, 1, 899.90),
(2, 4, 1, 199.90),
(3, 1, 2, 499.90),
(3, 5, 1, 899.90),
(4, 2, 3, 89.90),
(5, 3, 1, 129.90),
(5, 6, 2, 45.00),
(6, 1, 1, 499.90),
(7, 2, 1, 89.90);

-- PARTE 1: RELATÓRIO DE CLIENTES
WITH compras_cliente AS (
    SELECT 
        v.id_cliente,
        COUNT(DISTINCT v.id_venda) AS qtd_compras,
        COALESCE(SUM(iv.quantidade), 0) AS total_produtos,
        COALESCE(SUM(iv.quantidade * iv.preco_unitario), 0) AS total_gasto,
        MAX(v.data_venda) AS ultima_compra
    FROM venda v
    INNER JOIN item_venda iv ON v.id_venda = iv.id_venda
    GROUP BY v.id_cliente
)
SELECT 
    c.nome,
    c.cidade,
    c.renda,
    COALESCE(cc.qtd_compras, 0) AS quantidade_compras,
    COALESCE(cc.total_produtos, 0) AS total_produtos_adquiridos,
    COALESCE(cc.total_gasto, 0) AS valor_total_gasto,
    ROUND(CASE WHEN COALESCE(cc.qtd_compras, 0) = 0 THEN 0 ELSE cc.total_gasto / cc.qtd_compras END, 2) AS ticket_medio,
    COALESCE(DATE_FORMAT(cc.ultima_compra, '%d/%m/%Y'), 'Nenhuma compra') AS data_ultima_compra
FROM cliente c
LEFT JOIN compras_cliente cc ON c.id_cliente = cc.id_cliente
ORDER BY valor_total_gasto DESC;

-- PARTE 2: RELATÓRIO DE PRODUTOS
WITH desempenho_produto AS (
    SELECT 
        iv.id_produto,
        SUM(iv.quantidade) AS total_vendido,
        SUM(iv.quantidade * iv.preco_unitario) AS faturamento,
        COUNT(DISTINCT v.id_cliente) AS clientes_distintos
    FROM item_venda iv
    INNER JOIN venda v ON iv.id_venda = v.id_venda
    GROUP BY iv.id_produto
)
SELECT 
    p.nome AS produto,
    p.preco AS preco_atual,
    p.estoque,
    COALESCE(dp.total_vendido, 0) AS quantidade_total_vendida,
    COALESCE(dp.faturamento, 0) AS faturamento_gerado,
    COALESCE(dp.clientes_distintos, 0) AS clientes_diferentes
FROM produto p
LEFT JOIN desempenho_produto dp ON p.id_produto = dp.id_produto
ORDER BY faturamento_gerado DESC;

-- PARTE 3: RELATÓRIO DE VENDEDORES
WITH vendas_vendedor AS (
    SELECT 
        v.id_vendedor,
        COUNT(DISTINCT v.id_venda) AS qtd_vendas,
        COUNT(DISTINCT v.id_cliente) AS clientes_atendidos,
        SUM(iv.quantidade) AS total_produtos,
        SUM(iv.quantidade * iv.preco_unitario) AS faturamento
    FROM venda v
    INNER JOIN item_venda iv ON v.id_venda = iv.id_venda
    GROUP BY v.id_vendedor
)
SELECT 
    vend.nome AS vendedor,
    COALESCE(vv.qtd_vendas, 0) AS quantidade_vendas,
    COALESCE(vv.clientes_atendidos, 0) AS clientes_diferentes_atendidos,
    COALESCE(vv.total_produtos, 0) AS total_produtos_vendidos,
    COALESCE(vv.faturamento, 0) AS faturamento_total,
    ROUND(CASE WHEN COALESCE(vv.qtd_vendas, 0) = 0 THEN 0 ELSE vv.faturamento / vv.qtd_vendas END, 2) AS ticket_medio_vendas
FROM vendedor vend
LEFT JOIN vendas_vendedor vv ON vend.id_vendedor = vv.id_vendedor
ORDER BY faturamento_total DESC;

-- PARTE 4: KPIS OBRIGATÓRIOS

-- KPI 01
SELECT c.nome AS cliente, SUM(iv.quantidade * iv.preco_unitario) AS total_gasto
FROM cliente c
INNER JOIN venda v ON c.id_cliente = v.id_cliente
INNER JOIN item_venda iv ON v.id_venda = iv.id_venda
GROUP BY c.id_cliente, c.nome
ORDER BY total_gasto DESC LIMIT 1;

-- KPI 02
SELECT c.nome AS cliente, COUNT(v.id_venda) AS quantidade_compras
FROM cliente c
INNER JOIN venda v ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nome
ORDER BY quantidade_compras DESC LIMIT 1;

-- KPI 03
SELECT p.nome AS produto, SUM(iv.quantidade) AS total_unidades_vendidas
FROM produto p
INNER JOIN item_venda iv ON p.id_produto = iv.id_produto
GROUP BY p.id_produto, p.nome
ORDER BY total_unidades_vendidas DESC LIMIT 1;

-- KPI 04
SELECT p.nome AS produto, SUM(iv.quantidade * iv.preco_unitario) AS faturamento_total
FROM produto p
INNER JOIN item_venda iv ON p.id_produto = iv.id_produto
GROUP BY p.id_produto, p.nome
ORDER BY faturamento_total DESC LIMIT 1;

-- KPI 05
SELECT p.id_produto, p.nome AS produto, p.preco, p.estoque
FROM produto p
WHERE NOT EXISTS (SELECT 1 FROM item_venda iv WHERE iv.id_produto = p.id_produto);

-- KPI 06
SELECT vend.nome AS vendedor, COUNT(v.id_venda) AS quantidade_vendas
FROM vendedor vend
INNER JOIN venda v ON vend.id_vendedor = v.id_vendedor
GROUP BY vend.id_vendedor, vend.nome
ORDER BY quantidade_vendas DESC LIMIT 1;

-- KPI 07
SELECT vend.nome AS vendedor, SUM(iv.quantidade * iv.preco_unitario) AS faturamento_gerado
FROM vendedor vend
INNER JOIN venda v ON vend.id_vendedor = v.id_vendedor
INNER JOIN item_venda iv ON v.id_venda = iv.id_venda
GROUP BY vend.id_vendedor, vend.nome
ORDER BY faturamento_gerado DESC LIMIT 1;

-- KPI 08
SELECT COUNT(*) AS qtd_clientes_sem_compra
FROM cliente c
WHERE NOT EXISTS (SELECT 1 FROM venda v WHERE v.id_cliente = c.id_cliente);

-- KPI 09
SELECT SUM(quantidade * preco_unitario) AS faturamento_total_empresa
FROM item_venda;

-- KPI 10
WITH total_por_venda AS (
    SELECT v.id_venda, SUM(iv.quantidade * iv.preco_unitario) AS valor_venda
    FROM venda v
    INNER JOIN item_venda iv ON v.id_venda = iv.id_venda
    GROUP BY v.id_venda
)
SELECT ROUND(AVG(valor_venda), 2) AS ticket_medio_geral
FROM total_por_venda;

-- PARTE 5: KPIS CRIADOS PELA DUPLA

-- KPI Criado 01: Faturamento por Cidade
SELECT 
    c.cidade,
    COUNT(DISTINCT c.id_cliente) AS total_clientes,
    COUNT(DISTINCT v.id_venda) AS total_pedidos,
    COALESCE(SUM(iv.quantidade * iv.preco_unitario), 0) AS faturamento_total
FROM cliente c
LEFT JOIN venda v ON c.id_cliente = v.id_cliente
LEFT JOIN item_venda iv ON v.id_venda = iv.id_venda
GROUP BY c.cidade
ORDER BY faturamento_total DESC;

-- KPI Criado 02: Capital Parado em Estoque Sem Vendas
SELECT 
    p.nome AS produto,
    p.estoque,
    p.preco,
    (p.estoque * p.preco) AS capital_parado
FROM produto p
WHERE p.estoque > 0
  AND NOT EXISTS (SELECT 1 FROM item_venda iv WHERE iv.id_produto = p.id_produto)
ORDER BY capital_parado DESC;

-- KPI Criado 03: Faturamento por Faixa de Renda
WITH faturamento_por_cliente AS (
    SELECT 
        c.id_cliente,
        CASE 
            WHEN c.renda <= 4000.00 THEN 'Até R$ 4.000'
            WHEN c.renda BETWEEN 4000.01 AND 8000.00 THEN 'R$ 4.000,01 a R$ 8.000'
            ELSE 'Acima de R$ 8.000'
        END AS faixa_renda,
        COALESCE(SUM(iv.quantidade * iv.preco_unitario), 0) AS total_gasto
    FROM cliente c
    LEFT JOIN venda v ON c.id_cliente = v.id_cliente
    LEFT JOIN item_venda iv ON v.id_venda = iv.id_venda
    GROUP BY c.id_cliente, c.renda
)
SELECT 
    faixa_renda,
    COUNT(id_cliente) AS qtd_clientes,
    SUM(total_gasto) AS faturamento_total,
    ROUND(AVG(total_gasto), 2) AS media_gasto_por_cliente
FROM faturamento_por_cliente
GROUP BY faixa_renda
ORDER BY faturamento_total DESC;

-- KPI Criado 04: Taxa de Conversão da Base de Clientes
SELECT 
    COUNT(c.id_cliente) AS total_base,
    COUNT(DISTINCT v.id_cliente) AS clientes_ativos,
    COUNT(c.id_cliente) - COUNT(DISTINCT v.id_cliente) AS clientes_inativos,
    ROUND((COUNT(DISTINCT v.id_cliente) / COUNT(c.id_cliente)) * 100, 2) AS percentual_conversao_pct
FROM cliente c
LEFT JOIN venda v ON c.id_cliente = v.id_cliente;

-- KPI Criado 05: Produtos de Alta Penetração
SELECT 
    p.nome AS produto,
    COUNT(DISTINCT v.id_cliente) AS clientes_unicos_compradores,
    COUNT(DISTINCT c.cidade) AS cidades_atendidas
FROM produto p
INNER JOIN item_venda iv ON p.id_produto = iv.id_produto
INNER JOIN venda v ON iv.id_venda = v.id_venda
INNER JOIN cliente c ON v.id_cliente = c.id_cliente
GROUP BY p.id_produto, p.nome
HAVING clientes_unicos_compradores > 1
ORDER BY clientes_unicos_compradores DESC;