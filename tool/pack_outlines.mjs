// Builds assets/geo/outline.bin — the outline atlas behind find's first screen.
//
// Run rarely: the output is committed, and a fresh clone must not need Node.
// The reason it is committed and not fetched is ADR-089; the format is
// documented on OutlineAtlas in lib/data/geo/outline_atlas.dart, which reads it.
//
// Prerequisites, from this directory:
//
//   npm install mapshaper
//   for f in 10m_cultural/ne_10m_urban_areas \
//            10m_physical/ne_10m_coastline \
//            10m_physical/ne_10m_lakes \
//            10m_physical/ne_10m_rivers_lake_centerlines; do
//     curl -o "$(basename $f).zip" "https://naturalearth.s3.amazonaws.com/$f.zip"
//     unzip -oq "$(basename $f).zip" -d src/
//   done
//   for n in urban_areas coastline lakes rivers_lake_centerlines; do
//     npx mapshaper src/ne_10m_$n.shp -filter-fields -simplify 12% keep-shapes \
//       -o precision=0.001 format=geojson out2/$n.json
//   done
//   node pack_outlines.mjs
//
// **12% and 0.001 degrees are not arbitrary.** find draws at 24-150km across a
// phone, which is 60-380 metres to a pixel; 0.001 degrees is about 110 metres,
// and simplifying harder than 12% starts showing on a filled city's edge. The
// pair was checked by rendering Mumbai, Bangalore and Pune at both settings.
//
// Natural Earth is public domain, so nothing it draws has to be credited.
import fs from 'fs';
const CELL = 2, LAYERS = ['urban_areas','coastline','lakes','rivers_lake_centerlines'];
const POLY = new Set(['urban_areas','lakes']);   // closed, fillable; the rest are lines

const load = n => { const j = JSON.parse(fs.readFileSync(`./out2/${n}.json`,'utf8'));
  return (j.features ?? j.geometries).map(o => o.type==='Feature'?o.geometry:o); };
const rings = g => g.type==='Polygon'?g.coordinates:g.type==='MultiPolygon'?g.coordinates.flat()
  :g.type==='LineString'?[g.coordinates]:g.type==='MultiLineString'?g.coordinates:[];

const latIdx = lat => Math.min(Math.floor((lat+90)/CELL), 180/CELL-1);
const lonIdx = lon => Math.min(Math.floor((lon+180)/CELL), 360/CELL-1);
const keyOf = (lat,lon) => latIdx(lat)*180 + lonIdx(lon);

const cells = new Map();          // key -> { urban:[], coast:[], ... } of point arrays
const put = (key, layer, pts) => {
  if (pts.length < 2) return;
  let c = cells.get(key); if (!c) { c = {}; for (const l of LAYERS) c[l] = []; cells.set(key,c); }
  c[layer].push(pts);
};

for (const layer of LAYERS) {
  for (const g of load(layer)) for (const r of rings(g)) {
    if (POLY.has(layer)) {
      // a polygon must stay whole to be fillable: file it in every cell its bbox touches
      let b = [1/0,1/0,-1/0,-1/0];
      for (const [x,y] of r) { if(x<b[0])b[0]=x; if(y<b[1])b[1]=y; if(x>b[2])b[2]=x; if(y>b[3])b[3]=y; }
      for (let la = latIdx(b[1]); la <= latIdx(b[3]); la++)
        for (let lo = lonIdx(b[0]); lo <= lonIdx(b[2]); lo++) put(la*180+lo, layer, r);
    } else {
      // a line is cut at cell edges, each piece overlapping by one segment so no gap shows
      let run = [r[0]], key = keyOf(r[0][1], r[0][0]);
      for (let i = 1; i < r.length; i++) {
        const k = keyOf(r[i][1], r[i][0]);
        run.push(r[i]);
        if (k !== key) { put(key, layer, run); run = [r[i-1], r[i]]; key = k; }
      }
      put(key, layer, run);
    }
  }
}

// ---- encoding ----
const bytes = [];
const varint = n => { while (n >= 0x80) { bytes.push((n & 0x7f) | 0x80); n >>>= 7; } bytes.push(n); };
const zig = n => varint(n < 0 ? (-n * 2 - 1) : n * 2);
const md = v => Math.round(v * 1000);

const keys = [...cells.keys()].sort((a,b)=>a-b);
const chunks = [];
for (const key of keys) {
  const start = bytes.length, c = cells.get(key);
  for (const layer of LAYERS) {
    varint(c[layer].length);
    for (const pts of c[layer]) {
      varint(pts.length);
      let pLat = 0, pLon = 0;
      for (const [lon,lat] of pts) {
        const a = md(lat), o = md(lon);
        zig(a - pLat); zig(o - pLon); pLat = a; pLon = o;
      }
    }
  }
  chunks.push({ key, offset: start, length: bytes.length - start });
}

const HEAD = 8, IDX = chunks.length * 10;
const buf = Buffer.alloc(HEAD + IDX + bytes.length);
buf.write('CHTO', 0, 'ascii'); buf.writeUInt8(1,4); buf.writeUInt8(CELL,5);
buf.writeUInt16LE(chunks.length, 6);
chunks.forEach((c,i) => { const p = HEAD + i*10;
  buf.writeUInt16LE(c.key, p); buf.writeUInt32LE(c.offset + HEAD + IDX, p+2); buf.writeUInt32LE(c.length, p+6); });
Buffer.from(bytes).copy(buf, HEAD + IDX);
fs.writeFileSync('../assets/geo/outline.bin', buf);

const vtot = [...cells.values()].reduce((s,c)=>s+LAYERS.reduce((t,l)=>t+c[l].reduce((u,p)=>u+p.length,0),0),0);
console.log(`cells ${chunks.length}  shapes-vertices ${vtot} (after cell duplication)`);
console.log(`outline.bin ${(buf.length/1e6).toFixed(2)} MB  (header ${HEAD} + index ${IDX} + body ${bytes.length})`);
const big = chunks.reduce((m,c)=>Math.max(m,c.length),0);
console.log(`largest cell ${(big/1024).toFixed(1)} KB, mean ${(bytes.length/chunks.length/1024).toFixed(2)} KB`);
