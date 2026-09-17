CREATE DATABASE IF NOT EXISTS loja;
USE loja;

SET SQL_SAFE_UPDATES = 0;

-- 1. LIMPEZA E CRIAÇÃO COMPLETA DAS TABELAS
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

-- 2. INSERÇÃO DE DADOS PARA TESTE
INSERT INTO clientes (id_cliente, nome_cliente, cidade, estado) VALUES
(1, 'Ana Silva', 'Curitiba', 'PR'),
(2, 'Bruno Souza', 'Rio de Janeiro', 'RJ'),
(3, 'Carla Mendes', 'Curitiba', 'PR'),
(4, 'Daniel Rocha', 'São Paulo', 'SP');

INSERT INTO vendedores (id_vendedor, nome_vendedor, setor) VALUES
(1, 'Carlos Lima', 'Tecnologia'),
(2, 'Fernanda Alves', 'Móveis'),
(3, 'Mariana Costa', 'Eletro');

INSERT INTO produtos (id_produto, nome_produto, categoria, preco_padrao) VALUES
(1, 'Notebook Pro', 'Informática', 3500.00),
(2, 'Mouse Sem Fio', 'Informática', 80.00),
(3, 'Cadeira Ergonômica', 'Móveis', 1200.00),
(4, 'Teclado Mecânico', 'Informática', 250.00);

INSERT INTO vendas (id_venda, data_venda, id_cliente, id_vendedor, forma_pagamento, status_venda, valor_total) VALUES
(1, '2026-03-15', 1, 1, 'Pix', 'Concluída', 7000.00),
(2, '2026-04-01', 2, 1, 'Cartão de Crédito', 'Cancelada', 160.00),
(3, '2026-05-10', 3, 2, 'Pix', 'Concluída', 1200.00),
(4, '2026-06-20', 1, 3, 'Boleto', 'Concluída', 1000.00);

INSERT INTO itens_venda (id_item, id_venda, id_produto, quantidade, valor_unitario, desconto) VALUES
(1, 1, 1, 2, 3500.00, 0.00),
(2, 2, 2, 2, 80.00, 0.00),
(3, 3, 3, 1, 1200.00, 5.00),
(4, 4, 4, 4, 250.00, 10.00);


-- ------------------------------------------------------------
-- CONSULTAS DOS EXERCÍCIOS
-- ------------------------------------------------------------

-- EXERCÍCIO 01
SELECT 
    v.id_venda,
    v.data_venda,
    c.nome_cliente,
    v.valor_total
FROM vendas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente;

-- EXERCÍCIO 02
SELECT 
    v.id_venda,
    v.data_venda,
    vend.nome_vendedor,
    vend.setor,
    v.valor_total
FROM vendas v
INNER JOIN vendedores vend ON v.id_vendedor = vend.id_vendedor
ORDER BY v.data_venda DESC;

-- EXERCÍCIO 03
SELECT 
    iv.id_item,
    p.nome_produto,
    p.categoria,
    iv.quantidade,
    iv.valor_unitario
FROM itens_venda iv
INNER JOIN produtos p ON iv.id_produto = p.id_produto;

-- EXERCÍCIO 04
SELECT 
    v.id_venda,
    v.data_venda,
    p.nome_produto,
    iv.quantidade,
    iv.valor_unitario
FROM vendas v
INNER JOIN itens_venda iv ON v.id_venda = iv.id_venda
INNER JOIN produtos p ON iv.id_produto = p.id_produto;

-- EXERCÍCIO 05
SELECT 
    v.id_venda,
    v.data_venda,
    c.nome_cliente,
    vend.nome_vendedor,
    p.nome_produto,
    iv.quantidade,
    iv.valor_unitario
FROM vendas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN vendedores vend ON v.id_vendedor = vend.id_vendedor
INNER JOIN itens_venda iv ON v.id_venda = iv.id_venda
INNER JOIN produtos p ON iv.id_produto = p.id_produto;

-- EXERCÍCIO 06
SELECT 
    c.nome_cliente,
    c.cidade,
    v.id_venda,
    v.data_venda,
    v.status_venda AS status,
    v.valor_total
FROM vendas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
WHERE c.cidade = 'Curitiba';

-- EXERCÍCIO 07
SELECT 
    p.nome_produto,
    p.categoria,
    v.id_venda,
    v.data_venda,
    iv.quantidade
FROM itens_venda iv
INNER JOIN produtos p ON iv.id_produto = p.id_produto
INNER JOIN vendas v ON iv.id_venda = v.id_venda
WHERE p.categoria = 'Informática';

-- EXERCÍCIO 08
SELECT 
    v.id_venda,
    v.data_venda,
    c.nome_cliente,
    vend.nome_vendedor,
    v.valor_total
FROM vendas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN vendedores vend ON v.id_vendedor = vend.id_vendedor
WHERE v.forma_pagamento = 'Pix';

-- EXERCÍCIO 09
SELECT 
    iv.id_venda,
    p.nome_produto,
    iv.quantidade,
    iv.valor_unitario,
    iv.desconto,
    (iv.quantidade * iv.valor_unitario) AS subtotal_bruto
FROM itens_venda iv
INNER JOIN produtos p ON iv.id_produto = p.id_produto
WHERE iv.quantidade > 2;

-- EXERCÍCIO 10
SELECT 
    c.id_cliente,
    c.nome_cliente,
    COUNT(v.id_venda) AS quantidade_vendas,
    SUM(v.valor_total) AS total_comprado
FROM clientes c
INNER JOIN vendas v ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nome_cliente
ORDER BY total_comprado DESC;

-- EXERCÍCIO 11
SELECT 
    vend.id_vendedor,
    vend.nome_vendedor,
    COUNT(v.id_venda) AS quantidade_vendas,
    SUM(v.valor_total) AS total_vendido,
    AVG(v.valor_total) AS ticket_medio
FROM vendedores vend
INNER JOIN vendas v ON vend.id_vendedor = v.id_vendedor
GROUP BY vend.id_vendedor, vend.nome_vendedor;

-- EXERCÍCIO 12
SELECT 
    p.id_produto,
    p.nome_produto,
    p.categoria,
    SUM(iv.quantidade) AS quantidade_total_vendida
FROM produtos p
INNER JOIN itens_venda iv ON p.id_produto = iv.id_produto
GROUP BY p.id_produto, p.nome_produto, p.categoria
ORDER BY quantidade_total_vendida DESC;

-- EXERCÍCIO 13
SELECT 
    p.categoria,
    SUM(iv.quantidade) AS quantidade_total_itens,
    SUM(iv.quantidade * iv.valor_unitario * (1 - iv.desconto / 100)) AS faturamento_liquido
FROM produtos p
INNER JOIN itens_venda iv ON p.id_produto = iv.id_produto
GROUP BY p.categoria
ORDER BY faturamento_liquido DESC;

-- EXERCÍCIO 14
SELECT 
    v.id_venda,
    v.data_venda,
    c.nome_cliente,
    vend.nome_vendedor,
    v.forma_pagamento,
    v.valor_total
FROM vendas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN vendedores vend ON v.id_vendedor = vend.id_vendedor
WHERE v.status_venda = 'Concluída'
  AND v.data_venda BETWEEN '2026-03-01' AND '2026-06-30'
ORDER BY v.data_venda, v.id_venda;

-- EXERCÍCIO 15
SELECT 
    vend.nome_vendedor,
    COUNT(DISTINCT v.id_venda) AS quantidade_vendas,
    COUNT(DISTINCT v.id_cliente) AS quantidade_clientes_atendidos,
    SUM(iv.quantidade) AS quantidade_produtos_vendidos,
    SUM(iv.quantidade * iv.valor_unitario * (1 - iv.desconto / 100)) AS faturamento_dos_itens,
    AVG(v.valor_total) AS ticket_medio_das_vendas
FROM vendedores vend
INNER JOIN vendas v ON vend.id_vendedor = v.id_vendedor
INNER JOIN itens_venda iv ON v.id_venda = iv.id_venda
WHERE v.status_venda = 'Concluída'
GROUP BY vend.id_vendedor, vend.nome_vendedor
ORDER BY faturamento_dos_itens DESC;

SET SQL_SAFE_UPDATES = 1;