#!/usr/bin/env python3
"""Generate fully self-contained Sangara_Mobile_Preview.html (no runtime dependencies)."""
from pathlib import Path
import base64, json, re
root=Path(__file__).resolve().parent.parent
html=(root/'templates/mobile-preview.template.html').read_text(encoding='utf-8')
css=(root/'app/globals.css').read_text(encoding='utf-8')
css=re.sub(r"@import\s+['\"]tailwindcss['\"];?",'',css)
assets={}
for name in ['collection','tray','vase','box','coaster','mold','resin']:
 p=root/'public/images'/('collection-optimized.webp' if name=='collection' else name+'.webp')
 assets[name]='data:image/webp;base64,'+base64.b64encode(p.read_bytes()).decode('ascii')
products=(root/'data/products.json').read_text(encoding='utf-8')
html=html.replace('__INLINED_CSS__',css).replace('__CATALOG_JSON__',products.replace('</','<\\/'))
html=html.replace('__ASSETS_JSON__',json.dumps(assets,ensure_ascii=False,separators=(',',':')))
out=root/'Sangara_Mobile_Preview.html';out.write_text(html,encoding='utf-8')
print('Generated',out,out.stat().st_size,'bytes with',len(assets),'embedded images')
