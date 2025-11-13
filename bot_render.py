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