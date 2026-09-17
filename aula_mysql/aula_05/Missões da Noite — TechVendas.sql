CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    renda DECIMAL(10,2) NOT NULL
);

CREATE TABLE vendedor (
    id_vendedor INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE produto (
    id_produto INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    preco DECIMAL(10,2) NOT NULL,
    estoque INT NOT NULL
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

-- 2. Inserção de Dados Fictícios
INSERT INTO cliente (nome, cidade, renda) VALUES
('Ana Silva', 'Curitiba', 3500.00),
('Carlos Eduardo Silva', 'Curitiba', 5500.00),
('Amanda Souza', 'Colombo', 2800.00),
('Bruno Oliveira', 'São José dos Pinhais', 4200.00),
('Eduardo Santos', 'Curitiba', 7000.00),
('Fernanda Lima', 'Pinhais', 6000.00),
('Gabriel Costa', 'Colombo', 8000.00);

INSERT INTO vendedor (nome) VALUES
('Carlos Eduardo'),
('Mariana Lima'),
('Eduardo Xavier'),
('Beatriz Ramos'),
('Roberto Alves');

INSERT INTO produto (nome, preco, estoque) VALUES
('Mouse Sem Fio', 80.00, 50),
('Teclado Mecânico', 150.00, 30),
('Monitor 24"', 650.00, 15),
('Cabo HDMI', 30.00, 100),
('Headset USB', 200.00, 25),
('Suporte Notebook', 120.00, 40),
('Webcam Full HD', 220.00, 10);

INSERT INTO venda (data_venda, id_cliente, id_vendedor) VALUES
('2025-01-15', 1, 1),
('2025-02-10', 2, 3),
('2025-03-05', 5, 5),
('2025-04-12', 1, 1),
('2025-01-20', 7, 3);

INSERT INTO item_venda (id_venda, id_produto, quantidade, preco_unitario) VALUES
(1, 2, 1, 150.00),
(1, 4, 2, 30.00),
(2, 3, 1, 650.00),
(3, 5, 2, 200.00),
(4, 6, 1, 120.00),
(5, 2, 2, 150.00);

-- Missão 1 — Clientes sem compras
SELECT 
    c.nome,
    c.cidade,
    CONCAT('R$ ', COALESCE(FORMAT(SUM(iv.quantidade * iv.preco_unitario), 2, 'pt_BR'), '0,00')) AS valor_total_gasto
FROM cliente c
LEFT JOIN venda v ON c.id_cliente = v.id_cliente
LEFT JOIN item_venda iv ON v.id_venda = iv.id_venda
GROUP BY c.id_cliente, c.nome, c.cidade;

-- Missão 2 — Produtos sem vendas
SELECT 
    p.nome AS produto,
    p.preco,
    p.estoque,
    COALESCE(SUM(iv.quantidade), 0) AS quantidade_total_vendida
FROM produto p
LEFT JOIN item_venda iv ON p.id_produto = iv.id_produto
GROUP BY p.id_produto, p.nome, p.preco, p.estoque;

-- Missão 3 — Desempenho dos vendedores
SELECT 
    v.nome AS vendedor,
    COUNT(DISTINCT ve.id_venda) AS quantidade_vendas,
    COALESCE(SUM(iv.quantidade * iv.preco_unitario), 0) AS faturamento_total
FROM vendedor v
LEFT JOIN venda ve ON v.id_vendedor = ve.id_vendedor
LEFT JOIN item_venda iv ON ve.id_venda = iv.id_venda
GROUP BY v.id_vendedor, v.nome;

-- Missão 4 — Classificação de clientes
WITH faturamento_cliente AS (
    SELECT 
        c.id_cliente,
        c.nome,
        c.cidade,
        COALESCE(SUM(iv.quantidade * iv.preco_unitario), 0) AS total_gasto
    FROM cliente c
    LEFT JOIN venda v ON c.id_cliente = v.id_cliente
    LEFT JOIN item_venda iv ON v.id_venda = iv.id_venda
    GROUP BY c.id_cliente, c.nome, c.cidade
)
SELECT 
    nome,
    cidade,
    total_gasto
FROM faturamento_cliente
ORDER BY total_gasto DESC;


-- ============================================================================
-- PARTE 2 — BETWEEN e >= / <=
-- ============================================================================

-- Missão 5 — Clientes por faixa de renda
SELECT 
    nome,
    cidade,
    renda
FROM cliente
WHERE renda BETWEEN 3000.00 AND 6000.00;

-- Missão 6 — Comparando formas de escrever intervalos
SELECT 
    nome,
    cidade,
    renda
FROM cliente
WHERE renda >= 3000.00 AND renda <= 6000.00;
-- Comparação: Os resultados das Missões 5 e 6 são idênticos, pois BETWEEN é inclusivo (equivalente a >= e <=).

-- Missão 7 — Período de vendas
SELECT 
    v.id_venda AS codigo_venda,
    v.data_venda AS data,
    c.nome AS cliente,
    vend.nome AS vendedor
FROM venda v
INNER JOIN cliente c ON v.id_cliente = c.id_cliente
INNER JOIN vendedor vend ON v.id_vendedor = vend.id_vendedor
WHERE v.data_venda BETWEEN '2025-01-01' AND '2025-03-31';

-- Missão 8 — Produtos em determinada faixa de preço
SELECT 
    nome AS produto,
    preco,
    estoque
FROM produto
WHERE preco >= 100.00 AND preco <= 250.00;


-- ============================================================================
-- PARTE 3 — IN
-- ============================================================================

-- Missão 9 — Campanha regional
SELECT 
    nome,
    cidade,
    renda
FROM cliente
WHERE cidade IN ('Curitiba', 'Colombo', 'São José dos Pinhais');

-- Missão 10 — Produtos selecionados
SELECT 
    id_produto AS codigo,
    nome,
    preco,
    estoque
FROM produto
WHERE id_produto IN (1, 3, 5, 7);

-- Missão 11 — Vendas de vendedores selecionados
SELECT 
    vend.nome AS vendedor,
    v.id_venda AS codigo_venda,
    v.data_venda
FROM venda v
INNER JOIN vendedor vend ON v.id_vendedor = vend.id_vendedor
WHERE v.id_vendedor IN (1, 3, 5);


-- ============================================================================
-- PARTE 4 — LIKE
-- ============================================================================

-- Missão 12 — Busca por nomes
SELECT 
    nome,
    cidade,
    renda
FROM cliente
WHERE nome LIKE 'A%';

-- Missão 13 — Busca por sobrenome
SELECT 
    nome,
    cidade,
    renda
FROM cliente
WHERE nome LIKE '%Silva';

-- Missão 14 — Busca por parte do nome
SELECT 
    id_vendedor,
    nome
FROM vendedor
WHERE nome LIKE '%Eduardo%';


-- ============================================================================
-- PARTE 5 — EXISTS
-- ============================================================================

-- Missão 15 — Clientes que já compraram
SELECT 
    c.id_cliente AS codigo,
    c.nome,
    c.cidade
FROM cliente c
WHERE EXISTS (
    SELECT 1 
    FROM venda v 
    WHERE v.id_cliente = c.id_cliente
);

-- Missão 16 — Produtos que já foram vendidos
SELECT 
    p.id_produto AS codigo,
    p.nome,
    p.preco
FROM produto p
WHERE EXISTS (
    SELECT 1 
    FROM item_venda iv 
    WHERE iv.id_produto = p.id_produto
);

-- Missão 17 — Vendedores ativos
SELECT 
    v.id_vendedor AS codigo_vendedor,
    v.nome AS nome_vendedor
FROM vendedor v
WHERE EXISTS (
    SELECT 1 
    FROM venda ve 
    WHERE ve.id_vendedor = v.id_vendedor
);

-- Missão 18 — Clientes que NÃO compraram
SELECT 
    nome,
    cidade,
    renda
FROM cliente c
WHERE NOT EXISTS (
    SELECT 1 
    FROM venda v 
    WHERE v.id_cliente = c.id_cliente
);


-- ============================================================================
-- PARTE 6 — COMBINANDO OS CONCEITOS
-- ============================================================================

-- Missão 19 — Clientes de alto potencial
SELECT 
    c.nome AS cliente,
    c.cidade,
    c.renda
FROM cliente c
WHERE c.renda BETWEEN 5000.00 AND 8000.00
  AND c.cidade IN ('Curitiba', 'Colombo', 'São José dos Pinhais')
  AND EXISTS (
      SELECT 1 
      FROM venda v 
      WHERE v.id_cliente = c.id_cliente
  );

-- Missão 20 — Produtos estratégicos
SELECT 
    p.nome AS produto,
    p.preco,
    p.estoque
FROM produto p
WHERE p.preco BETWEEN 100.00 AND 300.00
  AND p.estoque > 20
  AND EXISTS (
      SELECT 1 
      FROM item_venda iv 
      WHERE iv.id_produto = p.id_produto
  );