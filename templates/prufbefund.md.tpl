# Prüfbefund

**Anlagenbetreiber:** {{ anlagenbetreiber|default("_____") }}  
**Telefon-Nr.:** {{ telefon_nr|default("_____") }}  
**Anlagenadresse:** {{ anlagenadresse|default("_____") }}  
**Postadresse:** {{ postadresse|default("_____") }}  
**Projektnummer:** {{ projektnummer|default("_____") }}  

**Datum der Überprüfung:** {{ datum_ueberpruefung|default("_____") }}  
**Name des Prüfers:** {{ name_pruefer|default("_____") }}  
**Unterschrift:** _____  
**Datum der nächsten Überprüfung:** {{ naechste_ueberpruefung|default("_____") }}

## Anlagendokumentation

### PV-Generator
- **Hersteller:** {{ modul_hersteller|default("_____") }}
- **Type:** {{ modul_type|default("_____") }}
- **Anzahl Module:** {{ modul_anzahl|default("_____") }}
- **Gesamtleistung:** {{ gesamtleistung_kwp }} kWp
- **Anzahl Stränge:** {{ anzahl_straenge }}
- **Module/Strang:** {{ module_pro_strang|join(', ') }}
- **Systemnennspannung:** {{ systemnennspannung }} V

### Wechselrichter
- **Hersteller:** {{ wechselrichter_hersteller|default("_____") }}
- **Type:** {{ wechselrichter_type|default("_____") }}
- **Nennleistung:** {{ wechselrichter_nennleistung }} W

### Batteriespeicher
- **Hersteller:** {{ batterie_hersteller|default("_____") }}
- **Type:** {{ batterie_type|default("_____") }}
- **Kapazität:** {{ batterie_kapazitaet }} kWh

## Prüfergebnisse

| Umfang der Überprüfung | {% for teil in anlagenteile %}{{ teil }} | {% endfor %}
|------------------------|{% for teil in anlagenteile %}---|{% endfor %}
| Technische Unterlagen: | {% for teil in anlagenteile %}○ | {% endfor %}
| Prüfbefund: | {% for teil in anlagenteile %}○ | {% endfor %}
| Anlagenzustand: | {% for teil in anlagenteile %}○ | {% endfor %}

## Zusammenfassung der Prüfergebnisse:

Die Anlage ist
- [ ] in Ordnung.
- [ ] in Ordnung, hat aber geringfügige Mängel, die innerhalb von _____ Wochen zu beheben sind.
- [ ] nicht in Ordnung.
- [ ] Es besteht Gefahr für Leben bzw. Sachwerte.

Im Einvernehmen mit dem Anlagenbetreiber (dessen Vertreter)
- [ ] wurde die Anlage spannungslos geschaltet.
- [ ] Abschaltung nicht möglich bzw. nicht erreichbar.
- [ ] Die Meldung an die zuständige Behörde wurde erstattet.

**Datum der Überprüfung:** {{ datum_ueberpruefung|default("_____") }}  
**Name des Prüfers:** {{ name_pruefer|default("_____") }}  
**Unterschrift:** _____  
**Datum der nächsten Überprüfung:** {{ naechste_ueberpruefung|default("_____") }}  

## Fehlende Daten:

{% for field, options in missing_data.items() %}
- **{{ field }}:** [BITTE WÄHLEN]
  {% if options %} *Optionen: {{ options|join(', ') }}*{% endif %}
{% endfor %}

---

*Erstellt am: {{ erstellt_am }}*  
*Dieser Befund wurde automatisch generiert*