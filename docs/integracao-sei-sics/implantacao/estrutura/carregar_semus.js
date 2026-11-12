// Cadastra a estrutura da SEMUS no SIGA pelas mesmas telas que um administrador usaria.
// Uso: node carregar_semus.js BASE ARQ_SENHA_ADMIN estrutura.json [pessoas.json]
// Idempotente: o que já existe é reaproveitado (órgão, cargo, unidades e pessoas pela sigla/CPF).
const fs = require('fs');
const sessao = require('./sessao');
const [, , BASE, ARQ, ESTRUTURA, PESSOAS] = process.argv;
const unidades = JSON.parse(fs.readFileSync(ESTRUTURA, 'utf8'));
const pessoas = PESSOAS ? JSON.parse(fs.readFileSync(PESSOAS, 'utf8')) : [];
const ORGAO = { sigla: 'SEMUS', nome: 'SECRETARIA MUNICIPAL DE SAUDE' };
const CARGO = 'SERVIDOR';

sessao(BASE, 'ZZ99999', ARQ, async ({ p, post }) => {
  const senha = fs.readFileSync(ARQ, 'utf8').trim();
  const api = async (caminho) => p.evaluate(async ([c, s]) => {
    if (!window.__tok) window.__tok = (await (await fetch('/siga/api/v1/autenticar', { method: 'POST', headers: { Authorization: 'Basic ' + btoa('ZZ99999:' + s) } })).json()).token;
    const r = await fetch(c, { headers: { Authorization: 'Bearer ' + window.__tok } });
    try { return await r.json(); } catch { return { errormsg: 'HTTP ' + r.status }; }
  }, [caminho, senha]);
  const log = (...a) => console.log(...a);

  // Município
  const locs = await api('/siga/api/v1/localidades?idUf=27&texto=Aragua');
  const loc = (locs.list || []).find((l) => /aragua/i.test(l.nome));
  if (!loc) throw new Error('Município Araguaína não cadastrado no SIGA (cp_localidade). Rode o comando de banco primeiro.');
  log('município', loc.idLocalidade, loc.nome);

  // Órgão
  let org = (await api('/siga/api/v1/orgaos/' + ORGAO.sigla)).orgao;
  if (!org) {
    const r = await post('/siga/app/orgaoUsuario/gravar', { nmOrgaoUsuario: ORGAO.nome, siglaOrgaoUsuario: ORGAO.sigla, isExternoOrgaoUsu: 'false', acao: 'i' });
    log('criar órgão:', r.status, r.msg);
    org = (await api('/siga/api/v1/orgaos/' + ORGAO.sigla)).orgao;
  }
  if (!org) throw new Error('Órgão não foi criado.');
  log('órgão', org.idOrgao, org.sigla);

  // Cargo
  const buscaCargo = async () => ((await api('/siga/api/v1/cargos?idOrgao=' + org.idOrgao + '&nome=' + encodeURIComponent(CARGO))).list || []).find((c) => c.nome === CARGO);
  let cargo = await buscaCargo();
  if (!cargo) { const r = await post('/siga/app/cargo/gravar', { nmCargo: CARGO, idOrgaoUsu: String(org.idOrgao) }); log('criar cargo:', r.status, r.msg); cargo = await buscaCargo(); }
  if (!cargo) throw new Error('Cargo não foi criado.');
  log('cargo', cargo.idCargo, cargo.nome);

  // Unidades, em ordem (pai antes do filho)
  const ids = {};
  let criadas = 0, existentes = 0, falhas = 0;
  for (const u of unidades) {
    const completa = ORGAO.sigla + u.sigla;
    let l = (await api('/siga/api/v1/lotacoes/' + encodeURIComponent(completa))).lotacao;
    if (!l) {
      const dados = { nmLotacao: u.nome, siglaLotacao: u.sigla, idOrgaoUsu: String(org.idOrgao), situacao: 'true', isExternaLotacao: 'false', idLocalidade: String(loc.idLocalidade) };
      if (u.pai) {
        if (!ids[u.pai]) { log('  sem pai criado para', u.sigla, '(pai', u.pai + ')'); falhas++; continue; }
        dados.lotacaoPai = String(ids[u.pai]);
      }
      const r = await post('/siga/app/lotacao/gravar', dados);
      l = (await api('/siga/api/v1/lotacoes/' + encodeURIComponent(completa))).lotacao;
      if (!l) { log('  falha', u.sigla, r.status, r.msg); falhas++; continue; }
      criadas++;
    } else existentes++;
    ids[u.sigla] = l.idLotacao;
  }
  log(`unidades: ${criadas} criadas, ${existentes} já existiam, ${falhas} falhas`);

  // Pessoas
  for (const pe of pessoas) {
    const lot = ids[pe.unidade];
    if (!lot) { log('pessoa', pe.nome, ': unidade', pe.unidade, 'não encontrada'); continue; }
    const ja = await api('/siga/api/v1/pessoas?cpf=' + pe.cpf);
    if ((ja.list || []).length) { await post('/siga/app/pessoa/enviar', { idOrgaoUsu: String(org.idOrgao), cpfPesquisa: pe.cpf }); log('pessoa já existe (acesso conferido):', ja.list[0].sigla, ja.list[0].nome); continue; }
    const r = await post('/siga/app/pessoa/gravar', { idOrgaoUsu: String(org.idOrgao), idCargo: String(cargo.idCargo), idLotacao: String(lot), nmPessoa: pe.nome, nomeExibicao: pe.nomeExibicao || '', cpf: pe.cpf, email: pe.email, idFuncao: '0', enviarEmail: 'true' });
    const depois = await api('/siga/api/v1/pessoas?cpf=' + pe.cpf);
    const nova = (depois.list || [])[0];
    log('pessoa', pe.nome, '->', nova ? nova.sigla + ' / ' + (nova.lotacao || {}).sigla : 'FALHOU ' + r.status + ' ' + r.msg);
  }
  // Anexação de PDFs liberada para todo o órgão SEMUS (a regra geral do SIGA de teste proíbe).
  const qa = new URLSearchParams({ idTpConfiguracao: '1', idTpMov: '2', idSituacao: '1', idOrgaoUsu: String(org.idOrgao), nmTipoRetorno: '' });
  const ra = await p.evaluate(async (q) => (await fetch('/sigaex/app/configuracao/editar_gravar?' + q)).status, qa.toString());
  log('anexação liberada para SEMUS:', ra);
  fs.writeFileSync('resultado_carga.json', JSON.stringify({ orgao: org, cargo, ids }, null, 1));
});
