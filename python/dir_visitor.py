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
    dirname = os.path.dirname(src_file)
    basename = os.path.basename(src_file)
    if basename[0].isupper() is False:
        title_case = os.path.join(dirname, basename[0].upper() + basename[1:])
        print(f"Rename {src_file} to {title_case}")
        os.rename(src_file, title_case)

def rename_without_question_mark(src_file, _, **kwargs):
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

def rename_dir(src_file: str, _, **kwargs):
    target = kwargs.get("target")
    replacement = kwargs.get("replacement")
    if not target or not replacement:
        raise ValueError("Target and replacement cannot be none or empty")
    if target not in src_file:
        return
    tgt_file = src_file.replace(target, replacement)
    if os.path.exists(tgt_file):
        print(f"File already exists: {tgt_file}")
        return
    print(f"Will rename fm: {src_file}\nwill rename to: {tgt_file}")
    if kwargs.get("noop", False) is True:
        print("Noop mode -> will not rename")
        return
    tgt_dir = os.path.dirname(tgt_file)
    if not os.path.exists(tgt_dir):
        os.makedirs(tgt_dir)
    os.rename(src_file, tgt_file)
    src_dir = os.path.dirname(src_file)
    if len(os.listdir(src_dir)) == 0:
        print(f"Deleting empty dir: {src_dir}")
        os.rmdir(src_dir)

def delete_dir(src_file: str, _, **kwargs):
    target = kwargs.get("target")
    if not target:
        raise ValueError("Target cannot be none or empty")
    src_dir = os.path.dirname(src_file)
    if target in src_dir is False:
        return

    print(f"Deleting file: {src_file}")

    if kwargs.get("noop", False) is True:
        print("Noop mode -> will not delete")
    else:
        os.remove(src_file)

    last_file = len(os.listdir(src_dir)) == 1
    if last_file is True:
        print(f"Deleting empty dir: {src_dir}\n")
        if kwargs.get("noop", False) is True:
            print("Noop mode -> will not delete")
        else:
            os.rmdir(src_dir)

def print_md(src_file, _):
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

    root_dir="/Users/chinomso/dev_looseboxes/automate/liveabove3d.com"
    markdown_file_test = lambda src_file, _: src_file.endswith(".md") is True

    action = translate
    kwargs = {'tgt_langs': ['ar','bn','de','es','fr','hi','it','ja','ko','ru','tr','uk','zh']}

    action = rename_without_question_mark
    kwargs = {}

    action = rename_dir
    kwargs = {'target': 'zh-cn', 'replacement': 'zh', 'noop': True}

    root_dir="/Users/chinomso/Desktop/live-above-3D"
    action = delete_dir
    kwargs = {'target': 'blog', 'noop': True}

    visit_dirs(action, root_dir, None, markdown_file_test, **kwargs)

