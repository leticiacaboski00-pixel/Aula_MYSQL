CREATE DATABASE sql_quest;

USE sql_quest;

CREATE TABLE jogadores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    classe VARCHAR(50) NOT NULL,
    nivel INT NOT NULL,
    moedas INT NOT NULL DEFAULT 0,
    pontos INT NOT NULL,
    guilda VARCHAR(50),
    bonus INT,
    status_jogador VARCHAR(30) NOT NULL,
    classificacao VARCHAR(30)
);

INSERT INTO jogadores
(nome, classe, nivel, moedas, pontos, guilda, bonus, status_jogador)
VALUES
('Arthas', 'Guerreiro', 18, 950, 7200, 'Dragões', 500, 'ATIVO'),

('Luna', 'Maga', 22, 1500, 9800, 'Fênix', NULL, 'ATIVO'),

('Thorim', 'Guerreiro', 15, 450, 5100, 'Dragões', 300, 'ATIVO'),

('Nyx', 'Assassina', 26, 2100, 12500, 'Sombras', NULL, 'ATIVO'),

('Eldrin', 'Mago', 12, 300, 3900, 'Fênix', 200, 'ATIVO'),

('Kael', 'Arqueiro', 20, 1100, 8300, 'Dragões', NULL, 'ATIVO'),

('Morgana', 'Maga', 30, 3200, 16000, 'Sombras', 1000, 'ATIVO'),

('Ragnar', 'Guerreiro', 8, 150, 1800, 'Dragões', NULL, 'INATIVO'),

('Lyra', 'Arqueira', 17, 700, 6500, 'Fênix', 400, 'ATIVO'),

('Draven', 'Assassino', 25, 1800, 11200, 'Sombras', 700, 'ATIVO'),

('Orion', 'Mago', 6, 80, 900, NULL, NULL, 'INATIVO'),

('Freya', 'Guerreira', 21, 1300, 8900, 'Dragões', 600, 'ATIVO');