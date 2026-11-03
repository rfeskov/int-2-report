import glob, platform, os, collections

m = platform.machine()
d = os.path.expanduser("~/lab/results")
st = sorted({os.path.basename(f).split("_")[0] for f in glob.glob(f"{d}/s*_{m}.tsv")})
rows = collections.OrderedDict()
for s in st:
    f = glob.glob(f"{d}/{s}_*_{m}.tsv")[0]
    for l in open(f):
        p = l.rstrip("\n").split("\t")
        if len(p) >= 2:
            rows.setdefault(p[0], {})[s] = p[1]
print("test".ljust(16) + "".join(s.ljust(8) for s in st))
for t, r in rows.items():
    print(t.ljust(16) + "".join(r.get(s, "-").ljust(8) for s in st))
