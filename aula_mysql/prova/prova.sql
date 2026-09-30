create database db_garantia_safra;
USE db_garantia_safra;
select* from garantia_safra;
 
-- O erro foi que eu tinha esquecido o select e o CSV não tinha anexado 


-- ============================================================================
-- ESTRUTURA DA TABELA
-- ============================================================================
-- ============================================================================
CREATE TABLE IF NOT EXISTS tb_garantia_safra (
    id_pagamento INT PRIMARY KEY,
    id_agricultor VARCHAR(20),
    uf_beneficiario VARCHAR(2),
    codigo_ibge_municipio VARCHAR(7),
    nome_municipio VARCHAR(100),
    data_pagamento DATE,
    valor_beneficio DECIMAL(10, 2)
);
-- EXERCÍCIO 1: PAINEL ANUAL POR UNIDADE DA FEDERAÇÃO
-- ============================================================================

WITH 
cte_1_1_base AS (
    SELECT *
    FROM garantia_safra
    WHERE ano_referencia >= 2020
),
-- Filtra apenas os registros cujo ano de referência é de 2020 em diante, ignorando anos anteriores.

cte_1_2_totais AS (
    SELECT 
        sigla_uf,
        ano_referencia,
        SUM(valor_parcela) AS valor_total,
        -- SUM(): Soma o valor de todas as parcelas do grupo.
        COUNT(valor_parcela) AS quantidade_parcelas,
        -- COUNT(coluna): Conta quantas parcelas não nulas foram pagas no grupo.
        COUNT(*) AS total_registros
        -- COUNT(*): Conta o total geral de linhas processadas para aquele grupo.
    FROM cte_1_1_base
    GROUP BY sigla_uf, ano_referencia
    -- GROUP BY: Agrupa os dados combinando cada Estado (sigla_uf) com cada Ano (ano_referencia).
),

cte_1_3_unicos AS (
    SELECT 
        sigla_uf,
        ano_referencia,
        COUNT(DISTINCT nis_favorecido) AS beneficiarios_unicos,
        -- COUNT(DISTINCT): Conta a quantidade de pessoas (NIS) sem duplicar um mesmo beneficiário no mesmo ano/UF.
        COUNT(DISTINCT id_municipio) AS municipios_atendidos
        -- COUNT(DISTINCT): Conta quantas cidades diferentes receberam o benefício sem repetição.
    FROM cte_1_1_base
    GROUP BY sigla_uf, ano_referencia
),

cte_1_4_estatisticas AS (
    SELECT 
        sigla_uf,
        ano_referencia,
        AVG(valor_parcela) AS ticket_medio,
        -- AVG(): Calcula a média aritmética dos valores de parcelas para o grupo.
        MAX(valor_parcela) AS maior_valor
        -- MAX(): Retorna o maior valor individual de parcela encontrado dentro do grupo.
    FROM cte_1_1_base
    GROUP BY sigla_uf, ano_referencia
),

cte_1_5_faixas AS (
    SELECT 
        sigla_uf,
        ano_referencia,
        CASE 
            WHEN AVG(valor_parcela) >= 800 THEN 'ALTO'
            WHEN AVG(valor_parcela) >= 500 THEN 'MÉDIO'
            ELSE 'BAIXO'
        END AS faixa_valor
        -- CASE/WHEN: Cria uma lógica condicional. Se a média da parcela for >= 800 define 'ALTO', se >= 500 'MÉDIO', senão 'BAIXO'.
    FROM cte_1_1_base
    GROUP BY sigla_uf, ano_referencia
)

SELECT 
    t.sigla_uf AS UF,
    t.ano_referencia AS ano,
    t.valor_total,
    t.quantidade_parcelas,
    u.beneficiarios_unicos,
    u.municipios_atendidos,
    ROUND(e.ticket_medio, 2) AS ticket_medio,
    -- ROUND(..., 2): Arredonda o valor decimal para exatamente duas casas após a vírgula.
    e.maior_valor,
    t.total_registros AS quantidade_por_faixa,
    f.faixa_valor AS classificacao_ticket_medio
FROM cte_1_2_totais t
JOIN cte_1_3_unicos u 
    ON t.sigla_uf = u.sigla_uf AND t.ano_referencia = u.ano_referencia
-- JOIN ... ON: Une a CTE de totais com a CTE de contagens únicas cruzando por estado e ano iguais.
JOIN cte_1_4_estatisticas e 
    ON t.sigla_uf = e.sigla_uf AND t.ano_referencia = e.ano_referencia
-- Une a CTE de estatísticas usando as chaves de UF e ano.
JOIN cte_1_5_faixas f 
    ON t.sigla_uf = f.sigla_uf AND t.ano_referencia = f.ano_referencia
-- Une a CTE de faixas usando as chaves de UF e ano.
ORDER BY t.ano_referencia, t.sigla_uf;
-- ORDER BY: Ordena o relatório final cronologicamente por ano e depois em ordem alfabética por UF.