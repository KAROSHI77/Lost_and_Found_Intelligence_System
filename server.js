const express=require('express'),mysql=require('mysql2/promise'),bcrypt=require('bcryptjs'),crypto=require('crypto');
const db=mysql.createPool({host:process.env.DB_HOST||'localhost',port:+process.env.DB_PORT||3306,user:process.env.DB_USER||'root',password:process.env.DB_PASSWORD||'',
 database:process.env.DB_NAME||'lost_found_intelligence',dateStrings:true,connectionLimit:10});
const q_=async(sql,p=[])=>(await db.query(sql,p))[0];
const PK={user:'user_id',category:'category_id',location:'location_id',lost_item:'lost_item_id',found_item:'found_item_id',item_match:'match_id',claim:'claim_id',verification:'verification_id',item_return:'return_id',item_image:'image_id',item_embedding:'embedding_id',notification:'notification_id',audit_log:'log_id'};
const ins=async(t,o,c=db)=>(await c.query(`INSERT INTO \`${t}\` SET ?`,[o]))[0].insertId;
const tbl=t=>{if(!PK[t])throw new Error('Unknown table');return t};

// ---- transaction helper: START TRANSACTION ... COMMIT / ROLLBACK
async function tx(fn){const c=await db.getConnection();try{await c.beginTransaction();const o=await fn(c);await c.commit();return o}catch(e){await c.rollback();throw e}finally{c.release()}}

// ---- matching engine (text similarity + category + location)
const tok=s=>new Set((s||'').toLowerCase().replace(/[^a-z ]/g,' ').split(/\s+/).filter(w=>w.length>2));
async function engine(){let n=0;const F=await q_("SELECT * FROM found_item WHERE status='AVAILABLE'");
 for(const l of await q_("SELECT * FROM lost_item WHERE status='ACTIVE'"))for(const f of F){
  if((await q_('SELECT 1 FROM item_match WHERE lost_item_id=? AND found_item_id=?',[l.lost_item_id,f.found_item_id])).length)continue;
  const a=tok(l.title+' '+l.description),b=tok(f.title+' '+f.description),i=[...a].filter(x=>b.has(x)).length,u=new Set([...a,...b]).size,
  sc=Math.min(.99,i/u*.6+(l.category_id==f.category_id?.2:0)+(l.location_id==f.location_id?.2:0));
  if(sc<.5)continue;n++;
  await ins('item_match',{lost_item_id:l.lost_item_id,found_item_id:f.found_item_id,similarity_score:+sc.toFixed(4),match_reason:'Auto-match on title, category, location and description similarity.'});
  await ins('notification',{user_id:l.user_id,related_type:'MATCH',related_id:l.lost_item_id,message:`A potential match has been found for your lost ${l.title}.`})}
 return n}

// ---- queries / views / procedures (all plain SQL)
const itemQ=(t,id,dt)=>async p=>{const w=[],a=[];if(p.status){w.push('i.status=?');a.push(p.status)}
 if(p.has)w.push((p.has=='yes'?'':'NOT ')+`EXISTS (SELECT 1 FROM item_match im WHERE im.${id}=i.${id})`);   // EXISTS / NOT EXISTS
 return q_(`SELECT i.${id} AS _id,i.title,i.description,u.name AS reported_by,c.name AS category,loc.name AS location,i.status,i.${dt}
  FROM ${t} i JOIN user u ON i.user_id=u.user_id JOIN category c ON i.category_id=c.category_id JOIN location loc ON i.location_id=loc.location_id
  ${w.length?'WHERE '+w.join(' AND '):''} ORDER BY i.${dt} ${p.order=='desc'?'DESC':'ASC'}`,a)};
const Q={
 lost_list:itemQ('lost_item','lost_item_id','lost_date_time'),found_list:itemQ('found_item','found_item_id','found_date_time'),
 proc_get_lost_items:async()=>(await db.query('CALL GetLostItems()'))[0][0],
 proc_lost_by_status:async p=>(await db.query('CALL GetLostItemsByStatus(?)',[p.status||'MATCHED']))[0][0],
 fn_match_count:()=>q_('SELECT lost_item_id,title,get_match_count(lost_item_id) AS matches FROM lost_item'),
 view_lost_item_details:()=>q_('SELECT * FROM lost_item_details'),
 view_item_match_details:()=>q_('SELECT * FROM item_match_details ORDER BY similarity_score DESC'),
 view_claim_verification_details:()=>q_('SELECT * FROM claim_verification_details'),
 distinct:async()=>[{status:(await q_('SELECT DISTINCT status FROM lost_item')).map(r=>r.status),category_id:(await q_('SELECT DISTINCT category_id FROM lost_item')).map(r=>r.category_id)}],
 aggregate:()=>q_('SELECT (SELECT COUNT(*) FROM lost_item) AS total_lost_items,MAX(similarity_score) AS highest_similarity,MIN(similarity_score) AS lowest_similarity,AVG(similarity_score) AS average_similarity,SUM(similarity_score) AS total_similarity_score FROM item_match'),
 group_lost_by_category:p=>q_('SELECT category_id,COUNT(*) AS total_lost_items FROM lost_item GROUP BY category_id HAVING COUNT(*)>=? ORDER BY category_id',[+p.min||1]),
 group_found_by_status:p=>q_('SELECT status,COUNT(*) AS total_items FROM found_item GROUP BY status HAVING COUNT(*)>=?',[+p.min||1]),
 lost_per_user:()=>q_('SELECT u.user_id,u.name,COUNT(l.lost_item_id) AS total_lost_items FROM user u LEFT JOIN lost_item l ON u.user_id=l.user_id GROUP BY u.user_id,u.name ORDER BY total_lost_items DESC'),
 category_lost_vs_found:()=>q_('SELECT c.category_id,c.name AS category,COUNT(DISTINCT l.lost_item_id) AS lost_count,COUNT(DISTINCT f.found_item_id) AS found_count FROM category c LEFT JOIN lost_item l ON c.category_id=l.category_id LEFT JOIN found_item f ON c.category_id=f.category_id GROUP BY c.category_id,c.name ORDER BY lost_count DESC'),
 top_match:()=>q_('SELECT match_id,lost_item_id,found_item_id,similarity_score,status FROM item_match WHERE similarity_score=(SELECT MAX(similarity_score) FROM item_match)'),
 lost_in_found_categories:()=>q_('SELECT lost_item_id,title,category_id FROM lost_item WHERE category_id IN (SELECT DISTINCT category_id FROM found_item)'),
 match_details:p=>{const w=[],a=[];if(p.min){w.push('im.similarity_score>=?');a.push(+p.min)}if(p.status){w.push('im.status=?');a.push(p.status)}
  return q_(`SELECT im.match_id,l.title AS lost_item,f.title AS found_item,l.description AS lost_description,f.description AS found_description,c.name AS category,loc.name AS location,im.similarity_score,im.match_reason,im.status
   FROM item_match im JOIN lost_item l ON im.lost_item_id=l.lost_item_id JOIN found_item f ON im.found_item_id=f.found_item_id
   JOIN category c ON l.category_id=c.category_id JOIN location loc ON l.location_id=loc.location_id ${w.length?'WHERE '+w.join(' AND '):''} ORDER BY im.similarity_score DESC`,a)},
 claim_details:(p,u)=>{const w=[],a=[];if(p.status){w.push('c.status=?');a.push(p.status)}if(u.role!='ADMIN'){w.push('c.user_id=?');a.push(u._id)}
  return q_(`SELECT c.claim_id,u.name AS claimant,l.title AS lost_item,f.title AS found_item,c.claim_description,c.status,v.verification_result AS verification,v.verified_at,ir.status AS return_status,c.resolved_at
   FROM claim c JOIN user u ON c.user_id=u.user_id JOIN lost_item l ON c.lost_item_id=l.lost_item_id JOIN found_item f ON c.found_item_id=f.found_item_id
   LEFT JOIN verification v ON c.claim_id=v.claim_id LEFT JOIN item_return ir ON c.claim_id=ir.claim_id ${w.length?'WHERE '+w.join(' AND '):''} ORDER BY c.claim_id`,a)},
 note_list:(p,u)=>{const w=[],a=[];if(p.status){w.push('status=?');a.push(p.status)}if(u.role!='ADMIN'){w.push('user_id=?');a.push(u._id)}
  return q_(`SELECT notification_id AS _id,user_id,related_type,related_id,message,status,created_at,read_at FROM notification ${w.length?'WHERE '+w.join(' AND '):''} ORDER BY created_at DESC,notification_id DESC`,a)}};

const app=express();app.use(express.json());app.use(express.static(__dirname+'/public'));
const A=f=>async(q,r)=>{try{r.json(await f(q,r))}catch(e){r.status(400).json({error:e.sqlMessage||e.message})}};
// ---- authentication: bcrypt passwords + revocable HTTP-only cookie sessions (user_session table)
const ck=q=>Object.fromEntries((q.headers.cookie||'').split(';').filter(Boolean).map(c=>{const i=c.indexOf('=');return[c.slice(0,i).trim(),decodeURIComponent(c.slice(i+1))]}));
const hash=t=>crypto.createHash('sha256').update(t).digest('hex'),adm=q=>{if(q.user.role!='ADMIN')throw new Error('Admin only')};
async function who(q){const t=ck(q).sid;if(!t)return null;
 const[u]=await q_('SELECT u.user_id AS _id,u.name,u.email,u.role,u.is_active FROM user_session s JOIN user u ON u.user_id=s.user_id WHERE s.token_hash=? AND s.revoked=0 AND s.expires_at>NOW()',[hash(t)]);return u&&u.is_active?u:null}
async function startSession(r,u){const t=crypto.randomBytes(32).toString('hex');
 await q_('INSERT INTO user_session (user_id,token_hash,expires_at) VALUES (?,?,DATE_ADD(NOW(),INTERVAL 7 DAY))',[u.user_id,hash(t)]);
 r.setHeader('Set-Cookie',`sid=${t}; HttpOnly; SameSite=Lax; Path=/; Max-Age=${7*86400}`);return{_id:u.user_id,name:u.name,email:u.email,role:u.role}}
app.post('/api/auth/register',A(async(q,r)=>{const{name,email,password,phone}=q.body;
 if(!name||!email||!password||password.length<6)throw new Error('Name, email and a password of at least 6 characters are required');
 if((await q_('SELECT 1 FROM user WHERE email=?',[email.toLowerCase()])).length)throw new Error('Email already registered');
 const id=await ins('user',{name,email:email.toLowerCase(),phone:phone||null,password_hash:await bcrypt.hash(password,10)});
 return startSession(r,{user_id:id,name,email:email.toLowerCase(),role:'USER'})}));
app.post('/api/auth/login',A(async(q,r)=>{const[u]=await q_('SELECT * FROM user WHERE email=?',[(q.body.email||'').toLowerCase()]);
 if(!u||!u.is_active||!(await bcrypt.compare(q.body.password||'',u.password_hash)))throw new Error('Invalid email or password');return startSession(r,u)}));
app.get('/api/auth/me',A(async q=>{const u=await who(q);if(!u)throw new Error('Not logged in');return u}));
app.post('/api/auth/logout',A(async(q,r)=>{const t=ck(q).sid;if(t)await q_('UPDATE user_session SET revoked=1 WHERE token_hash=?',[hash(t)]);r.setHeader('Set-Cookie','sid=; HttpOnly; Path=/; Max-Age=0');return{ok:true}}));
app.use('/api',async(q,r,n)=>{if(q.path.startsWith('/auth/'))return n();try{const u=await who(q);if(!u)return r.status(401).json({error:'Please log in'});q.user=u;n()}catch(e){r.status(500).json({error:e.message})}});

app.get('/api/q/:n',A(q=>Q[q.params.n](q.query,q.user)));
app.get('/api/crud/:c',A(async q=>{const t=tbl(q.params.c);if(/^(user|audit_log)$/.test(t))adm(q);
 const w=[],a=[];for(const[k,v]of Object.entries(q.query)){if(!/^\w+$/.test(k))throw new Error('Bad filter');w.push(`\`${k}\`=?`);a.push(v)}
 const rows=await q_(`SELECT *,\`${PK[t]}\` AS _id FROM \`${t}\` ${w.length?'WHERE '+w.join(' AND '):''} ORDER BY \`${PK[t]}\``,a);rows.forEach(r=>delete r.password_hash);return rows}));
app.put('/api/crud/:c/:id',A(async q=>{const t=tbl(q.params.c);
 if(t=='notification')return q_("UPDATE notification SET status='READ',read_at=NOW() WHERE notification_id=?"+(q.user.role!='ADMIN'?' AND user_id=?':''),[q.params.id,q.user._id]);
 adm(q);for(const k of Object.keys(q.body))if(!/^\w+$/.test(k))throw new Error('Bad field');
 return q_(`UPDATE \`${t}\` SET ? WHERE \`${PK[t]}\`=?`,[q.body,q.params.id])}));
app.delete('/api/crud/:c/:id',A(q=>{const t=tbl(q.params.c);adm(q);return q_(`DELETE FROM \`${t}\` WHERE \`${PK[t]}\`=?`,[q.params.id])}));

app.post('/api/report/:k',A(async q=>{const L=q.params.k=='lost',b=q.body,t=L?'lost_item':'found_item',dt=L?'lost_date_time':'found_date_time';
 if(!L&&!(b.title||'').trim())throw new Error('Found item title cannot be empty');
 // for lost items MySQL itself rejects an empty title (BEFORE INSERT trigger) and writes audit_log (AFTER INSERT trigger)
 const id=await ins(t,{user_id:q.user._id,category_id:b.category_id,location_id:b.location_id,title:b.title,description:b.description,[dt]:new Date()});
 await ins('item_embedding',{item_type:L?'LOST':'FOUND',item_id:id,embedding_reference:`embedding/${q.params.k}_item_${id}`,model_name:'Sentence-BERT'});
 if(b.image_url)await ins('item_image',{[L?'lost_item_id':'found_item_id']:id,image_url:b.image_url,image_type:L?'LOST':'FOUND'});
 return{id,matches_created:await engine()}}));
app.post('/api/match/run',A(async()=>({created:await engine()})));
app.post('/api/claims/from-match/:id',A(async q=>{const[m]=await q_('SELECT * FROM item_match WHERE match_id=?',[q.params.id]);if(!m)throw new Error('Match not found');
 const[l]=await q_('SELECT * FROM lost_item WHERE lost_item_id=?',[m.lost_item_id]);
 if(l.user_id!=q.user._id&&q.user.role!='ADMIN')throw new Error('Only the owner of the lost item can raise a claim');
 if((await q_('SELECT 1 FROM claim WHERE lost_item_id=? AND found_item_id=?',[m.lost_item_id,m.found_item_id])).length)throw new Error('A claim already exists for this match');
 return ins('claim',{user_id:l.user_id,lost_item_id:l.lost_item_id,found_item_id:m.found_item_id,claim_description:`This is my ${l.title.toLowerCase()}. ${l.description}`})}));
app.post('/api/claims/:id/approve',A(q=>{adm(q);return tx(async c=>{
 const[[cl]]=await c.query('SELECT * FROM claim WHERE claim_id=? FOR UPDATE',[q.params.id]);if(!cl)throw new Error('Claim not found');if(cl.status=='APPROVED')throw new Error('Claim already approved');
 await c.query("UPDATE claim SET status='APPROVED',resolved_at=CURRENT_TIMESTAMP WHERE claim_id=?",[cl.claim_id]);
 await c.query("UPDATE lost_item SET status='MATCHED' WHERE lost_item_id=?",[cl.lost_item_id]);
 await c.query("UPDATE found_item SET status='RETURNED' WHERE found_item_id=?",[cl.found_item_id]);
 await ins('verification',{claim_id:cl.claim_id,verified_by:q.user._id,verification_method:'IDENTITY_AND_ITEM_DETAILS',verification_result:'SUCCESS',notes:'Identity and item details successfully verified before return.'},c);
 await ins('item_return',{claim_id:cl.claim_id,verified_by:q.user._id,notes:'Item successfully returned to the verified claimant after approval.'},c);
 await ins('notification',{user_id:cl.user_id,related_type:'CLAIM',related_id:cl.claim_id,message:'Your claim was approved and the item is ready for return.'},c);return cl})}));
app.post('/api/tx/:k',A(async q=>{adm(q);const id=+q.body.id||10,k=q.params.k;if(!['commit','rollback','savepoint'].includes(k))throw new Error('Unknown transaction demo');
 const c=await db.getConnection(),u=(d)=>c.query('UPDATE lost_item SET description=? WHERE lost_item_id=?',[d,id]);
 try{await c.beginTransaction();
  if(k=='commit')await u('Updated description using transaction');
  if(k=='rollback')await c.query("UPDATE lost_item SET status='ACTIVE' WHERE lost_item_id=?",[id]);
  if(k=='savepoint'){await u('First transaction change');await c.query('SAVEPOINT sp1');await u('Second transaction change');await c.query('ROLLBACK TO SAVEPOINT sp1')}
  k=='rollback'?await c.rollback():await c.commit()}catch(e){await c.rollback();throw e}finally{c.release()}
 return(await q_('SELECT lost_item_id,title,status,description FROM lost_item WHERE lost_item_id=?',[id]))[0]}));

db.query('SELECT 1').catch(e=>console.error('MySQL error:',e.sqlMessage||e.message,'\nHave you run "npm run setup" and set DB_USER / DB_PASSWORD?'));
app.listen(process.env.PORT||3000,()=>console.log('Open http://localhost:'+(process.env.PORT||3000)));
