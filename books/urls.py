from django.urls import path
from .views import (
    BookListView, 
    BookDetailView, 
    BookCreateView, 
    BookUpdateView, 
    BookDeleteView
)

urlpatterns = [
    # /books/ -> list all books
    path('', BookListView.as_view(), name='book_list'),
    
    # /books/book/1/ -> details for book with pk 1
    path('book/<int:pk>/', BookDetailView.as_view(), name='book_detail'),
    
    # /books/book/add/ -> add a new book
    path('book/add/', BookCreateView.as_view(), name='book_create'),
    
    # /books/book/1/edit/ -> edit book with pk 1
    path('book/<int:pk>/edit/', BookUpdateView.as_view(), name='book_update'),
    
    # /books/book/1/delete/ -> delete book with pk 1
    path('book/<int:pk>/delete/', BookDeleteView.as_view(), name='book_delete'),
]
