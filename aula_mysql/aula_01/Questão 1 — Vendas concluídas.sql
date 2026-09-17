CREATE DATABASE IF NOT EXISTS loja;
USE loja;

-- Desativa o Safe Updates para evitar bloqueios de alteração
SET SQL_SAFE_UPDATES = 0;

-- Limpeza e Recriação da Tabela
DROP TABLE IF EXISTS vendas;

CREATE TABLE vendas (
    id_venda INT PRIMARY KEY AUTO_INCREMENT,
    data_venda DATE NOT NULL,
    nome_cliente VARCHAR(100) NOT NULL,
    cidade_cliente VARCHAR(80),
    estado_cliente CHAR(2),
    nome_produto VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    quantidade INT NOT NULL,
    valor_unitario DECIMAL(10,2) NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL,
    forma_pagamento VARCHAR(30) NOT NULL,
    status_venda VARCHAR(20) NOT NULL,
    vendedor VARCHAR(100) NOT NULL
);

-- Inserção dos Dados de Teste
INSERT INTO vendas (id_venda, data_venda, nome_cliente, cidade_cliente, estado_cliente, nome_produto, categoria, quantidade, valor_unitario, valor_total, forma_pagamento, status_venda, vendedor) VALUES
(1, '2023-11-15', 'Ana Silva', 'São Paulo', 'SP', 'Notebook Pro', 'Informática', 2, 3500.00, 7000.00, 'Cartão de Crédito', 'Concluída', 'Carlos Lima'),
(2, '2023-12-01', 'Bruno Souza', 'Rio de Janeiro', 'RJ', 'Mouse Sem Fio', 'Informática', 2, 80.00, 160.00, 'Cartão de Crédito', 'Cancelada', 'Carlos Lima'),
(3, '2024-05-10', 'Carla Mendes', 'Curitiba', 'PR', 'Cadeira Ergonomica', 'Móveis', 1, 1200.00, 1200.00, 'Pix', 'Pendente', 'Fernanda Alves'),
(4, '2024-08-20', 'Daniel Rocha', 'Belo Horizonte', 'MG', 'Teclado Mecânico', 'Informática', 0, 250.00, 0.00, 'Boleto', 'Pendente', 'Carlos Lima'),
(5, '2024-11-05', 'Eduardo Lima', 'São Paulo', 'SP', 'Monitor 27"', 'Informática', 3, 1400.00, 4200.00, 'Cartão de Crédito', 'Concluída', 'Mariana Costa'),
(6, '2025-01-15', 'Fernanda Dias', 'Porto Alegre', 'RS', 'Smartphone', 'Eletrônicos', 2, 2500.00, 5000.00, 'Pix', 'Concluída', 'Mariana Costa'),
(7, '2025-02-01', 'Gabriel Cruz', 'Salvador', 'BA', 'Mesa de Escritório', 'Móveis', 3, 600.00, 1800.00, 'Cartão de Crédito', 'Pendente', 'Fernanda Alves'),
(8, '2025-02-10', 'Helena Ramos', 'São Paulo', 'SP', 'Headset Gamer', 'Informática', 2, 300.00, 600.00, 'Pix', 'Concluída', 'Carlos Lima'),
(9, '2025-02-20', 'Igor Santos', 'Campinas', 'SP', 'Cafeteira', 'Eletrodomésticos', -1, 200.00, -200.00, 'Cartão de Crédito', 'Concluída', 'Mariana Costa'),
(10, '2025-02-25', 'Juliana Paes', 'Rio de Janeiro', 'RJ', 'Webcam Full HD', 'Informática', 3, 150.00, 450.00, 'Cartão de Crédito', 'Concluída', 'Carlos Lima');

-- 2. Consultas CTEs

-- Questão 1 — Vendas concluídas
WITH vendas_concluidas AS (
    SELECT 
        id_venda,
        data_venda,
        nome_cliente,
        nome_produto,
        valor_total,
        vendedor
    FROM vendas
    WHERE status_venda = 'Concluída'
)
SELECT 
    id_venda,
    data_venda,
    nome_cliente,
    nome_produto,
    valor_total,
    vendedor
FROM vendas_concluidas
ORDER BY valor_total DESC;

-- Questão 2 — Faturamento por categoria
WITH resumo_categorias AS (
    SELECT 
        categoria,
        COUNT(id_venda) AS quantidade_vendas,
        SUM(quantidade) AS total_produtos_vendidos,
        SUM(valor_total) AS faturamento_total,
        AVG(valor_total) AS valor_medio_vendas
    FROM vendas
    GROUP BY categoria
)
SELECT 
    categoria,
    quantidade_vendas,
    total_produtos_vendidos,
    faturamento_total,
    valor_medio_vendas
FROM resumo_categorias
WHERE faturamento_total > 10000.00
ORDER BY faturamento_total DESC;

-- Questão 3 — Desempenho dos vendedores
WITH desempenho_vendedores AS (
    SELECT 
        vendedor,
        COUNT(id_venda) AS quantidade_vendas,
        SUM(quantidade) AS total_produtos_vendidos,
        SUM(valor_total) AS valor_total_vendido,
        AVG(valor_total) AS ticket_medio
    FROM vendas
    GROUP BY vendedor
)
SELECT 
    vendedor,
    quantidade_vendas,
    total_produtos_vendidos,
    valor_total_vendido,
    ticket_medio
FROM desempenho_vendedores
ORDER BY valor_total_vendido DESC
LIMIT 3;

-- Questão 4 — Estados com faturamento acima da média
WITH vendas_validas AS (
    SELECT *
    FROM vendas
    WHERE quantidade > 0 
      AND status_venda != 'Cancelada'
),
faturamento_estados AS (
    SELECT 
        estado_cliente,
        COUNT(id_venda) AS quantidade_vendas,
        SUM(quantidade) AS total_produtos_vendidos,
        SUM(valor_total) AS faturamento_total
    FROM vendas_validas
    GROUP BY estado_cliente
),
media_faturamento AS (
    SELECT 
        AVG(faturamento_total) AS media_geral
    FROM faturamento_estados
)
SELECT 
    fe.estado_cliente,
    fe.quantidade_vendas,
    fe.total_produtos_vendidos,
    fe.faturamento_total,
    mf.media_geral,
    (fe.faturamento_total - mf.media_geral) AS diferenca_para_media
FROM faturamento_estados fe
CROSS JOIN media_faturamento mf
WHERE fe.faturamento_total > mf.media_geral
ORDER BY fe.faturamento_total DESC;

-- Desafio Adicional — Subquery
SELECT 
    sub.categoria,
    sub.quantidade_vendas,
    sub.total_produtos_vendidos,
    sub.faturamento_total,
    sub.valor_medio_vendas
FROM (
    SELECT 
        categoria,
        COUNT(id_venda) AS quantidade_vendas,
        SUM(quantidade) AS total_produtos_vendidos,
        SUM(valor_total) AS faturamento_total,
        AVG(valor_total) AS valor_medio_vendas
    FROM vendas
    GROUP BY categoria
) sub
WHERE sub.faturamento_total > 10000.00
ORDER BY sub.faturamento_total DESC;

-- Reativa o Safe Updates por segurança
SET SQL_SAFE_UPDATES = 1;