#!/usr/bin/env python3

import argparse
import os
import shutil
import sys
import subprocess

from pathlib import Path

def num_pages(pfile):
    return int(subprocess.run(["/usr/bin/qpdf", "--show-npages", pfile], stdout=subprocess.PIPE).stdout)

def prefill(pages: map, num_pages: int):
    pages['N'] = range(1, num_pages + 1)


def parse_pages(p: str, num_pages: int) -> dict:
    if '-' in p:
        prange = p.split('-')
        start=int(prange[0])
        end=num_pages if prange[1].endswith('end') else int(prange[1])
        if end > num_pages:
            raise Exception("page number is large than number of pages!")

        if (start > end):
            # the range is in reverse, build and reverse
            pageset = list(range(end, start+1, 1))
            pageset.reverse()
        else:
            pageset = list(range(start, end+1, 1))
        return [str(i) for i in pageset]
    else:
        return [p]

def clear_pages(pages: dict):
    print(pages['N'])
    pages['N'] = [str(n) for n in pages['N'] if str(n) not in pages['D']]
    return pages

if __name__ == "__main__":

    parser = argparse.ArgumentParser(prog="mod_pdf")
    parser.add_argument("--pdf", type=str, help="working file")
    parser.add_argument("--pages", nargs='+', help="pages to modify")
    args = parser.parse_args()

    if args.pdf is None:
        print("Please provide at least one argument!")
        sys.exit(0)

    work_name = args.pdf

    if not os.path.exists(work_name):
        work_name = os.path.join(os.path.curdir, work_name)
    work_doc = Path(work_name)
    temp_doc = "/tmp/tmp_pdf_doco.pdf"

    shutil.copy(work_doc.name, temp_doc)

    pages = {
        'L': [],
        'R': [],
        'S': [],
        'D': [],
        'N': [],
    }
    n_pages = num_pages(temp_doc)
    prefill(pages, n_pages)
    for r in args.pages:
        for p in r.split(','):
            op = p[-1]

            if op not in pages.keys():
                op = 'N'
                to_parse = p
            else:
                to_parse = p[:-1]

            parsed_range = parse_pages(p[:-1], n_pages)
            pages[op].extend(parsed_range)

    pages=clear_pages(pages)

    cmd = [
        '/usr/bin/qpdf',
        '--empty',
        "--pages",
        f"{temp_doc}",
        ",".join(pages['N']) if len(pages['D']) > 0 else '',
        "--",
        f"{work_doc}",
        "--rotate=-90:{l_pages}".format(l_pages=",".join(pages['L'])) if len(pages['L']) > 0 else '',
        "--rotate=+90:{r_pages}".format(r_pages=",".join(pages['R'])) if len(pages['R']) > 0 else '',
        "--rotate=+180:{s_pages}".format(s_pages=",".join(pages['S'])) if len(pages['S']) > 0 else '',
    ]

    print("Command:\n{cmd}'\n".format(cmd=" ".join(cmd)))
    subprocess.run([c for c in cmd if c])

