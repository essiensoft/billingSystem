# PHPNuxBill Production Deployment Checklist

## 🔐 Security Verification

- [x] **RCE Prevention**: eval() removed from all widgets
- [x] **SQL Injection**: Parameterized queries in 9 controllers
- [x] **Command Injection**: escapeshellarg() in Radius handler
- [x] **Session Security**: Secure configuration + regeneration
- [x] **Cryptographic Security**: random_int() + AES-256 encryption
- [x] **Access Control**: IDOR prevention implemented
- [x] **Router Passwords**: Encryption enabled

## 📝 Pre-Deployment Tasks

### 1. Environment Configuration
- [ ] Create production `.env` file
- [ ] Generate strong `ENCRYPTION_KEY` (32+ chars): `openssl rand -base64 32`
- [ ] Set production domain in `APP_URL`
- [ ] Configure strong database passwords
- [ ] Set correct timezone in `TZ`

### 2. Infrastructure Preparation
- [ ] Provision production server (2GB+ RAM, 10GB+ storage)
- [ ] Install Docker 20.10+ and Docker Compose 2.0+
- [ ] Configure firewall (allow 80, 443, SSH only)
- [ ] Obtain SSL/TLS certificates (Let's Encrypt recommended)
- [ ] Set up backup storage location

### 3. Database Preparation
- [ ] Backup existing database (if upgrading)
- [ ] Prepare migration scripts
- [ ] Test migrations on staging environment

## 🚀 Deployment Steps

### 1. Build & Push Docker Image
```bash
docker build -t yourusername/phpnuxbill:latest .
docker tag yourusername/phpnuxbill:latest yourusername/phpnuxbill:v1.0.0
docker login
docker push yourusername/phpnuxbill:latest
docker push yourusername/phpnuxbill:v1.0.0
```

- [ ] Docker image built successfully
- [ ] Image pushed to registry
- [ ] Version tagged appropriately

### 2. Deploy Services
```bash
docker-compose -f docker-compose.production.yml up -d
```

- [ ] All containers started
- [ ] Health checks passing
- [ ] No errors in logs

### 3. Initialize Database
```bash
# First time installation
docker exec -i phpnuxbill-mysql mysql -u phpnuxbill_user -p<PASSWORD> phpnuxbill_prod < install/phpnuxbill.sql

# Copy required files
docker cp system/uploads/. phpnuxbill-app:/var/www/html/system/uploads/
docker exec phpnuxbill-app chown -R www-data:www-data /var/www/html/system/uploads/
```

- [ ] Database schema imported
- [ ] Upload files copied
- [ ] Permissions set correctly

### 4. Run Migrations (if upgrading)
```bash
docker exec phpnuxbill-app php migrate_router_passwords.php
docker exec phpnuxbill-app php migrate_widgets.php
```

- [ ] Router passwords encrypted
- [ ] Widgets migrated
- [ ] Migration logs reviewed

### 5. Configure SSL/TLS
- [ ] SSL certificates installed
- [ ] HTTPS enabled
- [ ] HTTP to HTTPS redirect configured
- [ ] HSTS headers enabled

### 6. Complete Installation
- [ ] Navigate to production URL
- [ ] Complete installation wizard
- [ ] Create admin account with strong password
- [ ] Configure application settings

## 🔒 Security Hardening

### Application Security
- [ ] Change default admin credentials
- [ ] Review user permissions
- [ ] Disable phpMyAdmin in production (optional)
- [ ] Configure rate limiting
- [ ] Set up security headers

### Infrastructure Security
- [ ] Configure firewall rules
- [ ] Set up fail2ban for SSH
- [ ] Enable automatic security updates
- [ ] Configure log rotation
- [ ] Implement monitoring

### Database Security
- [ ] Strong database passwords set
- [ ] Database access restricted to localhost
- [ ] Enable MySQL audit logging
- [ ] Configure automated backups

## 📊 Monitoring & Backups

### Monitoring Setup
- [ ] Container health monitoring configured
- [ ] Application logs centralized
- [ ] Error alerting set up
- [ ] Performance metrics tracked

### Backup Configuration
```bash
# Create backup script
cat > /opt/phpnuxbill/backup.sh <<'EOF'
#!/bin/bash
BACKUP_DIR="/opt/backups/phpnuxbill"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR
docker exec phpnuxbill-mysql mysqldump -u root -p$MYSQL_ROOT_PASSWORD phpnuxbill_prod > $BACKUP_DIR/db_$DATE.sql
docker cp phpnuxbill-app:/var/www/html/system/uploads $BACKUP_DIR/uploads_$DATE
find $BACKUP_DIR -type f -mtime +7 -delete
EOF

chmod +x /opt/phpnuxbill/backup.sh
echo "0 2 * * * /opt/phpnuxbill/backup.sh" | crontab -
```

- [ ] Backup script created
- [ ] Automated backups scheduled
- [ ] Backup restoration tested
- [ ] Off-site backup configured

## 🧪 Testing & Validation

### Functional Testing
- [ ] Login/logout works
- [ ] User registration works
- [ ] Payment processing works
- [ ] Router integration works
- [ ] Voucher generation works

### Security Testing
```bash
cd tests
./security_test_suite.sh
```

- [ ] SQL injection tests pass
- [ ] Session security verified
- [ ] Access control tested
- [ ] Encryption verified
- [ ] No eval() in widgets

### Performance Testing
- [ ] Load testing completed
- [ ] Response times acceptable
- [ ] Resource usage monitored
- [ ] Database queries optimized

## 📋 Post-Deployment

### Documentation
- [ ] Production credentials documented (securely)
- [ ] Deployment process documented
- [ ] Custom configurations noted
- [ ] Troubleshooting guide created

### Training & Handover
- [ ] Admin users trained
- [ ] Support team briefed
- [ ] Escalation procedures defined
- [ ] Maintenance schedule established

### Monitoring (First 48 Hours)
- [ ] Monitor error logs continuously
- [ ] Check resource usage
- [ ] Verify backup completion
- [ ] Test critical user flows
- [ ] Address any issues immediately

## ✅ Final Verification

- [ ] Application accessible via HTTPS
- [ ] All features working correctly
- [ ] No errors in logs
- [ ] Backups completing successfully
- [ ] Monitoring alerts configured
- [ ] Security headers present
- [ ] Performance acceptable
- [ ] Documentation complete

## 🎉 Production Ready!

**Deployment Date**: _______________  
**Deployed By**: _______________  
**Version**: v1.0.0  
**Security Status**: ✅ MEDIUM RISK - Production Ready

---

## 📞 Emergency Contacts

**Technical Lead**: _______________  
**Database Admin**: _______________  
**Security Team**: _______________  
**On-Call Support**: _______________

## 🔄 Next Steps

1. Monitor for 48 hours
2. Schedule first security audit (30 days)
3. Plan next feature release
4. Review and update documentation
5. Conduct user feedback session
