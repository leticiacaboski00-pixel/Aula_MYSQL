USE pizzaria_tech_dw;

SELECT 'Clientes' AS tabela, COUNT(*) AS total FROM dim_cliente
UNION ALL
SELECT 'Produtos', COUNT(*) FROM dim_produto
UNION ALL
SELECT 'Vendedores', COUNT(*) FROM dim_vendedor
UNION ALL
SELECT 'Datas', COUNT(*) FROM dim_tempo
UNION ALL
SELECT 'Vendas', COUNT(*) FROM fact_venda;