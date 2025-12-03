/*
Recebe um @id_fatura e retorna todos os detalhes necessários da fatura, incluindo:

Dados do cliente

Itens do pedido (nome do prato, quantidade, preço)

Valores totais e impostos
*/

CREATE FUNCTION fn_DetalhesFatura (
    @id_fatura INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        f.id_fatura,
        f.data AS data_fatura,
        c.nome AS cliente,
        c.nif,
        c.morada,
        c.localidade,
        c.codigo_postal,
        p.id_pedido,
        pr.nome AS prato,
        pp.quantidade,
        pr.preco_venda,
        (pp.quantidade * pr.preco_venda) AS subtotal,
        f.valor_total,
        f.valor_iva,
        (f.valor_total + f.valor_iva) AS total_com_iva
    FROM Fatura f
    JOIN Pedido p ON f.id_pedido = p.id_pedido
    JOIN Cliente c ON p.id_cliente = c.id_cliente
    JOIN Pedido_Prato pp ON p.id_pedido = pp.id_pedido
    JOIN Prato pr ON pp.id_prato = pr.id_prato
    WHERE f.id_fatura = @id_fatura
);

/* Como utilizar:
SELECT * FROM dbo.fn_DetalhesFatura(1);
*/