// Uso: node perm3.js BASE USUARIO ARQ_SENHA SIGLAS...   (libera por SIGLA do servico, ex.: CAD_PESSOA)
const fs=require('fs');const {chromium}=require('playwright');
(async()=>{
 const [,,BASE,usr,arq,...siglas]=process.argv; const senha=fs.readFileSync(arq,'utf8').trim();
 const b=await chromium.launch(); const p=await (await b.newContext({ignoreHTTPSErrors:true})).newPage();
 await p.goto(BASE+'/siga/',{waitUntil:'networkidle'});
 await p.fill('input[name="username"]',usr);await p.fill('input[name="password"]',senha);
 await Promise.all([p.waitForLoadState('networkidle'),p.click('button[type="submit"], input[type="submit"]')]);
 if(!p.url().includes('principal')){console.log('login falhou');await b.close();process.exit(1);}
 const tok=await p.evaluate(async([u,s])=>(await (await fetch('/siga/api/v1/autenticar',{method:'POST',headers:{Authorization:'Basic '+btoa(u+':'+s)}})).json()).token,[usr,senha]);
 const idp=await p.evaluate(async([t,u])=>(await (await fetch('/siga/api/v1/pessoas/'+u,{headers:{Authorization:'Bearer '+t}})).json()).pessoa?.idPessoaIni,[tok,usr]);
 const lista=async()=>{await p.goto(BASE+'/siga/app/gi/acesso/listar?idAbrangencia=3&pessoaSel.id='+idp+'&pessoaSel.sigla='+usr,{waitUntil:'networkidle'});
   return p.$$eval('span[id^="SPAN-"]',a=>a.map(s=>({id:s.id.slice(5),sigla:(s.innerText.match(/^\s*([A-Z_]+):/)||[])[1],cor:s.querySelector('li')?.getAttribute('style')||'',acao:s.querySelector('a')?.innerText||''})));};
 for(const sg of siglas){
   const it=(await lista()).filter(i=>i.sigla===sg);
   if(!it.length){console.log(sg,': nao encontrado na arvore');continue;}
   for(const i of it){
     if(/green/.test(i.cor)){console.log(sg,i.id,': ja permitido');continue;}
     const r=await p.evaluate(async([id,idp])=>{const x=await fetch('/siga/app/gi/acesso/gravar?idServico='+id+'&idSituacao=1&pessoaSel.id='+idp);return x.status+' '+(await x.text()).replace(/<[^>]+>/g,' ').replace(/\s+/g,' ').trim().slice(0,90);},[i.id,idp]);
     console.log(sg,i.id,':',r);
   }
 }
 await b.close();
})();
