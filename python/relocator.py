def relocate_files():
    NOOP = False
    project_dir="/Users/chinomso/dev_looseboxes/automate/liveabove3d.com/2025/03"
    src_day_of_month = "20"

    en_dir = os.path.join(project_dir, src_day_of_month, "en")
    en_file_names = os.listdir(en_dir)
    tgt_langs = "ar,bn,de,es,fr,hi,it,ja,ko,ru,tr,uk,zh".split(",")
    day_of_months = {
#         "Why-your-faith-did-not-work.md": 20,
        "What-is-it-with-fire.md": 21,
        "What-is-it-with-Jesus.md": 22,
        "What-exactly-is-going-on.md": 23,
        "Too-much-freedom.md": 24,
        "Mast*rbator-in-heaven.md": 25,
        "The-only-personality-that-matters.md": 26,
        "So,-who-do-you-think-is-self-righteous.md": 27,
        "Death-is-not-death,-life-is-not-life.md": 28
    }
    unable_to_resolve = {}
    try:
        for en_file_name in day_of_months:
            new_day_of_month = day_of_months.get(en_file_name)
            if not new_day_of_month:
                print(f"\tSkipping: {en_file_name}")
                continue
            new_day_of_month = str(new_day_of_month)
            src_file = os.path.join(en_dir, en_file_name)
            if not os.path.exists(src_file):
                src_file = os.path.join(project_dir, new_day_of_month, "en", en_file_name)
            if not os.path.isfile(src_file):
                print(f"\tNot a file: {src_file}")
                continue
            if src_file.endswith(".md") is  False:
                print(f"\tNot a markdown file: {src_file}")
                continue
            print(f"\nSrc file: {src_file}")
            file_name, ext = os.path.splitext(en_file_name)
            en_tgt_file = os.path.join(project_dir, new_day_of_month, "en", en_file_name)
            if src_file != en_tgt_file:
                move(src_file, en_tgt_file, noop=NOOP)
            else:
                print(f"\tAlready exists, en file: {src_file}")
            for tgt_lang in tgt_langs:
                new_tgt_dir = os.path.join(project_dir, new_day_of_month, tgt_lang)
                if len(os.listdir(os.path.dirname(src_file))) == len(os.listdir(new_tgt_dir)):
                    print(f"\tTranslation to {tgt_lang} already exists in {new_tgt_dir}")
                    continue
                new_file_name = translate_file_name(file_name, "en", tgt_lang)
                tgt_file = os.path.join(project_dir, src_day_of_month, tgt_lang, f"{new_file_name}{ext}")
                if not os.path.exists(tgt_file):
                    print(f"\tUnable to resolve: {tgt_file}")
                    elements = unable_to_resolve.get(en_file_name, [])
                    elements.append(tgt_lang)
                    unable_to_resolve[en_file_name] = elements
                    continue
                new_tgt_file = os.path.join(new_tgt_dir, f"{new_file_name}{ext}")
                move(tgt_file, new_tgt_file, noop=NOOP)
    finally:
        print("Unable to resolve")
        print(unable_to_resolve)
