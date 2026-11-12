// Sessao autenticada na tela do SIGA; executa POSTs de formulario (mesmo caminho da tela).
const fs=require('fs');const {chromium}=require('playwright');
module.exports=async function(BASE,usr,arq,fn){
 const senha=fs.readFileSync(arq,'utf8').trim();
 const b=await chromium.launch(); const p=await (await b.newContext({ignoreHTTPSErrors:true})).newPage();
 await p.goto(BASE+'/siga/',{waitUntil:'networkidle'});
 await p.fill('input[name="username"]',usr);await p.fill('input[name="password"]',senha);
 await Promise.all([p.waitForLoadState('networkidle'),p.click('button[type="submit"], input[type="submit"]')]);
 if(!p.url().includes('principal')) throw new Error('login falhou');
 const post=(caminho,dados)=>p.evaluate(async([c,d])=>{const r=await fetch(c,{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:new URLSearchParams(d).toString()});const t=await r.text();
   const m=t.match(/class="[^"]*alert[^"]*"[^>]*>([\s\S]{0,400}?)<\/div>/i)||t.match(/<title>([^<]*)<\/title>/i);return {status:r.status,url:r.url,msg:(m?m[1]:'').replace(/<[^>]+>/g,' ').replace(/\s+/g,' ').trim().slice(0,200)};},[caminho,dados]);
 const get=(caminho)=>p.evaluate(async(c)=>{const r=await fetch(c);return await r.text();},caminho);
 try{return await fn({p,post,get});}finally{await b.close();}
};
