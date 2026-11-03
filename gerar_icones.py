from PIL import Image
import os

res = "android/app/src/main/res"
img = Image.open("assets/icons/localizacoes.png").convert("RGBA")

for pasta, tam in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
    os.makedirs(f"{res}/mipmap-{pasta}", exist_ok=True)
    img.resize((tam, tam), Image.LANCZOS).save(f"{res}/mipmap-{pasta}/ic_localizacoes.png")

os.makedirs(f"{res}/drawable-nodpi", exist_ok=True)
img.resize((432, 432), Image.LANCZOS).save(f"{res}/drawable-nodpi/icone_localizacoes.png")

print("Ícones gerados com sucesso!")