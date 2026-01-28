SELECT
  dados.ano,
  dados.sigla_uf,
  ufs.nome AS sigla_uf_nome,
  dados.sexo,
  COUNTIF(dados.admitidos_desligados = '01') AS total_admitidos,
  COUNTIF(dados.admitidos_desligados = '02') AS total_desligados
FROM `basedosdados.br_me_caged.microdados_antigos_ajustes` AS dados
LEFT JOIN `basedosdados.br_bd_diretorios_brasil.uf` AS ufs
  ON dados.sigla_uf = ufs.sigla
GROUP BY
  ano, sigla_uf, sigla_uf_nome, sexo
ORDER BY
  ano, sigla_uf, sexo;
