import json
import os
import asyncio
from googletrans import Translator

async def translate_arbs():
    translator = Translator()
    en_path = 'lib/l10n/app_en.arb'
    
    with open(en_path, 'r', encoding='utf-8') as f:
        en_data = json.load(f)
    
    # We will exclude 'en' and 'ar' because they are already translated correctly.
    langs = ['de', 'fa', 'hi', 'id', 'it', 'ja', 'ko', 'ps', 'pt', 'ru', 'tr', 'ur', 'zh-cn']
    
    for lang in langs:
        print(f"Translating to {lang}...")
        translated_data = {}
        for k, v in en_data.items():
            if k.startswith('@') or not isinstance(v, str):
                translated_data[k] = v
                continue
            
            try:
                # Protect format parameters
                temp_v = v.replace('{folder}', 'XYZ_FOLDER_XYZ').replace('{style}', 'XYZ_STYLE_XYZ')
                res = await translator.translate(temp_v, dest=lang)
                final_str = res.text.replace('XYZ_FOLDER_XYZ', '{folder}').replace('XYZ_STYLE_XYZ', '{style}')
                translated_data[k] = final_str
            except Exception as e:
                print(f"Failed to translate {k} for {lang}, fallback to EN")
                translated_data[k] = v
                
        # Handle zh-cn naming to zh
        file_lang = 'zh' if lang == 'zh-cn' else lang
        out_path = f'lib/l10n/app_{file_lang}.arb'
        with open(out_path, 'w', encoding='utf-8') as f:
            json.dump(translated_data, f, ensure_ascii=False, indent=2)
            
    print("All done!")

asyncio.run(translate_arbs())
