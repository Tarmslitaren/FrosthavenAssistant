import re, sys

def show_uncovered(lcov_path, target_keyword):
    with open(lcov_path) as f:
        content = f.read()

    blocks = content.strip().split('end_of_record')
    for block in blocks:
        sf_match = re.search(r'^SF:(.+)$', block, re.MULTILINE)
        if not sf_match:
            continue
        sf = sf_match.group(1).strip().replace('\\', '/')
        if target_keyword not in sf:
            continue

        # Parse line hits
        hits = {}
        for m in re.finditer(r'^DA:(\d+),(\d+)', block, re.MULTILINE):
            line_no = int(m.group(1))
            count = int(m.group(2))
            hits[line_no] = count

        lf_m = re.search(r'^LF:(\d+)$', block, re.MULTILINE)
        lh_m = re.search(r'^LH:(\d+)$', block, re.MULTILINE)
        lf = int(lf_m.group(1)) if lf_m else 0
        lh = int(lh_m.group(1)) if lh_m else 0
        pct = lh/lf*100 if lf else 0

        uncovered = sorted([ln for ln, c in hits.items() if c == 0])
        print(f"File: {sf}")
        print(f"Coverage: {pct:.1f}% ({lh}/{lf})")
        print(f"Uncovered lines: {uncovered}")
        print()

if __name__ == '__main__':
    keyword = sys.argv[1] if len(sys.argv) > 1 else ''
    show_uncovered('coverage/lcov.info', keyword)
