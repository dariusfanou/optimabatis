# Generated by Django 5.1.1 on 2024-11-30 18:56

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Intervention',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('typedemande', models.CharField(max_length=30)),
                ('description', models.TextField()),
                ('date', models.DateField(blank=True)),
                ('heure', models.TimeField(blank=True)),
                ('imediatement', models.BooleanField(default=False)),
                ('image0', models.ImageField(upload_to='image_intervention')),
                ('image1', models.ImageField(blank=True, null=True, upload_to='image_intervention')),
                ('image2', models.ImageField(blank=True, null=True, upload_to='image_intervention')),
                ('preferencecontact', models.CharField(max_length=20)),
                ('actif', models.BooleanField(default=True)),
                ('createur', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='Publiciter',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('image', models.ImageField(upload_to='pub_image')),
                ('description', models.TextField()),
                ('createur', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='Service',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('label', models.CharField(max_length=20)),
                ('image', models.ImageField(upload_to='image_service')),
                ('createur', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='SousService',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('label', models.CharField(max_length=20)),
                ('image', models.ImageField(upload_to='image_service')),
                ('createur', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL)),
                ('service', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='service.service')),
            ],
        ),
    ]
