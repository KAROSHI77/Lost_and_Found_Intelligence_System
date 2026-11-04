// npm run setup : creates the database, tables, triggers, procedures, views and (once) the sample data
const mysql=require('mysql2/promise'),fs=require('fs'),path=require('path');
const split=sql=>{const out=[];let d=';',buf='';
 for(const line of sql.split(/\r?\n/)){
  const m=line.match(/^\s*DELIMITER\s+(\S+)/i);if(m){d=m[1];continue}
  if(/^\s*--/.test(line))continue;buf+=line+'\n';
  if(line.trimEnd().endsWith(d)){const s=buf.trim().slice(0,-d.length).trim();if(s)out.push(s);buf=''}}
 return out};
(async()=>{
 const c=await mysql.createConnection({host:process.env.DB_HOST||'localhost',port:+process.env.DB_PORT||3306,user:process.env.DB_USER||'root',password:process.env.DB_PASSWORD||''});
 const run=async f=>{for(const s of split(fs.readFileSync(path.join(__dirname,f),'utf8')))await c.query(s);console.log('Ran',f)};
 await run('schema.sql');
 const[[{n}]]=await c.query('SELECT COUNT(*) AS n FROM user');
 if(n===0)await run('seed.sql');else console.log('Users already exist, seed.sql skipped');
 await c.end();console.log('Database ready. Now run: npm start');
})().catch(e=>{console.error('Setup failed:',e.sqlMessage||e.message);process.exit(1)});
