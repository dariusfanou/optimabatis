# Generated by Django 5.1.1 on 2024-11-30 18:56

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('utilisateur', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='utilisateur',
            name='datenaissance',
            field=models.DateField(null=True),
        ),
        migrations.AlterField(
            model_name='utilisateur',
            name='photo',
            field=models.ImageField(blank=True, null=True, upload_to='photo_profile'),
        ),
    ]
