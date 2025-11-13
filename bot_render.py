import os
import logging
from pathlib import Path
from datetime import datetime, timedelta
import json  # Verwende JSON statt YAML
import jinja2
from telegram import Update, ReplyKeyboardMarkup, KeyboardButton, ReplyKeyboardRemove
from telegram.ext import (
    Application, CommandHandler, MessageHandler, filters, 
    ContextTypes, ConversationHandler
)

# Konversations-States
(
    ANLAGENBETREIBER, TELEFON, ANLAGENADRESSE, 
    POSTADRESSE, NAMEPRUEFER, CONFIRM
) = range(6)

# Logging für Render
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)
logger = logging.getLogger(__name__)

class PrufbefundBot:
    def __init__(self):
        self.token = os.environ.get('TELEGRAM_TOKEN')
        if not self.token:
            raise ValueError("❌ TELEGRAM_TOKEN Umgebungsvariable nicht gesetzt")
        
        self.load_config()
        self.user_data = {}
        logger.info("✅ Bot initialisiert")
    
    def load_config(self):
        """Lädt Konfiguration - ersetzt YAML mit direkter Konfiguration"""
        try:
            # Ersetze YAML mit direkter Konfiguration
            self.config = {
                'templates': {
                    'html': 'templates/prufbefund.html.tpl',
                    'fields': 'fields.json'
                },
                'output': {
                    'directory': 'outputs/'
                },
                'required_fields': [
                    'anlagenbetreiber',
                    'telefon_nr', 
                    'anlagenadresse',
                    'postadresse',
                    'datum_ueberpruefung',
                    'name_pruefer',
                    'naechste_ueberpruefung'
                ],
                'anlagenteile': [
                    'Elektrotech. <br>Anlage-<br>Versorgung',
                    'Verteiler',
                    'Betriebsmittel',
                    'Blitzschutz'
                ]
            }
            
            # Lade field_options aus JSON oder erstelle Standard
            try:
                with open('fields.json', 'r', encoding='utf-8') as f:
                    self.field_options = json.load(f)
            except FileNotFoundError:
                # Fallback field_options
                self.field_options = {
                    'anlagenbetreiber': ['Franz Konrad', 'Max Mustermann', 'Erika Musterfrau'],
                    'telefon_nr': ['+43 676 85463924', '+43 664 1234567'],
                    'name_pruefer': ['Jamal Vagapov']
                }
                
            logger.info("✅ Konfiguration geladen")
            
        except Exception as e:
            logger.error(f"❌ Fehler beim Laden der Konfiguration: {e}")
            raise