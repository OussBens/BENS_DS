# BENS Digital Solutions — site web

Site vitrine et back-office de **BENS Digital Solutions (BENS DS)**, agence digitale basée en Algérie
(développement web/mobile, backend, UI/UX, conseil, maintenance) et éditeur d'**AUTODZ**.

- `lib/` : application Flutter Web (site public + back-office `/admin`)
- `backend/` : API NestJS + Prisma

## Lancer le site

```bash
flutter pub get
flutter run -d chrome
```

## Build de production

```bash
flutter build web
```
