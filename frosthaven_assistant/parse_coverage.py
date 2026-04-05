import re, sys

with open('coverage/lcov.info') as f:
    content = f.read()

blocks = content.strip().split('end_of_record')
results = []
for block in blocks:
    sf_match = re.search(r'^SF:(.+)$', block, re.MULTILINE)
    lf_match = re.search(r'^LF:(\d+)$', block, re.MULTILINE)
    lh_match = re.search(r'^LH:(\d+)$', block, re.MULTILINE)
    if sf_match and lf_match and lh_match:
        sf = sf_match.group(1).strip().replace('\\', '/')
        lf = int(lf_match.group(1))
        lh = int(lh_match.group(1))
        if lf > 0:
            pct = lh / lf * 100
            results.append((pct, lf, lh, sf))

threshold = float(sys.argv[1]) if len(sys.argv) > 1 else 75.0
below = [(p, lf, lh, sf) for p, lf, lh, sf in results if p < threshold]
below.sort(key=lambda x: x[0])

print(f"Files below {threshold}% coverage ({len(below)} files):")
print(f"{'Coverage':>10}  {'LH/LF':>10}  File")
print("-" * 80)
for pct, lf, lh, sf in below:
    # Strip the lib/ prefix for display
    short = sf.split('lib/')[-1] if 'lib/' in sf else sf
    print(f"{pct:9.1f}%  {lh:4}/{lf:<4}  {short}")
