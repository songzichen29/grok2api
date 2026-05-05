import re, sys, time, shutil
p = '/root/grok2api/data/config.toml'
shutil.copy2(p, p + '.bak.' + str(int(time.time())))
s = open(p, encoding='utf-8').read()

def sub_section(text, section, key, value):
    pat = r'(\[' + re.escape(section) + r'\][^\[]*?' + re.escape(key) + r'\s*=\s*)"[^"]*"'
    new = r'\g<1>"' + value + '"'
    return re.sub(pat, new, text, count=1)

s = sub_section(s, 'proxy.egress',    'mode',               'single_proxy')
s = sub_section(s, 'proxy.egress',    'proxy_url',          'http://host.docker.internal:7890')
s = sub_section(s, 'proxy.egress',    'resource_proxy_url', 'http://host.docker.internal:7890')
s = sub_section(s, 'proxy.clearance', 'mode',               'flaresolverr')
s = sub_section(s, 'proxy.clearance', 'flaresolverr_url',   'http://flaresolverr:8191')

open(p, 'w', encoding='utf-8').write(s)
print('PATCHED')
