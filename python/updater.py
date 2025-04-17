import os

from translator import translate_file_name


def _single_file_name_of_dir(tgt_dir) -> str:
    if os.path.isdir(tgt_dir) is False:
        raise ValueError(f"Expected directory, got file: {tgt_dir}")
    if os.path.exists(tgt_dir) is False:
        raise ValueError(f"Directory does not exist: {tgt_dir}")
    tgt_file_names = os.listdir(tgt_dir)
    if len(tgt_file_names) != 1:
        raise ValueError(f"Expected 1 file in {tgt_dir}, found {len(tgt_file_names)}")
    return tgt_file_names[0]


def update_file_names(root_dir: str, src_lang: str, tgt_langs: [str], **kwargs):

    src_dir = os.path.join(root_dir, src_lang)
    src_file_name = _single_file_name_of_dir(src_dir)

    for tgt_lang in tgt_langs:

        tgt_dir = os.path.join(root_dir, tgt_lang)

        existing_file_name = _single_file_name_of_dir(tgt_dir)
        existing_file = os.path.join(tgt_dir, existing_file_name)

        if kwargs.get('noop', False) is True:
            tgt_file_name = f"{tgt_lang}.md"
            print(f"Noop mode -> will use made up name: {tgt_file_name}")
        else:
            tgt_file_name = translate_file_name(src_file_name, src_lang, tgt_lang)
        tgt_file = os.path.join(tgt_dir, tgt_file_name)

        print(f"Will rename fm: {existing_file}\nwill rename to: {tgt_file}")
        if kwargs.get('noop', False) is True:
            print("Noop mode -> will not rename")
            continue
        os.rename(existing_file, tgt_file)


if __name__ == "__main__":

    print(f"cwd: {os.getcwd()}")

    root_dir = "/Users/chinomso/dev_looseboxes/automate/liveabove3d.com/2025/03/25"

    update_file_names(
        root_dir,
        'en',
        ['ar','bn','de','es','fr','hi','it','ja','ko','ru','tr','uk','zh'],
        noop=True)

