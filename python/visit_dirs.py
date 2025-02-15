import os
import re
import shutil
import time

from typing import Callable, Union, AnyStr, Any

import requests


class TextLines:
    def __init__(self, text: str):
        if not text:
            raise ValueError("Text is required")
        self.__lines_without_breaks: [str] = []
        self.__breaks: [int] = []
        self.__len = 0
        for line in text.splitlines(False):
            line = line.strip()
            if line == '' or len(line) == 0:
                self.__breaks.append(self.__len)
            else:
                self.__lines_without_breaks.append(line)
            self.__len += 1

    def is_multiline(self):
        return len(self.__lines_without_breaks) > 1

    def compose(self, lines: [str]) -> str:
        return '\n'.join(self.with_breaks(lines))

    def with_breaks(self, lines: [str]) -> [str]:
        result = [*lines]
        for break_idx in self.__breaks:
            result.insert(break_idx, "")
        return result

    def get_lines_without_breaks(self) -> [str]:
        return [e for e in self.__lines_without_breaks]

    def get_break_count(self) -> int:
        return len(self.__breaks)

    def __len__(self):
        return self.__len


class Translator:
    @classmethod
    def of_config(cls, agent_config: dict[str, any]) -> 'Translator':
        net_config = agent_config['net']
        return cls(net_config['service-url'],
                   net_config.get('chunk-size', 10000),
                   net_config.get('user-agent', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36'))

    __verbose = True

    def __init__(self,
                 service_url: str,
                 chunk_size: int = 10000,
                 user_agent: str = "aideas/translator"):
        self.__service_url = service_url
        self.__user_agent = user_agent
        self.__chunk_size = chunk_size
        # Do not put letters here, they may be translated or cause other inconsistencies.
        self.__separator: str = "~~~"

    @staticmethod
    def _chunkify(text_list: list[str], chunk_size: int) -> [str]:
        text_size = 0
        result_list = []
        chunk = []
        for line in text_list:
            line = line.strip()
            if text_size + len(line) < chunk_size:
                chunk.append(line)
                text_size += len(line)
            elif chunk and len(line) < chunk_size:
                result_list.append(chunk)
                chunk = [line]
                text_size = len(line)
        result_list.append(chunk)
        return result_list

    def translate(self, text: Union[list[str], str], from_lang: str, to_lang: str) -> Union[list[str], str]:
        if isinstance(text, str):
            text_lines = TextLines(text)
            text_list = text_lines.get_lines_without_breaks()
        else:
            text_lines = None
            text_list = text

        chunks = Translator._chunkify(text_list, self.__chunk_size)

        result_big_list = []
        for chunk in chunks:
            if not chunk:
                continue
            result = self.__translate(chunk, from_lang, to_lang)
            result_big_list.extend(result)

        return text_lines.compose(result_big_list) if text_lines else result_big_list

    def translate_file_path(self, filepath: str, from_lang: str, to_lang: str):
        name, ext = os.path.splitext(os.path.basename(filepath))
        name_translated: str = self.translate(name, from_lang, to_lang)
        if name_translated and name_translated != name:
            return os.path.join(os.path.dirname(filepath), f'{name_translated}{ext}')
        parts: [str] = filepath.rsplit('.', 1)
        if len(parts) < 2:
            return filepath + "." + to_lang
        else:
            return parts[0] + "." + to_lang + "." + parts[1]

    def __translate(self,
                    text_list: list[str],
                    from_lang: str,
                    to_lang: str) -> list[str]:
        if self.__verbose:
            print(f"Translate new chunk with {sum(len(i) for i in text_list)} chars")
        text = f" {self.__separator} ".join(text_list)
        params = {"client": "gtx", "sl": from_lang, "tl": to_lang, "dt": "t", "q": text}
        headers = {
            "User-Agent": self.__user_agent
        }
        json_result = self.call_translation_service(params=params, headers=headers)
        return self._handle_result(json_result)

    def _handle_result(self, json_result) -> list[str]:
        if not json_result or not json_result[0]:
            return []

        result = []
        return_string = " ".join(i[0].strip() for i in json_result[0])
        split = return_string.split(self.__separator)
        split = map(lambda x: x.strip(), split)
        result.extend(split)
        return list(filter(lambda x: x, result))

    def call_translation_service(self, params: dict, headers: dict) -> list[str]:
        # print(f"Requesting translation from: {self.__service_url}")
        r = requests.get(self.__service_url, params=params, headers=headers)
        return r.json()

    def get_separator(self) -> str:
        return self.__separator


def read_content(file_path: str):
    with open(file_path, 'r+') as text_file:
        return text_file.read()

def write_content(content: AnyStr, file_path: str):
    with open(file_path, 'w+') as text_file:
        text_file.write(content)

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


def rename_to_title_case(src_file, _):
    if src_file.endswith(".md") is False:
        return
    dirname = os.path.dirname(src_file)
    basename = os.path.basename(src_file)
    if basename[0].isupper() is False:
        title_case = os.path.join(dirname, basename[0].upper() + basename[1:])
        print(f"Rename {src_file} to {title_case}")
        os.rename(src_file, title_case)

def rename_without_question_mark(src_file, _):
    if src_file.endswith(".md") is False:
        return
    dirname = os.path.dirname(src_file)
    basename = os.path.basename(src_file)
    if str(basename).endswith("?.md"):
        tgt_file = os.path.join(dirname, basename[:-4] + ".md")
        print(f"\nSrc: {src_file}\nTgt: {tgt_file}")
        os.rename(src_file, tgt_file)

translator = Translator("https://translate.googleapis.com/translate_a/single")

def _translate(src_file: str, src_lang: str, tgt_lang: str) -> Union[str, None]:

    if src_file.endswith(".md") is False:
        return

    src_dir = os.path.dirname(src_file)
    basename = os.path.basename(src_file)
    if basename == "README.md":
        return
    if str(src_dir).endswith(src_lang) is False:
        # We are not in the en directory
        return

    tgt_dir = str(src_dir).replace(f"/{src_lang}", f"/{tgt_lang}")
    if os.path.exists(tgt_dir) is True:
        if len(os.listdir(tgt_dir)) == len(os.listdir(src_dir)):
            print(f"\tTranslation to {tgt_lang} already exists for: {src_file}")
            return

    name, ext = os.path.splitext(basename)
    src_content = read_content(src_file)
    # Remove image part i.e.: ![cover image](../cover.png "cover-image")
    m = re.match(r"!\[.+?\]\((.+?(png|jpg|jpeg|gif|webp)).*?\)", src_content)
    image_part = None if not m else m.group(0)
    if image_part:
        src_image_path = m.group(1).replace("../", f"{os.path.dirname(src_dir)}/").replace("./", f"{src_dir}/")
        tgt_image_path = m.group(1).replace("../", f"{os.path.dirname(tgt_dir)}/").replace("./", f"{tgt_dir}/")
        if src_image_path == tgt_image_path:
            src_image_path = ""
            tgt_image_path = ""
            print("\tNo need to move: ", src_image_path)
        src_content = src_content.replace(image_part, "").strip()
    else:
        src_image_path = ""
        tgt_image_path = ""
        print("\tNo image part for: ", src_file)

    new_name = translator.translate(name.replace("---", " - ").replace("-", " ").strip(), src_lang, tgt_lang)
    new_name = new_name.replace(" - ", "---").replace(" ", "-")

    tgt_content = translator.translate(src_content, src_lang, tgt_lang)

    tgt_file = os.path.join(tgt_dir, f"{new_name}{ext}")
    if os.path.exists(tgt_file) is True:
        print(f"\tTranslation to {tgt_lang} already exists for: {src_file}")
        return

    if not os.path.exists(tgt_dir):
        os.makedirs(tgt_dir)

    # Move cover image
    if src_image_path and tgt_image_path:
        print(f"\tWill move to {tgt_image_path} from {src_image_path}")
        shutil.copy2(src_image_path, tgt_image_path)

    tgt_content = f"{image_part}\n\n{tgt_content}" if image_part else f"{tgt_content}"
    write_content(tgt_content, tgt_file)
    print(f"Translated to: {tgt_file} from {src_file}")
    return tgt_file

def translate(src_file: str, _: str, **kwargs):
    src_lang = kwargs.get('src_lang', 'en')
    tgt_langs = kwargs['tgt_langs']
    sleep_interval = kwargs.get('sleep_interval', 2)
    #print(f"src_lang: {src_lang}, tgt_langs: {tgt_langs}, sleep_interval: {sleep_interval}")
    for tgt_lang in tgt_langs:
        result = _translate(src_file, src_lang, tgt_lang)
        if result:
            time.sleep(sleep_interval)

def print_md(src_file, _):
    if src_file.endswith(".md") is False:
        return
    print(src_file)

if __name__ == "__main__":

    print(f"cwd: {os.getcwd()}")

    # translated = translator.translate(read_content("./git-ignore/automate-jamstack/welcome.md"), "en", "de")
    # print("Translated:\n", translated)

    project_dir="/Users/chinomso/dev_looseboxes/automate/liveabove3d.com"

    visit_dirs(translate, project_dir, None, None,
               tgt_langs="ar,bn,de,es,fr,hi,it,ja,ko,ru,tr,uk,zh-cn".split(","))
