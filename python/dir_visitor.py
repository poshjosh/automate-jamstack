import os
import re
import shutil
import time

from typing import Callable, Union, AnyStr, Any
from translator import translate

def read_content(file_path: str):
    with open(file_path, 'r+') as text_file:
        return text_file.read()

def write_content(content: AnyStr, file_path: str):
    with open(file_path, 'w+') as text_file:
        text_file.write(content)

def rename_to_title_case(src_file, _):
    if src_file.endswith(".md") is False:
        return
    dirname = os.path.dirname(src_file)
    basename = os.path.basename(src_file)
    if basename[0].isupper() is False:
        title_case = os.path.join(dirname, basename[0].upper() + basename[1:])
        print(f"Rename {src_file} to {title_case}")
        os.rename(src_file, title_case)

def rename_without_question_mark(src_file, _, **kwargs):
    if src_file.endswith(".md") is False:
        return
    dirname = os.path.dirname(src_file)
    basename = os.path.basename(src_file)
    if str(basename).endswith("?.md"):
        # es question mark has first and last respectively = ¿ and ?
        offset = basename.startswith("¿") and 1 or 0
        tgt_file = os.path.join(dirname, basename[offset:-4] + ".md")
        print(f"\nSrc: {src_file}\nTgt: {tgt_file}")
        if kwargs.get("noop", False) is True:
            return
        os.rename(src_file, tgt_file)

def print_md(src_file, _):
    if src_file.endswith(".md") is False:
        return
    print(src_file)

def visit_dirs(action: Callable[[str, str, dict[str, Any]], None],
               root_src_dir: str = '.',
               root_dst_dir: str = None,
               test: Union[Callable[[str, str], bool], None] = None,
               **kwargs):
    """
    Visits recursively the source directory and performs the action on each file.

    The below code moves all the dir and files from the current directory to the directory ./abc
    highlight:: python
    code-block:: python
    visit_dir(lambda src, dst: shutil.move(src, dst), '.', './abc')
    """
    if not root_src_dir:
        raise ValueError("Source directory cannot be none or empty")
    for src_dir, dirs, files in os.walk(root_src_dir):
        dst_dir = None if not root_dst_dir else src_dir.replace(root_src_dir, root_dst_dir, 1)
        if dst_dir and not os.path.exists(dst_dir):
            os.makedirs(dst_dir)
        for file_ in files:
            src_file = os.path.join(src_dir, file_)
            dst_file = None if not dst_dir else os.path.join(dst_dir, file_)
            if test is None or test(src_file, dst_file):
                action(src_file, dst_dir, **kwargs)

if __name__ == "__main__":

    print(f"cwd: {os.getcwd()}")

    project_dir="/Users/chinomso/dev_looseboxes/automate/liveabove3d.com"

    action = translate
    kwargs = {'tgt_langs': "ar,bn,de,es,fr,hi,it,ja,ko,ru,tr,uk,zh-cn".split(",")}

    action = rename_without_question_mark
    kwargs = {}

#     visit_dirs(action, project_dir, None, None, **kwargs)

