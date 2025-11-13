import os
import logging
from pathlib import Path
from datetime import datetime, timedelta
import yaml
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
        """Lädt Konfiguration aus Dateien"""
        try:
            with open('config.yaml', 'r', encoding='utf-8') as f:
                self.config = yaml.safe_load(f)
            
            with open(self.config['templates']['fields'], 'r', encoding='utf-8') as f:
                self.field_options = yaml.safe_load(f)
                
            logger.info("✅ Konfiguration geladen")
            
        except Exception as e:
            logger.error(f"❌ Fehler beim Laden der Konfiguration: {e}")
            raise
    
    def get_next_file_number(self):
        """Ermittelt nächste Dateinummer"""
        try:
            output_dir = Path(self.config['output']['directory'])
            output_dir.mkdir(exist_ok=True)
            
            existing_files = list(output_dir.glob("prufbefund_*.html"))
            numbers = []
            
            for file in existing_files:
                try:
                    number_str = file.stem.split('_')[1]
                    numbers.append(int(number_str))
                except (IndexError, ValueError):
                    continue
            
            return max(numbers) + 1 if numbers else 1
        except Exception as e:
            logger.error(f"⚠️ Fehler bei Nummerngenerierung: {e}")
            return 1
    
    def generate_html(self, user_data):
        """Generiert HTML-Prüfbefund"""
        try:
            template_path = Path(self.config['templates']['html'])
            
            with open(template_path, 'r', encoding='utf-8') as f:
                template_content = f.read()
            
            template = jinja2.Template(template_content)
            
            # Automatische Daten
            heute = datetime.now().strftime("%d.%m.%Y")
            naechstes_jahr = (datetime.now() + timedelta(days=365)).strftime("%d.%m.%Y")
            
            user_data.update({
                'projektnummer': f"PB{datetime.now().strftime('%Y%m')}_{self.get_next_file_number():03d}",
                'modul_hersteller': 'Trina Solar',
                'modul_type': 'TSM-NEG9R.28',
                'modul_anzahl': 50,
                'wechselrichter_hersteller': 'Solaxpower',
                'wechselrichter_type': 'X3-Hybrid G4 10.0kW',
                'batterie_hersteller': 'Solaxpower', 
                'batterie_type': 'T-BAT H 9.0 V2',
                'datum_ueberpruefung': heute,
                'naechste_ueberpruefung': naechstes_jahr,
                'anlagenteile': self.config['anlagenteile'],
                'erstellt_am': datetime.now().strftime("%d.%m.%Y %H:%M"),
                'heutiges_datum': heute,
                'gesamtleistung_kwp': 22.8,
                'gesamtleistung_w': 22750,
                'anzahl_straenge': 3,
                'systemnennspannung': 1000,
                'batterie_kapazitaet': 9.2,
                'wechselrichter_nennleistung': 10000
            })
            
            html_content = template.render(**user_data)
            
            # Speichern
            output_dir = Path(self.config['output']['directory'])
            output_dir.mkdir(exist_ok=True)
            
            filename = f"prufbefund_{self.get_next_file_number():03d}.html"
            filepath = output_dir / filename
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(html_content)
            
            logger.info(f"✅ HTML erstellt: {filename}")
            return filepath
            
        except Exception as e:
            logger.error(f"❌ Fehler beim Generieren: {e}")
            return None

    async def start(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Startet den Bot"""
        welcome_text = """
🤖 **Willkommen beim Prüfbefund-Generator Bot!**

Ich helfe dir bei der Erstellung von Prüfbefunden für Photovoltaik-Anlagen.

Bitte gib folgende Daten ein:
        """
        
        await update.message.reply_text(welcome_text)
        await update.message.reply_text("👤 **Anlagenbetreiber:**\nBitte gib den Namen ein:")
        
        return ANLAGENBETREIBER
    
    async def get_anlagenbetreiber(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Speichert Anlagenbetreiber"""
        self.user_data['anlagenbetreiber'] = update.message.text
        
        options = self.field_options.get('telefon_nr', [])
        if options:
            keyboard = [[KeyboardButton(option)] for option in options]
            reply_markup = ReplyKeyboardMarkup(keyboard, one_time_keyboard=True)
            await update.message.reply_text(
                "📞 **Telefon-Nr.:**\nWähle eine Option oder gib eigene Nummer ein:",
                reply_markup=reply_markup
            )
        else:
            await update.message.reply_text("📞 **Telefon-Nr.:**\nBitte gib die Telefonnummer ein:")
        
        return TELEFON
    
    async def get_telefon(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Speichert Telefonnummer"""
        self.user_data['telefon_nr'] = update.message.text
        
        await update.message.reply_text(
            "🏠 **Anlagenadresse:**\nBitte gib die vollständige Adresse ein:",
            reply_markup=ReplyKeyboardRemove()
        )
        
        return ANLAGENADRESSE
    
    async def get_anlagenadresse(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Speichert Anlagenadresse"""
        self.user_data['anlagenadresse'] = update.message.text
        
        await update.message.reply_text(
            "📬 **Postadresse:**\nBitte gib die Postadresse ein:\n(Leer lassen falls gleich)"
        )
        
        return POSTADRESSE
    
    async def get_postadresse(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Speichert Postadresse"""
        postadresse = update.message.text
        self.user_data['postadresse'] = postadresse if postadresse.strip() else self.user_data['anlagenadresse']
        
        options = self.field_options.get('name_pruefer', ['Vagapov Jamal'])
        keyboard = [[KeyboardButton(option)] for option in options]
        reply_markup = ReplyKeyboardMarkup(keyboard, one_time_keyboard=True)
        
        await update.message.reply_text(
            "👨‍💼 **Name des Prüfers:**\nWähle einen Prüfer oder gib eigenen Namen ein:",
            reply_markup=reply_markup
        )
        
        return NAMEPRUEFER
    
    async def get_name_pruefer(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Speichert Prüfer-Namen"""
        self.user_data['name_pruefer'] = update.message.text
        
        # Zusammenfassung
        summary = f"""
✅ **Zusammenfassung:**

👤 **Anlagenbetreiber:** {self.user_data['anlagenbetreiber']}
📞 **Telefon:** {self.user_data['telefon_nr']}
🏠 **Anlagenadresse:** {self.user_data['anlagenadresse']}
📬 **Postadresse:** {self.user_data['postadresse']}
👨‍💼 **Prüfer:** {self.user_data['name_pruefer']}

Sind alle Daten korrekt?
        """
        
        keyboard = [["✅ Ja, Prüfbefund erstellen", "❌ Nein, Daten korrigieren"]]
        reply_markup = ReplyKeyboardMarkup(keyboard, one_time_keyboard=True)
        
        await update.message.reply_text(summary, reply_markup=reply_markup)
        return CONFIRM
    
    async def confirm_data(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Bestätigt Daten und erstellt Prüfbefund"""
        user_choice = update.message.text
        
        if user_choice == "✅ Ja, Prüfbefund erstellen":
            await update.message.reply_text("🔄 Erstelle Prüfbefund...", reply_markup=ReplyKeyboardRemove())
            
            filepath = self.generate_html(self.user_data)
            
            if filepath:
                with open(filepath, 'rb') as file:
                    await update.message.reply_document(
                        document=file,
                        filename=f"prufbefund_{datetime.now().strftime('%Y%m%d_%H%M')}.html",
                        caption="✅ **Prüfbefund erfolgreich erstellt!**"
                    )
                
                await update.message.reply_text("🎉 Prüfbefund erstellt! Starte neu mit /start")
            else:
                await update.message.reply_text("❌ Fehler beim Erstellen. Bitte versuche es erneut.")
            
            return ConversationHandler.END
        else:
            await update.message.reply_text("🔄 Starte erneut...", reply_markup=ReplyKeyboardRemove())
            await update.message.reply_text("👤 **Anlagenbetreiber:**\nBitte gib den Namen ein:")
            return ANLAGENBETREIBER
    
    async def cancel(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """Bricht ab"""
        await update.message.reply_text("❌ Vorgang abgebrochen. Starte neu mit /start")
        return ConversationHandler.END

def main():
    """Startet den Bot"""
    try:
        bot = PrufbefundBot()
        application = Application.builder().token(bot.token).build()
        
        # Conversation Handler
        conv_handler = ConversationHandler(
            entry_points=[CommandHandler('start', bot.start)],
            states={
                ANLAGENBETREIBER: [MessageHandler(filters.TEXT & ~filters.COMMAND, bot.get_anlagenbetreiber)],
                TELEFON: [MessageHandler(filters.TEXT & ~filters.COMMAND, bot.get_telefon)],
                ANLAGENADRESSE: [MessageHandler(filters.TEXT & ~filters.COMMAND, bot.get_anlagenadresse)],
                POSTADRESSE: [MessageHandler(filters.TEXT & ~filters.COMMAND, bot.get_postadresse)],
                NAMEPRUEFER: [MessageHandler(filters.TEXT & ~filters.COMMAND, bot.get_name_pruefer)],
                CONFIRM: [MessageHandler(filters.TEXT & ~filters.COMMAND, bot.confirm_data)],
            },
            fallbacks=[CommandHandler('cancel', bot.cancel)]
        )
        
        application.add_handler(conv_handler)
        
        # Start Polling
        logger.info("🤖 Bot gestartet und läuft auf Render...")
        application.run_polling()
        
    except Exception as e:
        logger.error(f"💥 Bot Fehler: {e}")

if __name__ == '__main__':
    main()