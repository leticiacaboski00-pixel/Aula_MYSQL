CREATE DATABASE IF NOT EXISTS loja;
USE loja;

-- Limpeza caso precise recriar do zero
DROP TABLE IF EXISTS vendas;

-- ============================================================
-- 2. CRIAÇÃO DA TABELA
-- ============================================================
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

-- ============================================================
-- 3. INSERÇÃO DOS DADOS DE TESTE
-- ============================================================
INSERT INTO vendas (id_venda, data_venda, nome_cliente, cidade_cliente, estado_cliente, nome_produto, categoria, quantidade, valor_unitario, valor_total, forma_pagamento, status_venda, vendedor) VALUES
(1, '2023-11-15', 'Ana Silva', 'São Paulo', 'SP', 'Notebook Pro', 'Informática', 1, 3500.00, 3500.00, 'Cartao', 'Concluída', 'Carlos Lima'),
(2, '2023-12-01', 'Bruno Souza', 'Rio de Janeiro', 'RJ', 'Mouse Sem Fio', 'Informática', 2, 80.00, 160.00, 'Cartao', 'Cancelada', 'Carlos Lima'),
(3, '2024-05-10', 'Carla Mendes', 'Curitiba', 'PR', 'Cadeira Ergonomica', 'Móveis', 1, 1200.00, 1200.00, 'Pix', 'Pendente', 'Fernanda Alves'),
(4, '2024-08-20', 'Daniel Rocha', 'Belo Horizonte', 'MG', 'Teclado Mecânico', 'Informática', 0, 250.00, 0.00, 'Boleto', 'Pendente', 'Carlos Lima'),
(5, '2024-11-05', 'Eduardo Lima', 'São Paulo', 'SP', 'Monitor 27"', 'Informática', 2, 1400.00, 2800.00, 'Cartao', 'Pendente', 'Mariana Costa'),
(6, '2025-01-15', 'Fernanda Dias', 'Porto Alegre', 'RS', 'Smartphone', 'Eletrônicos', 1, 2500.00, 2500.00, 'Pix', 'Concluída', 'Mariana Costa'),
(7, '2025-02-01', 'Gabriel Cruz', 'Salvador', 'BA', 'Mesa de Escritório', 'Móveis', 3, 600.00, 1800.00, 'Cartão de Crédito', 'Pendente', 'Fernanda Alves'),
(8, '2025-02-10', 'Helena Ramos', 'São Paulo', 'SP', 'Headset Gamer', 'Informática', 1, 300.00, 300.00, 'Pix', 'Concluída', 'Carlos Lima'),
(9, '2025-02-20', 'Igor Santos', 'Campinas', 'SP', 'Cafeteira', 'Eletrodomésticos', -1, 200.00, -200.00, 'Cartao', 'Concluída', 'Mariana Costa'),
(10, '2025-02-25', 'Juliana Paes', 'Rio de Janeiro', 'RJ', 'Webcam Full HD', 'Informática', 3, 150.00, 100.00, 'Cartao', 'Concluída', 'Carlos Lima');

-- Chave primária no WHERE, execute esta linha primeiro:
SET SQL_SAFE_UPDATES = 0;

-- Questão 1 — Atualização da forma de pagamento
UPDATE vendas
SET forma_pagamento = 'Cartão de Crédito'
WHERE forma_pagamento = 'Cartao';

-- Questão 2 — Atualização do status da venda
UPDATE vendas
SET status_venda = 'Cancelada'
WHERE status_venda = 'Pendente'
  AND data_venda < '2025-01-01';

-- Reativa a proteção contra UPDATEs acidentais
SET SQL_SAFE_UPDATES = 1;

-- Questão 4 — Correção do valor total (Executado antes da Q3 para usar a base de preço correta)
UPDATE vendas
SET valor_total = quantidade * valor_unitario
WHERE id_venda = 10;

-- Desativa temporariamente a trava de segurança do MySQL para UPDATEs sem Primary Key
SET SQL_SAFE_UPDATES = 0;

-- Questão 3 — Reajuste do valor unitário (+10% em Informática)
UPDATE vendas
SET valor_unitario = valor_unitario * 1.10
WHERE categoria = 'Informática';

-- Reativa a trava de segurança
SET SQL_SAFE_UPDATES = 1;

-- ============================================================
-- 5. EXCLUSÕES (DELETE)
-- ============================================================

-- Desativa a trava de segurança para permitir DELETE sem chave primária no WHERE
SET SQL_SAFE_UPDATES = 0;

-- Questão 5 — Exclusão de vendas canceladas antigas
DELETE FROM vendas
WHERE status_venda = 'Cancelada'
  AND data_venda < '2024-01-01';

-- Questão 6 — Exclusão de registros inválidos
DELETE FROM vendas
WHERE quantidade <= 0;

-- Reativa a trava de segurança
SET SQL_SAFE_UPDATES = 1;

-- ============================================================
-- 6. CONSULTAS E RELATÓRIOS (SELECT)
-- ============================================================

-- Questão 7 — Quantidade de vendas por categoria
SELECT 
    categoria,
    COUNT(id_venda) AS quantidade_vendas
FROM vendas
GROUP BY categoria
ORDER BY quantidade_vendas DESC;

-- Questão 8 — Resumo financeiro por categoria
SELECT 
    categoria,
    SUM(valor_total) AS valor_total_vendido,
    AVG(valor_total) AS valor_medio_vendas,
    MIN(valor_total) AS menor_valor_venda,
    MAX(valor_total) AS maior_valor_venda
FROM vendas
GROUP BY categoria
ORDER BY valor_total_vendido DESC;

-- Questão 9 — Total vendido por vendedor
SELECT 
    vendedor,
    COUNT(id_venda) AS quantidade_vendas,
    SUM(quantidade) AS total_produtos_vendidos,
    SUM(valor_total) AS valor_total_vendido
FROM vendas
GROUP BY vendedor
ORDER BY valor_total_vendido DESC;

-- Questão 10 — Relatório de vendas por estado
SELECT 
    estado_cliente,
    COUNT(id_venda) AS quantidade_vendas,
    SUM(quantidade) AS total_produtos_vendidos,
    SUM(valor_total) AS faturamento_total,
    AVG(valor_total) AS ticket_medio
FROM vendas
GROUP BY estado_cliente
HAVING SUM(valor_total) > 5000.00
ORDER BY faturamento_total DESC;