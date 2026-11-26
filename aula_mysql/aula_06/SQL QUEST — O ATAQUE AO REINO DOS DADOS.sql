create database db_desafio;
USE db_desafio;
select* from db_desafio;

UPDATE jogadores
SET classificacao = CASE 
    WHEN pontos >= 12000 THEN 'LENDÁRIO'
    WHEN pontos >= 8000 THEN 'ELITE'
    WHEN pontos >= 5000 THEN 'VETERANO'
    ELSE 'APRENDIZ'
END;

UPDATE jogadores
SET bonus = COALESCE(bonus, 0);

UPDATE jogadores
SET moedas = moedas + 250
WHERE pontos > (SELECT AVG(pontos) FROM jogadores);

UPDATE jogadores
SET moedas = moedas + 300
WHERE guilda IN (
    SELECT guilda
    FROM jogadores
    WHERE guilda IS NOT NULL
    GROUP BY guilda
    HAVING AVG(pontos) > 7000
);

UPDATE jogadores
SET nivel = nivel + 1
WHERE id IN (
    SELECT id 
    FROM jogadores 
    ORDER BY pontos DESC 
    LIMIT 3
);
SELECT * 
FROM jogadores 
WHERE status = 'ATIVO' AND nivel < 18;

SELECT * 
FROM jogadores 
WHERE status = 'ATIVO' AND nivel < 18;

SELECT * 
FROM jogadores 
WHERE status = 'INATIVO' AND pontos < 2000;


DELETE FROM jogadores
WHERE status = 'INATIVO' AND pontos < 2000;

SELECT 
    id,
    nome,
    nivel,
    moedas,
    pontos,
    guilda,
    bonus,
    status,
    classificacao
FROM jogadores
ORDER BY pontos DESC;