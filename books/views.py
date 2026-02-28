from django.urls import reverse_lazy
from django.views.generic import ListView, DetailView, CreateView, UpdateView, DeleteView
from .models import Book

# List all books (Shows a page with all books)
class BookListView(ListView):
    model = Book
    template_name = 'books/book_list.html'
    context_object_name = 'books'

# Show details of a single book
class BookDetailView(DetailView):
    model = Book
    template_name = 'books/book_detail.html'
    context_object_name = 'book'

# Add a new book (Displays a form and handles creation)
class BookCreateView(CreateView):
    model = Book
    fields = ['title', 'author', 'description', 'published_year', 'pdf_file', 'cover_image']
    template_name = 'books/book_form.html'
    success_url = reverse_lazy('book_list')

# Edit an existing book
class BookUpdateView(UpdateView):
    model = Book
    fields = ['title', 'author', 'description', 'published_year', 'pdf_file', 'cover_image']
    template_name = 'books/book_form.html'
    success_url = reverse_lazy('book_list')

# Delete a book (Asks for confirmation before deleting)
class BookDeleteView(DeleteView):
    model = Book
    template_name = 'books/book_confirm_delete.html'
    success_url = reverse_lazy('book_list')
