import os
import django

# Tell Django which settings module to use — must be done BEFORE any model imports
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from books.models import Book  # noqa: E402 — import must come after django.setup()

pdfs = [
    "books/pdfs/Retsept.pdf",
    "books/pdfs/TechPlan.pdf",
    "books/pdfs/topshiriq.pdf",
    "books/pdfs/X_TOP_TECHPLAN.pdf",
]

# 9 covers (range 1..9 inclusive)
covers = [
    f"books/covers/{i}.png" for i in range(1, 10)
]

for i in range(1, 10):
    Book.objects.create(
        title=f"Kitob #{i}",
        author=f"Muallif {i % 10 + 1}",
        description="Bu test uchun yaratilgan mock kitob.",
        published_year=2015 + (i % 10),
        pdf_file=pdfs[i % 4],
        cover_image=covers[i % 9],  # 9 covers → modulo 9
    )

print("✅ 100 ta mock kitob muvaffaqiyatli yaratildi!")