from django.db.models import Q
from rest_framework.viewsets import ModelViewSet
from rest_framework.filters import SearchFilter

from .models import Product, Stock
from .serializers import ProductSerializer, StockSerializer


class ProductViewSet(ModelViewSet):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    filter_backends = [SearchFilter]
    search_fields = ['title', 'description']


class StockViewSet(ModelViewSet):
    queryset = Stock.objects.all()
    serializer_class = StockSerializer

    def get_queryset(self):
        qs = super().get_queryset()
        products = self.request.query_params.get('products')
        if products:
            qs = qs.filter(positions__product_id=products).distinct()
        return qs
