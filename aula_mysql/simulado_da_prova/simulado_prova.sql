create database tb_base_de_dados_beneficios_cidadoes;

-- Exercício 1 – Painel Municipal Mensal
WITH dados_limpos AS (
    SELECT 
        ano_competencia,
        mes_competencia,
        id_municipio,
        sigla_uf,
        nis_favorecido,
        COALESCE(valor_parcela, 0) AS valor_parcela
    FROM db_simulado_prova.tb_base_de_dados_beneficios_cidadoes
    WHERE nis_favorecido IS NOT NULL 
      AND TRIM(nis_favorecido) <> ''
)
SELECT 
    ano_competencia,
    mes_competencia,
    id_municipio,
    sigla_uf,
    SUM(valor_parcela) AS total_gasto,
    COUNT(DISTINCT nis_favorecido) AS total_cidadaos_atendidos,
    ROUND(AVG(valor_parcela), 2) AS valor_medio_repasse,
    MAX(valor_parcela) AS maior_valor_pago
FROM dados_limpos
GROUP BY 
    ano_competencia,
    mes_competencia,
    id_municipio,
    sigla_uf
ORDER BY 
    ano_competencia DESC,
    mes_competencia DESC,
    total_gasto DESC;


-- Exercício 2 – Qualidade de Dados
WITH cpfs_com_multiplos_nis AS (
    SELECT cpf_favorecido
    FROM db_simulado_prova.tb_base_de_dados_beneficios_cidadoes
    WHERE cpf_favorecido IS NOT NULL AND TRIM(cpf_favorecido) <> ''
    GROUP BY cpf_favorecido
    HAVING COUNT(DISTINCT nis_favorecido) > 1
),
nis_com_multiplos_cpf AS (
    SELECT nis_favorecido
    FROM db_simulado_prova.tb_base_de_dados_beneficios_cidadoes
    WHERE nis_favorecido IS NOT NULL AND TRIM(nis_favorecido) <> ''
    GROUP BY nis_favorecido
    HAVING COUNT(DISTINCT cpf_favorecido) > 1
)
SELECT DISTINCT
    b.cpf_favorecido,
    b.nis_favorecido,
    b.nome_favorecido
FROM db_simulado_prova.tb_base_de_dados_beneficios_cidadoes b
WHERE b.cpf_favorecido IN (SELECT cpf_favorecido FROM cpfs_com_multiplos_nis)
   OR b.nis_favorecido IN (SELECT nis_favorecido FROM nis_com_multiplos_cpf)
ORDER BY b.cpf_favorecido, b.nis_favorecido;


-- Exercício 3 – Ranking por Município dentro da UF
WITH total_por_municipio AS (
    SELECT 
        ano_competencia,
        mes_competencia,
        sigla_uf,
        id_municipio,
        SUM(COALESCE(valor_parcela, 0)) AS total_gasto_municipio
    FROM db_simulado_prova.tb_base_de_dados_beneficios_cidadoes
    GROUP BY 
        ano_competencia,
        mes_competencia,
        sigla_uf,
        id_municipio
)
SELECT 
    ano_competencia,
    mes_competencia,
    sigla_uf,
    id_municipio,
    total_gasto_municipio,
    DENSE_RANK() OVER (
        PARTITION BY ano_competencia, mes_competencia, sigla_uf 
        ORDER BY total_gasto_municipio DESC
    ) AS pos_uf
FROM total_por_municipio
ORDER BY 
    sigla_uf,
    ano_competencia DESC,
    mes_competencia DESC,
    pos_uf;


-- Exercício 4 – Participação do Município no Total da UF
WITH total_municipio AS (
    SELECT 
        ano_competencia,
        mes_competencia,
        sigla_uf,
        id_municipio,
        SUM(COALESCE(valor_parcela, 0)) AS valor_municipio
    FROM db_simulado_prova.tb_base_de_dados_beneficios_cidadoes
    GROUP BY ano_competencia, mes_competencia, sigla_uf, id_municipio
),
total_uf AS (
    SELECT 
        ano_competencia,
        mes_competencia,
        sigla_uf,
        SUM(COALESCE(valor_parcela, 0)) AS valor_total_uf
    FROM db_simulado_prova.tb_base_de_dados_beneficios_cidadoes
    GROUP BY ano_competencia, mes_competencia, sigla_uf
)
SELECT 
    m.ano_competencia,
    m.mes_competencia,
    m.sigla_uf,
    m.id_municipio,
    m.valor_municipio,
    u.valor_total_uf,
    ROUND((m.valor_municipio / u.valor_total_uf) * 100, 2) AS share_pct
FROM total_municipio m
JOIN total_uf u 
  ON m.ano_competencia = u.ano_competencia 
 AND m.mes_competencia = u.mes_competencia 
 AND m.sigla_uf = u.sigla_uf
ORDER BY m.sigla_uf, m.ano_competencia DESC, m.mes_competencia DESC, share_pct DESC;


-- Exercício 5 – Perfil do Beneficiário
WITH resumo_cpf AS (
    SELECT 
        ano_competencia,
        mes_competencia,
        id_municipio,
        cpf_favorecido,
        nome_favorecido,
        SUM(COALESCE(valor_parcela, 0)) AS total_recebido_cpf,
        ROUND(AVG(COALESCE(valor_parcela, 0)), 2) AS media_valor_parcela,
        COUNT(*) AS qtd_registros
    FROM db_simulado_prova.tb_base_de_dados_beneficios_cidadoes
    WHERE cpf_favorecido IS NOT NULL AND TRIM(cpf_favorecido) <> ''
    GROUP BY ano_competencia, mes_competencia, id_municipio, cpf_favorecido, nome_favorecido
),
resumo_municipio AS (
    SELECT 
        ano_competencia,
        mes_competencia,
        id_municipio,
        SUM(COALESCE(valor_parcela, 0)) AS total_municipio
    FROM db_simulado_prova.tb_base_de_dados_beneficios_cidadoes
    GROUP BY ano_competencia, mes_competencia, id_municipio
)
SELECT 
    c.ano_competencia,
    c.mes_competencia,
    c.id_municipio,
    c.cpf_favorecido,
    c.nome_favorecido,
    c.total_recebido_cpf,
    c.media_valor_parcela,
    c.qtd_registros,
    ROUND((c.total_recebido_cpf / m.total_municipio) * 100, 4) AS pct_participacao_municipio
FROM resumo_cpf c
JOIN resumo_municipio m 
  ON c.ano_competencia = m.ano_competencia 
 AND c.mes_competencia = m.mes_competencia 
 AND c.id_municipio = m.id_municipio
ORDER BY c.total_recebido_cpf DESC;