import pandas as pd
import yaml
import jinja2
from pathlib import Path
from datetime import datetime, timedelta
import json
import tkinter as tk
from tkinter import ttk, messagebox

class PrufbefundGenerator:
    def __init__(self, config_path="config.yaml"):
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                self.config = yaml.safe_load(f)
            
            with open(self.config['templates']['fields'], 'r', encoding='utf-8') as f:
                self.field_options = yaml.safe_load(f)
            print("✅ Konfiguration geladen")
            
        except Exception as e:
            print(f"❌ Fehler beim Laden: {e}")
            self.field_options = {}
    
    def create_input_popup(self):
        """Erstellt ein Popup-Formular für alle Eingaben"""
        root = tk.Tk()
        root.title("Prüfbefund - Stammdaten eingeben")
        root.geometry("500x400")
        root.resizable(True, True)
        
        # Center the window
        root.eval('tk::PlaceWindow . center')
        
        # Main frame
        main_frame = ttk.Frame(root, padding="20")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Configure grid weights
        root.columnconfigure(0, weight=1)
        root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(1, weight=1)
        
        # Title
        title_label = ttk.Label(main_frame, text="Bitte geben Sie die Stammdaten ein:", 
                               font=('Arial', 12, 'bold'))
        title_label.grid(row=0, column=0, columnspan=2, pady=(0, 20), sticky=tk.W)
        
        # Input fields
        fields = [
            ('anlagenbetreiber', 'Anlagenbetreiber:', True),
            ('telefon_nr', 'Telefon-Nr.:', True),
            ('anlagenadresse', 'Anlagenadresse:', True),
            ('postadresse', 'Postadresse:', False),
            ('name_pruefer', 'Name des Prüfers:', True)
        ]
        
        entries = {}
        row_num = 1
        
        for field_key, field_label, required in fields:
            # Label
            label = ttk.Label(main_frame, text=field_label)
            label.grid(row=row_num, column=0, sticky=tk.W, pady=5)
            
            # Entry field
            if field_key == 'anlagenadresse' or field_key == 'postadresse':
                entry = tk.Text(main_frame, height=3, width=40)
                entry.grid(row=row_num, column=1, sticky=(tk.W, tk.E), pady=5, padx=(10, 0))
            else:
                entry = ttk.Entry(main_frame, width=40)
                # Default-Wert für Prüfer setzen
                if field_key == 'name_pruefer':
                    entry.insert(0, 'Vagapov Jamal')
                entry.grid(row=row_num, column=1, sticky=(tk.W, tk.E), pady=5, padx=(10, 0))
            
            if required:
                # Add red asterisk for required fields
                req_label = ttk.Label(main_frame, text="*", foreground="red")
                req_label.grid(row=row_num, column=2, sticky=tk.W, padx=(5, 0))
            
            entries[field_key] = entry
            row_num += 1
        
        # Required fields note
        note_label = ttk.Label(main_frame, text="* Pflichtfelder", foreground="red", 
                              font=('Arial', 9))
        note_label.grid(row=row_num, column=0, columnspan=2, pady=(10, 0), sticky=tk.W)
        
        row_num += 1
        
        # Buttons
        button_frame = ttk.Frame(main_frame)
        button_frame.grid(row=row_num, column=0, columnspan=2, pady=20)
        
        result = {'data': None}
        
        def on_ok():
            # Validate required fields
            user_data = {}
            missing_fields = []
            
            for field_key, field_label, required in fields:
                if field_key in ['anlagenadresse', 'postadresse']:
                    value = entries[field_key].get("1.0", tk.END).strip()
                else:
                    value = entries[field_key].get().strip()
                
                if required and not value:
                    missing_fields.append(field_label)
                else:
                    user_data[field_key] = value
            
            if missing_fields:
                error_msg = "Bitte folgende Pflichtfelder ausfüllen:\n" + "\n".join(f"• {field}" for field in missing_fields)
                tk.messagebox.showerror("Fehlende Daten", error_msg)
                return
            
            # Add automatic data with today's date in dd.mm.yyyy format
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
                'datum_ueberpruefung': heute,  # Format: dd.mm.yyyy
                'naechste_ueberpruefung': naechstes_jahr  # Format: dd.mm.yyyy
            })
            
            result['data'] = user_data
            root.destroy()
        
        def on_cancel():
            if tk.messagebox.askokcancel("Abbruch", "Möchten Sie wirklich abbrechen?"):
                root.destroy()
        
        ok_button = ttk.Button(button_frame, text="OK", command=on_ok)
        ok_button.pack(side=tk.LEFT, padx=(0, 10))
        
        cancel_button = ttk.Button(button_frame, text="Abbrechen", command=on_cancel)
        cancel_button.pack(side=tk.LEFT)
        
        # Bind Enter key to OK button
        root.bind('<Return>', lambda e: on_ok())
        
        # Focus first field
        entries['anlagenbetreiber'].focus()
        
        # Run the dialog
        root.mainloop()
        
        return result['data']
    
    def get_next_file_number(self):
        """Ermittelt die nächste fortlaufende Nummer"""
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
    
    def load_data(self):
        """Lädt Daten oder verwendet Benutzereingabe"""
        try:
            data_path = self.config['data']['source']
            data = pd.read_csv(data_path, encoding=self.config['data']['encoding'])
            print(f"✅ Daten geladen: {len(data)} Zeilen")
            
            # Immer heutiges Datum im Format dd.mm.yyyy und +1 Jahr setzen
            heute = datetime.now().strftime("%d.%m.%Y")
            naechstes_jahr = (datetime.now() + timedelta(days=365)).strftime("%d.%m.%Y")
            
            # Datum in allen Zeilen aktualisieren
            data['datum_ueberpruefung'] = heute
            data['naechste_ueberpruefung'] = naechstes_jahr
            
            # Name des Prüfers auf Default-Wert setzen, falls nicht vorhanden
            if 'name_pruefer' not in data.columns or data['name_pruefer'].isna().all():
                data['name_pruefer'] = 'Vagapov Jamal'
            
            print(f"📅 Datum gesetzt: {heute} → {naechstes_jahr}")
            print(f"👤 Prüfer gesetzt: Vagapov Jamal")
            
            return data
            
        except Exception as e:
            print(f"❌ Fehler beim Laden der Daten: {e}")
            print("🔄 Öffne Eingabe-Popup...")
            
            # Popup-Formular öffnen
            user_data = self.create_input_popup()
            if user_data is None:
                print("❌ Abbruch durch Benutzer")
                return pd.DataFrame()
            
            return pd.DataFrame([user_data])
    
    def safe_get(self, row, key, default=""):
        try:
            value = row.get(key, default)
            if pd.isna(value) or value is None or str(value).strip() == "":
                return default
            return str(value)
        except:
            return default
    
    def calculate_anlagendaten(self, row):
        try:
            modul_anzahl = int(self.safe_get(row, 'modul_anzahl', "50"))
        except:
            modul_anzahl = 50
        
        return {
            'gesamtleistung_kwp': round((455 * modul_anzahl) / 1000, 1),
            'gesamtleistung_w': 455 * modul_anzahl,
            'anzahl_straenge': 3,
            'module_pro_strang': [303, 303, 220],
            'systemnennspannung': 1000,
            'batterie_kapazitaet': 9.2,
            'wechselrichter_nennleistung': 10000
        }
    
    def identify_missing_data(self, row):
        missing = {}
        required_fields = self.config['required_fields']
        
        for field in required_fields:
            value = self.safe_get(row, field)
            if value == "":
                options = self.field_options.get(field, []) if self.field_options else []
                missing[field] = options
        
        return missing
    
    def generate_prufbefund(self, data):
        try:
            template_path = self.config['templates']['html']
            with open(template_path, 'r', encoding='utf-8') as f:
                template_content = f.read()
            
            template = jinja2.Template(template_content)
            reports = []
            
            for idx, row in data.iterrows():
                print(f"📝 Verarbeite Zeile {idx + 1}...")
                
                missing_data = self.identify_missing_data(row)
                anlagendaten = self.calculate_anlagendaten(row)
                
                # Daten für Template vorbereiten
                template_data = {}
                for key in row.index:
                    template_data[key] = self.safe_get(row, key)
                
                template_data.update(anlagendaten)
                template_data.update({
                    'missing_data': missing_data,
                    'anlagenteile': self.config['anlagenteile'],
                    'erstellt_am': datetime.now().strftime("%d.%m.%Y %H:%M"),
                    'heutiges_datum': datetime.now().strftime("%d.%m.%Y")  # Format: dd.mm.yyyy
                })
                
                report = template.render(**template_data)
                
                # Fortlaufende Nummer für Dateinamen
                file_number = self.get_next_file_number() + idx
                projektnummer = f"PB{datetime.now().strftime('%Y%m')}_{file_number:03d}"
                
                reports.append({
                    'content': report,
                    'projektnummer': projektnummer,
                    'file_number': file_number
                })
            
            return reports
            
        except Exception as e:
            print(f"❌ Fehler beim Generieren: {e}")
            raise
    
    def save_reports(self, reports):
        output_dir = Path(self.config['output']['directory'])
        output_dir.mkdir(exist_ok=True)
        
        for report in reports:
            filename = f"prufbefund_{report['file_number']:03d}.html"
            filepath = output_dir / filename
            
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(report['content'])
            
            print(f"✅ HTML Bericht erstellt: {filename}")
            
            # Letzte Datei automatisch öffnen
            if report == reports[-1]:  # Nur die letzte Datei öffnen
                import webbrowser
                webbrowser.open('file://' + str(filepath.resolve()))
        
        print(f"🎉 {len(reports)} Prüfbefund(e) erstellt in: {output_dir}")

if __name__ == "__main__":
    try:
        print("🚀 Starte Prüfbefund-Generator...")
        generator = PrufbefundGenerator()
        
        data = generator.load_data()
        
        if data.empty:
            print("❌ Keine Daten vorhanden - Beende Programm.")
            exit()
        
        print(f"📊 Geladene Datensätze: {len(data)}")
        
        reports = generator.generate_prufbefund(data)
        generator.save_reports(reports)
        
        print("🎊 Fertig! Der Prüfbefund wurde im Browser geöffnet.")
        
    except Exception as e:
        print(f"💥 Fehler: {e}")
        import traceback
        traceback.print_exc()