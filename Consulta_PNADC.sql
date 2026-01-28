-- PNADC microdados: construção de base agregada para análise do mercado de trabalho

WITH microdados_ocupados AS (
  SELECT
    dados.ano,
    dados.sigla_uf,
    
    -- Variáveis sociodemográficas
    d_sexo.valor AS sexo,
    d_cor.valor AS cor_raca,
    d_esc.valor AS nivel_instrucao,
    
    -- Características da ocupação
    d_pos.valor AS posicao_ocupacao,
    d_setor.valor AS setor_atividade,
    
    -- Grupos etários (a partir da idade em anos completos)
    CASE 
      WHEN SAFE_CAST(dados.V2009 AS INT64) BETWEEN 14 AND 17 THEN '14 a 17 anos'
      WHEN SAFE_CAST(dados.V2009 AS INT64) BETWEEN 18 AND 24 THEN '18 a 24 anos'
      WHEN SAFE_CAST(dados.V2009 AS INT64) BETWEEN 25 AND 39 THEN '25 a 39 anos'
      WHEN SAFE_CAST(dados.V2009 AS INT64) BETWEEN 40 AND 59 THEN '40 a 59 anos'
      WHEN SAFE_CAST(dados.V2009 AS INT64) >= 60 THEN '60 anos ou mais'
      ELSE 'Não classificado' 
    END AS grupo_idade,
    
    -- Indicadores institucionais do vínculo de trabalho
    d_cart.valor AS carteira_assinada,
    d_cnpj.valor AS tem_cnpj,
    d_serv.valor AS servidor_estatutario,
    d_prev.valor AS contribui_previdencia,
    
    -- Variáveis quantitativas
    SAFE_CAST(dados.V1028 AS FLOAT64) AS peso_amostral,
    SAFE_CAST(dados.VD4020 AS FLOAT64) AS rendimento_mensal,
    SAFE_CAST(dados.VD4031 AS FLOAT64) AS horas_trabalhadas

  FROM `basedosdados.br_ibge_pnadc.microdados` AS dados
  
  -- Junção com dicionário para decodificação das variáveis categóricas
  LEFT JOIN `basedosdados.br_ibge_pnadc.dicionario` AS d_sexo
    ON d_sexo.nome_coluna = 'V2007' AND CAST(dados.V2007 AS STRING) = d_sexo.chave

  LEFT JOIN `basedosdados.br_ibge_pnadc.dicionario` AS d_cor
    ON d_cor.nome_coluna = 'V2010' AND CAST(dados.V2010 AS STRING) = d_cor.chave

  LEFT JOIN `basedosdados.br_ibge_pnadc.dicionario` AS d_esc
    ON d_esc.nome_coluna = 'VD3004' AND CAST(dados.VD3004 AS STRING) = d_esc.chave

  LEFT JOIN `basedosdados.br_ibge_pnadc.dicionario` AS d_pos
    ON d_pos.nome_coluna = 'VD4009' AND CAST(dados.VD4009 AS STRING) = d_pos.chave

  LEFT JOIN `basedosdados.br_ibge_pnadc.dicionario` AS d_setor
    ON d_setor.nome_coluna = 'VD4008' AND CAST(dados.VD4008 AS STRING) = d_setor.chave

  LEFT JOIN `basedosdados.br_ibge_pnadc.dicionario` AS d_cart
    ON d_cart.nome_coluna = 'V4029' AND CAST(dados.V4029 AS STRING) = d_cart.chave

  LEFT JOIN `basedosdados.br_ibge_pnadc.dicionario` AS d_cnpj
    ON d_cnpj.nome_coluna = 'V4019' AND CAST(dados.V4019 AS STRING) = d_cnpj.chave

  LEFT JOIN `basedosdados.br_ibge_pnadc.dicionario` AS d_serv
    ON d_serv.nome_coluna = 'V4028' AND CAST(dados.V4028 AS STRING) = d_serv.chave

  LEFT JOIN `basedosdados.br_ibge_pnadc.dicionario` AS d_prev
    ON d_prev.nome_coluna = 'VD4012' AND CAST(dados.VD4012 AS STRING) = d_prev.chave
  
  -- Restrição ao universo de pessoas ocupadas
  WHERE SAFE_CAST(dados.VD4002 AS INT64) = 1
    AND dados.ano BETWEEN 2012 AND 2023
    AND SAFE_CAST(dados.trimestre AS INT64) = 4
)

-- Agregação por ano, unidade da federação e características individuais e ocupacionais
SELECT 
  ano, 
  sigla_uf, 
  sexo,
  cor_raca,
  nivel_instrucao,
  posicao_ocupacao,
  setor_atividade,
  grupo_idade,
  carteira_assinada,
  tem_cnpj,
  servidor_estatutario,
  contribui_previdencia,
  
  SUM(peso_amostral) AS total_pessoas_estimado,
  SUM(rendimento_mensal * peso_amostral) AS massa_renda_total,
  SUM(horas_trabalhadas * peso_amostral) AS massa_horas_total,
  SAFE_DIVIDE(SUM(rendimento_mensal * peso_amostral), SUM(peso_amostral)) AS rendimento_medio_estimado,
  SAFE_DIVIDE(SUM(horas_trabalhadas * peso_amostral), SUM(peso_amostral)) AS horas_medias_estimadas

FROM microdados_ocupados

GROUP BY 
  ano, 
  sigla_uf, 
  sexo,
  cor_raca,
  nivel_instrucao,
  posicao_ocupacao,
  setor_atividade,
  grupo_idade,
  carteira_assinada,
  tem_cnpj,
  servidor_estatutario,
  contribui_previdencia

ORDER BY ano, sigla_uf;
