from django.db import models
from django.core.validators import FileExtensionValidator

class Book(models.Model):
    title = models.CharField(max_length=200)
    author = models.CharField(max_length=100)
    description = models.TextField()
    published_year = models.IntegerField()
    
    # New fields
    pdf_file = models.FileField(
        upload_to='books/pdfs/', 
        validators=[FileExtensionValidator(allowed_extensions=['pdf'])],
        help_text="Faqat PDF formatdagi fayllar ruxsat etiladi."
    )
    cover_image = models.ImageField(
        upload_to='books/covers/', 
        null=True, blank=True,
        help_text="Kitob muqovasi (ixtiyoriy)"
    )
    
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title