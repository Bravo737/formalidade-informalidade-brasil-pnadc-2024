SELECT
    dados.indice AS Indice_IPCA,  -- Valor acumulado do índice de preços
    dados.ano AS Ano             -- Ano de referência (para o JOIN)
FROM
    `basedosdados.br_ibge_ipca.mes_brasil` AS dados
WHERE
    -- Filtra apenas os valores de Dezembro, que representam o índice acumulado anual.
    dados.mes = 12
    -- Filtra os anos relevantes para sua análise da PNAD (2012 a 2023)
    AND dados.ano >= 2012
ORDER BY
    dados.ano ASC