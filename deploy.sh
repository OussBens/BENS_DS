#!/bin/bash

echo "🚀 Déploiement CHM Automotive API sur cPanel"
echo "=============================================="

# Configuration
CPANEL_USER="bensds64"
CPANEL_HOST="bensds.com"
API_DIR="/home/$CPANEL_USER/public_html/api"

echo "📁 Création du dossier API..."
# ssh $CPANEL_USER@$CPANEL_HOST "mkdir -p $API_DIR"

echo "📤 Upload des fichiers PHP..."
# scp api/*.php $CPANEL_USER@$CPANEL_HOST:$API_DIR/

echo "🗄️ Import de la base de données..."
echo "Veuillez exécuter le script SQL via phpMyAdmin :"
echo "https://$CPANEL_HOST/phpmyadmin"

echo ""
echo "✅ Configuration terminée !"
echo ""
echo "🌐 Endpoints disponibles :"
echo "   - https://$CPANEL_HOST/api/cars.php"
echo "   - https://$CPANEL_HOST/api/orders.php"
echo "   - https://$CPANEL_HOST/api/auth.php"
echo ""
echo "📱 Mettez à jour votre fichier .env Flutter avec :"
echo "   API_BASE_URL=https://$CPANEL_HOST/api"