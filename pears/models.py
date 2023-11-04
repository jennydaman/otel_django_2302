from django.db import models


class Pear(models.Model):
    creation_date = models.DateTimeField(auto_now_add=True)
    color = models.CharField(max_length=8)
