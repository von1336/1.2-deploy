from django.test import TestCase
from .models import Product, Stock, StockProduct


class ProductModelTest(TestCase):
    def test_create_product(self):
        p = Product.objects.create(title='Test Product', description='Desc')
        self.assertEqual(p.title, 'Test Product')
        self.assertEqual(Product.objects.count(), 1)


class StockModelTest(TestCase):
    def test_create_stock_with_positions(self):
        p1 = Product.objects.create(title='P1', description='')
        p2 = Product.objects.create(title='P2', description='')
        stock = Stock.objects.create(address='Address 1')
        StockProduct.objects.create(stock=stock, product=p1, quantity=10, price=100)
        StockProduct.objects.create(stock=stock, product=p2, quantity=5, price=200)
        self.assertEqual(stock.positions.count(), 2)
