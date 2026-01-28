SELECT
  dados.ano,
  dados.sigla_uf,
  ufs.nome AS sigla_uf_nome,
  COUNTIF(dados.admitidos_desligados = '01') AS total_admitidos,
  COUNTIF(dados.admitidos_desligados = '02') AS total_desligados,
  SUM(dados.saldo_movimentacao) AS saldo_total
FROM `basedosdados.br_me_caged.microdados_antigos_ajustes` AS dados
LEFT JOIN `basedosdados.br_bd_diretorios_brasil.uf` AS ufs
  ON dados.sigla_uf = ufs.sigla
GROUP BY
  ano, sigla_uf, sigla_uf_nome
ORDER BY
  ano, sigla_uf;
