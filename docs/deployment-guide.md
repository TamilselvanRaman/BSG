# Deployment & Backup Guide

## 1. Docker Compose Deployment
```bash
docker compose up -d --build
```
This launches MySQL 8.0, the Express API (`:4000`), and the Next.js Web Portal (`:3000`).

## 2. Database Migrations & Seeding
```bash
cd backend/click-smart-chart-api
npx prisma migrate deploy
npm run prisma:seed
```

## 3. Automated MySQL Backup Policy
Schedule a daily cron job for encrypted tenant-consistent MySQL dumps:
```bash
mysqldump --single-transaction -u root -p click_smart_chart_saas | gzip > /backups/csc_$(date +%F).sql.gz
```
