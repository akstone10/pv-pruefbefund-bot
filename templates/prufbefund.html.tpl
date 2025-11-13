<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Prüfbefund {{ projektnummer }}</title>
    <style>
        /* CSS-Variablen für bessere Wartbarkeit */
        :root {
            --primary-color: #2c3e50;
            --success-color: #4CAF50;
            --warning-color: #ff9800;
            --danger-color: #f44336;
            --light-gray: #f5f5f5;
            --medium-gray: #ddd;
            --dark-gray: #666;
            --border-radius: 4px;
            --padding-small: 5px 8px;
            --padding-medium: 10px 15px;
            --padding-large: 15px 20px;
            --font-family: Arial, sans-serif;
        }
        
        /* Basis-Styles */
        body { 
            font-family: var(--font-family); 
            margin: 20px; 
            line-height: 1.5;
        }
        
        .header { 
            background: var(--light-gray); 
            padding: var(--padding-large); 
            margin-bottom: 20px; 
            border-radius: var(--border-radius);
        }
        
        table { 
            border-collapse: collapse; 
            width: 100%; 
            margin: 10px 0; 
        }
        
        th, td { 
            border: 1px solid var(--medium-gray); 
            padding: var(--padding-small); 
            text-align: left; 
        }
        
        th { 
            background: var(--light-gray); 
        }
        
        .missing { 
            color: var(--danger-color); 
            font-weight: bold; 
        }
        
        .section { 
            margin: 20px 0; 
        }
        
        select, input[type="text"] { 
            padding: 5px; 
            margin: 0 5px; 
            width: 200px; 
            border: 1px solid var(--medium-gray);
            border-radius: var(--border-radius);
        }
        
        .auto-field { 
            background: #f0f8ff; 
        }
        
        /* Stammdaten Table Styles */
        #stammdaten-table td {
            padding: 10px;
            vertical-align: top;
        }
        
        #stammdaten-table td:first-child {
            width: 150px;
            font-weight: bold;
        }
        
        #stammdaten-table td:last-child {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: var(--border-radius);
            min-height: 20px;
        }
        
        /* Check Table Styles */
        .check-table input[type="checkbox"] {
            transform: scale(1.3);
            margin: 5px;
        }
        
        .status-ok select {
            border: 2px solid var(--success-color);
            background: #f9fff9;
        }

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }

        .modal-content {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
            width: 500px;
            max-width: 90%;
        }

        .modal input, .modal textarea {
            width: 100%;
            padding: 8px;
            border: 2px solid var(--medium-gray);
            border-radius: var(--border-radius);
            margin-bottom: 15px;
            box-sizing: border-box;
        }

        .modal textarea {
            height: 60px;
            resize: vertical;
        }

        .modal-buttons {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 20px;
        }

        .modal-button {
            padding: 10px 20px;
            border: none;
            border-radius: var(--border-radius);
            cursor: pointer;
            font-weight: bold;
        }

        .modal-ok {
            background: var(--success-color);
            color: white;
        }

        .modal-cancel {
            background: var(--dark-gray);
            color: white;
        }
        
        /* Print Styles */
        @media print {
            button, .no-print {
                display: none !important;
            }
            
            body {
                margin: 0;
                font-size: 12pt;
            }
            
            .header {
                background: white;
                border: 1px solid black;
            }
        }
        
        /* Responsive Verbesserungen */
        @media (max-width: 768px) {
            body {
                margin: 10px;
            }
            
            select, input[type="text"] {
                width: 100%;
                margin: 5px 0;
            }
            
            .modal-content {
                width: 95%;
                padding: 15px;
            }
            
            .modal-buttons {
                flex-direction: column;
            }
        }
        
        /* Accessibility Verbesserungen */
        .sr-only {
            position: absolute;
            width: 1px;
            height: 1px;
            padding: 0;
            margin: -1px;
            overflow: hidden;
            clip: rect(0, 0, 0, 0);
            white-space: nowrap;
            border: 0;
        }
        
        input:focus, select:focus, textarea:focus, button:focus {
            outline: 2px solid var(--primary-color);
            outline-offset: 2px;
        }
        
        /* Verbesserte Button Styles */
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: var(--border-radius);
            cursor: pointer;
            font-size: 16px;
            transition: background-color 0.3s;
        }
        
        .btn-primary {
            background: var(--primary-color);
            color: white;
        }
        
        .btn-primary:hover {
            background: #1a252f;
        }
        
        .edit-link {
            margin-left: 15px;
            font-size: 12px;
            color: var(--dark-gray);
            text-decoration: none;
            cursor: pointer;
            background: none;
            border: none;
            padding: 0;
        }
        
        .edit-link:hover {
            color: var(--primary-color);
            text-decoration: underline;
        }
        
        .date-input {
            width: 120px !important;
        }
        
        .error-message {
            color: var(--danger-color);
            font-size: 12px;
            margin-left: 10px;
        }
        
        /* Normale Schrift für Tabellenzellen */
        .normal-text {
            font-weight: normal;
        }
    </style>
</head>
<body>
    <!-- Modal für Stammdaten -->
    <div id="stammdatenModal" class="modal" aria-hidden="true" role="dialog" aria-labelledby="modalTitle">
        <div class="modal-content">
            <h2 id="modalTitle" style="margin-top: 0; color: var(--primary-color);">Stammdaten eingeben</h2>
            <p style="color: var(--dark-gray); margin-bottom: 20px;">Bitte geben Sie die erforderlichen Stammdaten ein:</p>
            
            <div>
                <label for="input-anlagenbetreiber" style="display: block; margin-bottom: 5px; font-weight: bold;">
                    Anlagenbetreiber: *
                </label>
                <input type="text" id="input-anlagenbetreiber" placeholder="Name des Anlagenbetreibers" required>
            </div>
            
            <div>
                <label for="input-telefon_nr" style="display: block; margin-bottom: 5px; font-weight: bold;">
                    Telefon-Nr.: *
                </label>
                <input type="tel" id="input-telefon_nr" placeholder="+43 123 456789" required>
            </div>
            
            <div>
                <label for="input-anlagenadresse" style="display: block; margin-bottom: 5px; font-weight: bold;">
                    Anlagenadresse: *
                </label>
                <textarea id="input-anlagenadresse" placeholder="Straße Hausnummer, PLZ Ort" required></textarea>
            </div>
            
            <div>
                <label for="input-postadresse" style="display: block; margin-bottom: 5px; font-weight: bold;">
                    Postadresse:
                </label>
                <textarea id="input-postadresse" placeholder="Falls abweichend von Anlagenadresse"></textarea>
            </div>
            
            <div class="modal-buttons">
                <button id="cancel-btn" class="modal-button modal-cancel">Abbrechen</button>
                <button id="ok-btn" class="modal-button modal-ok">OK</button>
            </div>
            
            <p style="font-size: 12px; color: #7f8c8d; margin-top: 15px;">
                * Pflichtfelder
            </p>
        </div>
    </div>

    <div class="header">
        <h1>Prüfbefund</h1>
        <p><strong>Projektnummer:</strong> <span id="projektnummer">{{ projektnummer|default("_____") }}</span></p>
    </div>

    <div class="section">
        <h3>
            Stammdaten 
            <button type="button" class="edit-link" onclick="resetStammdaten()" aria-label="Stammdaten bearbeiten">
                ✎ Bearbeiten
            </button>
        </h3>
        <table id="stammdaten-table">
            <tr>
                <td><strong>Anlagenbetreiber:</strong></td>
                <td id="anlagenbetreiber-cell">_____</td>
            </tr>
            <tr>
                <td><strong>Telefon-Nr.:</strong></td>
                <td id="telefon_nr-cell">_____</td>
            </tr>
            <tr>
                <td><strong>Anlagenadresse:</strong></td>
                <td id="anlagenadresse-cell">_____</td>
            </tr>
            <tr>
                <td><strong>Postadresse:</strong></td>
                <td id="postadresse-cell">_____</td>
            </tr>
        </table>
    </div>

    <div class="section">
        <h3>Umfang der Überprüfung</h3>
        <table class="check-table">
            <thead>
                <tr>
                    <th>Umfang der Überprüfung</th>
                    {% for teil in anlagenteile %}
                    <th>{{ teil }}</th>
                    {% endfor %}
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><strong>Technische Unterlagen:</strong></td>
                    {% for teil in anlagenteile %}
                    <td class="status-ok">
                        <input type="checkbox" checked title="Technische Unterlagen vorhanden">
                    </td>
                    {% endfor %}
                </tr>
                <tr>
                    <td><strong>Prüfbefund:</strong></td>
                    {% for teil in anlagenteile %}
                    <td class="status-ok">
                        <input type="checkbox" checked title="Prüfbefund vorhanden">
                    </td>
                    {% endfor %}
                </tr>
                <tr>
                    <td><strong>Anlagenzustand:</strong></td>
                    {% for teil in anlagenteile %}
                    <td class="status-ok">
                        <select aria-label="Anlagenzustand für {{ teil }}">
                            <option value="">-</option>
                            <option value="OK" selected>✓ In Ordnung</option>
                            <option value="G">⚠ Geringe Mängel</option>
                            <option value="N">❌ Nicht in Ordnung</option>
                        </select>
                    </td>
                    {% endfor %}
                </tr>
            </tbody>
        </table><table style="width:100%;margin-bottom:20px;">
                        <tr>
                            <td style="width:150px;padding:8px;">Anlagenteil:</td>
                            <td style="padding:8px;">
                                <select style="width:200px;padding:5px;" aria-label="Anlagenteil auswählen">
                                    <option>-- Bitte wählen --</option>
                                    <option>PV-Anlage</option>
                                    <option>Wechselrichter</option>
                                    <option>Batteriespeicher</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding:8px;">Geprüft nach:</td>
                            <td style="padding:8px;">
                                <select style="width:200px;padding:5px;" aria-label="Prüfstandard auswählen">
                                    <option>-- Bitte wählen --</option>
                                    <option>ÖVE E 8101-6</option>
                                    <option>Nicht geprüft</option>
                                </select>
                            </td>
                        </tr>
                    </table>
    </div>
    
    <br><br>
    
    <table style="border-collapse:collapse;width:100%;border:1px solid var(--medium-gray);">
        <tbody>
            <tr>
                <td style="padding:20px;">
                    <!-- Anlagenteil und Geprüft nach -->
                                        
                    <!-- Zusammenfassung Radio-Buttons -->
                    <div style="padding:15px; border:1px solid var(--medium-gray); background:var(--light-gray); border-radius:var(--border-radius);">
                        <p style="margin:0; line-height:1.8;">
                            <b>Dieser Befund dient als:</b><br>
                            <input type="checkbox" id="erstpruefung" checked title="Erstprüfung"> 
                            <label for="erstpruefung">Erstprüfung</label>
                            &emsp;&emsp;
                            <input type="checkbox" id="ausserordentlich" title="Außerordentliche Prüfung"> 
                            <label for="ausserordentlich">Außerordentliche Prüfung</label>
                            &emsp;&emsp;
                            <input type="checkbox" id="wiederkehrend" title="Wiederkehrende Prüfung"> 
                            <label for="wiederkehrend">Wiederkehrende Prüfung</label>
                            <br><br>
                            <strong>Zusammenfassung der Prüfergebnisse:</strong><br>
                            <input type="radio" id="zusammenfassung_ok" name="zusammenfassung" value="ok"> 
                            <label for="zusammenfassung_ok">Die Anlage ist in Ordnung.</label><br><br>
                            <input type="radio" id="zusammenfassung_maengel" name="zusammenfassung" value="maengel"> 
                            <label for="zusammenfassung_maengel">Die Anlage ist in Ordnung, hat aber geringfügige Mängel, <div style="margin-left: 25px;">die innerhalb von 
                                <input type="text" style="width: 50px; padding:2px;" placeholder="___" aria-label="Anzahl Wochen"> Wochen zu beheben sind.</div>
                            </label><br>
                            <input type="radio" id="zusammenfassung_nicht_ok" name="zusammenfassung" value="nicht_ok"> 
                            <label for="zusammenfassung_nicht_ok">Die Anlage ist nicht in Ordnung.</label><br>
                            <div id="nicht_ok_options" style="margin-left: 20px; display: none; background: #f8f9fa; padding: 10px; border-radius: var(--border-radius); margin-top: 5px;">
                                <strong>Grund:</strong><br><br>
                                <input type="checkbox" id="nicht_ok_gefahr" name="nicht_ok_grund" value="gefahr"> 
                                <label for="nicht_ok_gefahr">Es besteht Gefahr für Leben bzw. Sachwerte.</label>
                                <div style="margin-left: 25px;">
                                    Im Einvernehmen mit dem Anlagenbetreiber (dessen Vertretter)<br>
                                    wurde die Anlage spannungslos geschaltet.
                                </div>
                                <br>
                                <input type="checkbox" id="nicht_ok_abschaltung" name="nicht_ok_grund" value="abschaltung"> 
                                <label for="nicht_ok_abschaltung">Abschaltung nicht möglich bzw. nicht erreichbar.</label>
                                <br><br>
                                <input type="checkbox" id="nicht_ok_meldung" name="nicht_ok_grund" value="meldung"> 
                                <label for="nicht_ok_meldung">Die Meldung an die zuständige Behörde wurde erstattet</label>
                            </div>
                        </p>
                    </div>
                    
                    <br>
                    
                    <table>
                        <tr>
                            <td>Datum der Überprüfung:</td>
                            <td>
                                <input type="text" id="datum_ueberpruefung" 
                                       value="{{ datum_ueberpruefung|default(heutiges_datum) }}" 
                                       placeholder="dd.mm.yyyy"
                                       class="date-input"
                                       onchange="validateDate(this); calculateNextInspectionDate();">
                                <span id="datum_ueberpruefung_error" class="error-message"></span>
                            </td>
                        </tr>
                        <tr>
                            <td>Name des Prüfers:</td>
                            <td>
                                <input type="text" id="name_pruefer" value="{{ name_pruefer|default('Vagapov Jamal') }}" 
                                       style="padding: 5px; border: 1px solid var(--medium-gray); border-radius: var(--border-radius); width: 200px;"
                                       placeholder="Name des Prüfers">
                            </td>
                        </tr>
                        <tr>
                            <td>Unterschrift:</td>
                            <td>___________________</td>
                        </tr>
                        <tr>
                            <td>Nächste Überprüfung:</td>
                            <td>
                                <input type="text" id="naechste_ueberpruefung" 
                                       value="{{ naechste_ueberpruefung|default('') }}"
                                       placeholder="dd.mm.yyyy"
                                       class="date-input"
                                       onchange="validateDate(this); lockNextInspectionDate();">
                                <span id="naechste_ueberpruefung_error" class="error-message"></span>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </tbody>
    </table>
    
    <br>

    <div style="page-break-before: always;">
        <!-- Inhalt der nächsten Seite -->
    </div>

    <div class="section">
        <h3>Anlagendaten</h3>
        <table>
            <tr>
                <td>Anzahl Module:</td>
                <td><input type="number" id="modul_anzahl" value="{{ modul_anzahl|default('50') }}" min="1" onchange="calculateLeistung()"></td>
            </tr>
            <tr>
                <td>Gesamtleistung:</td>
                <td><span id="gesamtleistung_display">{{ gesamtleistung_kwp }} kWp</span></td>
            </tr>
            <tr>
                <td>Wechselrichter Hersteller:</td>
                <td>
                    <select id="wechselrichter_hersteller" onchange="updateWechselrichterData()">
                        <option value="">-- Bitte wählen --</option>
                        <option value="Solaxpower">Solaxpower</option>
                        <option value="Fronius">Fronius</option>
                        <option value="Huawei">Huawei</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td>Wechselrichter Type:</td>
                <td>
                    <select id="wechselrichter_type">
                        <option value="">-- Zuerst Hersteller wählen --</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td>Batteriespeicher Hersteller:</td>
                <td>
                    <select id="batterie_hersteller" onchange="updateBatterieData()">
                        <option value="">-- Bitte wählen --</option>
                        <option value="Solaxpower">Solaxpower</option>
                        <option value="BYD">BYD</option>
                        <option value="LG Energy Solution">LG Energy Solution</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td>Batteriespeicher Type:</td>
                <td>
                    <select id="batterie_type">
                        <option value="">-- Zuerst Hersteller wählen --</option>
                    </select>
                </td>
            </tr>
        </table>
    </div>

    <div style="text-align: center; margin-top: 30px;">
        <button id="pdfButton" class="btn btn-primary no-print">
            📄 Als PDF exportieren
        </button>
    </div>

    <script>
        // Konstanten und Datenbank für Komponenten
        const KOMPONENTEN_DATEN = {
            modul: {
                "Trina Solar": [
                    { type: "TSM-NEG9R.28", leistung: 455, spannung: 51.4 },
                    { type: "TSM-NEG9R.26", leistung: 445, spannung: 50.8 },
                    { type: "TSM-NEG9R.24", leistung: 435, spannung: 50.2 }
                ],
                "Jinko Solar": [
                    { type: "Tiger Neo 78HL4", leistung: 460, spannung: 52.1 },
                    { type: "Tiger Neo 78HL3", leistung: 450, spannung: 51.5 }
                ],
                "Canadian Solar": [
                    { type: "HiHero 445H", leistung: 445, spannung: 50.9 },
                    { type: "HiHero 435H", leistung: 435, spannung: 50.3 }
                ]
            },
            wechselrichter: {
                "Solaxpower": [
                    { type: "X3-Hybrid G4 10.0kW", leistung: 10000 },
                    { type: "X3-Hybrid G4 8.0kW", leistung: 8000 },
                    { type: "X3-Hybrid G4 6.0kW", leistung: 6000 }
                ],
                "Fronius": [
                    { type: "Primo 8.2-1", leistung: 8200 },
                    { type: "Primo 6.0-1", leistung: 6000 }
                ],
                "Huawei": [
                    { type: "SUN2000-10KTL", leistung: 10000 },
                    { type: "SUN2000-8KTL", leistung: 8000 }
                ]
            },
            batterie: {
                "Solaxpower": [
                    { type: "T-BAT H 9.0 V2", kapazitaet: 9.2 },
                    { type: "T-BAT H 6.0 V2", kapazitaet: 6.1 },
                    { type: "T-BAT H 12.0 V2", kapazitaet: 12.3 }
                ],
                "BYD": [
                    { type: "Battery-Box Premium HVS", kapazitaet: 10.2 },
                    { type: "Battery-Box Premium HVM", kapazitaet: 7.7 }
                ],
                "LG Energy Solution": [
                    { type: "RESU10H", kapazitaet: 9.8 },
                    { type: "RESU16H", kapazitaet: 16.0 }
                ]
            }
        };

        // Aktuelle Auswahl speichern
        let aktuellesModul = null;

        // DOM-Elemente-Cache
        const elements = {
            modal: document.getElementById('stammdatenModal'),
            anlagenbetreiberCell: document.getElementById('anlagenbetreiber-cell'),
            telefonNrCell: document.getElementById('telefon_nr-cell'),
            anlagenadresseCell: document.getElementById('anlagenadresse-cell'),
            postadresseCell: document.getElementById('postadresse-cell'),
            okBtn: document.getElementById('ok-btn'),
            cancelBtn: document.getElementById('cancel-btn'),
            nichtOkRadio: document.getElementById('zusammenfassung_nicht_ok'),
            nichtOkOptions: document.getElementById('nicht_ok_options'),
            pdfButton: document.getElementById('pdfButton')
        };

        // Funktion zur Validierung des dd.mm.yyyy Formats
        function validateDate(inputElement) {
            const value = inputElement.value.trim();
            const errorSpan = document.getElementById(inputElement.id + '_error');
            
            // Regex für dd.mm.yyyy Format
            const dateRegex = /^(0[1-9]|[12][0-9]|3[01])\.(0[1-9]|1[0-2])\.\d{4}$/;
            
            if (value === '') {
                if (errorSpan) errorSpan.textContent = '';
                inputElement.style.borderColor = 'var(--medium-gray)';
                return false;
            }
            
            if (!dateRegex.test(value)) {
                if (errorSpan) errorSpan.textContent = 'Ungültiges Format (dd.mm.yyyy)';
                inputElement.style.borderColor = 'var(--danger-color)';
                return false;
            }
            
            // Zusätzliche Validierung für reales Datum
            const parts = value.split('.');
            const day = parseInt(parts[0], 10);
            const month = parseInt(parts[1], 10);
            const year = parseInt(parts[2], 10);
            
            const date = new Date(year, month - 1, day);
            if (date.getFullYear() !== year || date.getMonth() !== month - 1 || date.getDate() !== day) {
                if (errorSpan) errorSpan.textContent = 'Ungültiges Datum';
                inputElement.style.borderColor = 'var(--danger-color)';
                return false;
            }
            
            if (errorSpan) errorSpan.textContent = '';
            inputElement.style.borderColor = 'var(--success-color)';
            return true;
        }

        // Funktion zur Berechnung des nächsten Überprüfungsdatums (dd.mm.yyyy)
        function calculateNextInspectionDate() {
            const currentDateInput = document.getElementById('datum_ueberpruefung');
            const nextDateInput = document.getElementById('naechste_ueberpruefung');
            
            if (currentDateInput.value && validateDate(currentDateInput)) {
                const parts = currentDateInput.value.split('.');
                const day = parseInt(parts[0], 10);
                const month = parseInt(parts[1], 10);
                const year = parseInt(parts[2], 10);
                
                // Datum + 1 Jahr berechnen
                const nextYear = year + 1;
                
                // Formatierung für dd.mm.yyyy sicherstellen
                const nextDate = `${day.toString().padStart(2, '0')}.${month.toString().padStart(2, '0')}.${nextYear}`;
                
                // Validieren ob das resultierende Datum gültig ist (für Schaltjahre etc.)
                const nextDateObj = new Date(nextYear, month - 1, day);
                if (nextDateObj.getDate() === day && nextDateObj.getMonth() === month - 1 && nextDateObj.getFullYear() === nextYear) {
                    nextDateInput.value = nextDate;
                } else {
                    // Falls ungültig (z.B. 29.02. in keinem Schaltjahr), letzten Tag des Monats nehmen
                    const lastDay = new Date(nextYear, month, 0).getDate();
                    nextDateInput.value = `${lastDay.toString().padStart(2, '0')}.${month.toString().padStart(2, '0')}.${nextYear}`;
                }
                
                validateDate(nextDateInput);
            }
        }

        // Sperrt das nächste Überprüfungsdatum nach manueller Änderung
        function lockNextInspectionDate() {
            const nextDateInput = document.getElementById('naechste_ueberpruefung');
            const currentDateInput = document.getElementById('datum_ueberpruefung');
            
            if (nextDateInput.value && currentDateInput.value && validateDate(nextDateInput) && validateDate(currentDateInput)) {
                const currentParts = currentDateInput.value.split('.');
                const currentYear = parseInt(currentParts[2], 10);
                const nextParts = nextDateInput.value.split('.');
                const nextYear = parseInt(nextParts[2], 10);
                
                const expectedYear = currentYear + 1;
                
                // Prüfen ob das Jahr vom Standard abweicht
                if (nextYear !== expectedYear) {
                    if (confirm(`Das Datum weicht vom Standard (Überprüfungsdatum + 1 Jahr = ${expectedYear}) ab. Möchten Sie dieses Datum wirklich verwenden?`)) {
                        nextDateInput.style.borderColor = 'var(--warning-color)';
                        nextDateInput.title = 'Manuell geändertes Datum';
                    } else {
                        // Zurücksetzen auf automatisches Datum
                        calculateNextInspectionDate();
                    }
                }
            }
        }

        // Hilfsfunktionen
        const utils = {
            // Daten im Local Storage speichern
            saveToStorage: (key, data) => {
                try {
                    localStorage.setItem(key, JSON.stringify(data));
                    return true;
                } catch (e) {
                    console.error('Fehler beim Speichern:', e);
                    return false;
                }
            },
            
            
            
            // Formular validieren
            validateForm: (fields) => {
                for (const [key, value] of Object.entries(fields)) {
                    if (value.required && !value.value.trim()) {
                        return { isValid: false, field: key };
                    }
                }
                return { isValid: true };
            },
            
            // Modal anzeigen/verstecken
            toggleModal: (show) => {
                elements.modal.style.display = show ? 'flex' : 'none';
                if (show) {
                    document.getElementById('input-anlagenbetreiber').focus();
                }
            }
        };

        // Stammdaten-Funktionen
        const stammdaten = {
            // Stammdaten speichern
            save: (data) => {
                return utils.saveToStorage('prufbefund_stammdaten', data);
            },
            
            // Stammdaten laden
            load: () => {
                return utils.loadFromStorage('prufbefund_stammdaten');
            },
            
            // Stammdaten anzeigen
            display: (data) => {
                if (!data) return false;
                
                elements.anlagenbetreiberCell.textContent = data.anlagenbetreiber || '_____';
                elements.telefonNrCell.textContent = data.telefon_nr || '_____';
                elements.anlagenadresseCell.textContent = data.anlagenadresse || '_____';
                elements.postadresseCell.textContent = data.postadresse || data.anlagenadresse || '_____';
                
                return true;
            },
            
            // Stammdaten zurücksetzen
            reset: () => {
                if (confirm('Möchten Sie die Stammdaten zurücksetzen und neu eingeben?')) {
                    localStorage.removeItem('prufbefund_stammdaten');
                    elements.anlagenbetreiberCell.textContent = '_____';
                    elements.telefonNrCell.textContent = '_____';
                    elements.anlagenadresseCell.textContent = '_____';
                    elements.postadresseCell.textContent = '_____';
                    
                    // Neu abfragen
                    askForStammdaten();
                }
            }
        };

        // Funktion zur Abfrage der Stammdaten
        function askForStammdaten() {
            utils.toggleModal(true);
        }

        // Reset-Button für Stammdaten
        function resetStammdaten() {
            stammdaten.reset();
        }

        // Anlagendaten-Funktionen
        function updateWechselrichterData() {
            const hersteller = document.getElementById('wechselrichter_hersteller').value;
            const typeSelect = document.getElementById('wechselrichter_type');
            
            typeSelect.innerHTML = '<option value="">-- Bitte wählen --</option>';
            
            if (hersteller && KOMPONENTEN_DATEN.wechselrichter[hersteller]) {
                KOMPONENTEN_DATEN.wechselrichter[hersteller].forEach(wr => {
                    const option = document.createElement('option');
                    option.value = wr.type;
                    option.textContent = `${wr.type} (${wr.leistung/1000}kW)`;
                    typeSelect.appendChild(option);
                });
            }
        }

        function updateBatterieData() {
            const hersteller = document.getElementById('batterie_hersteller').value;
            const typeSelect = document.getElementById('batterie_type');
            
            typeSelect.innerHTML = '<option value="">-- Bitte wählen --</option>';
            
            if (hersteller && KOMPONENTEN_DATEN.batterie[hersteller]) {
                KOMPONENTEN_DATEN.batterie[hersteller].forEach(batterie => {
                    const option = document.createElement('option');
                    option.value = batterie.type;
                    option.textContent = `${batterie.type} (${batterie.kapazitaet}kWh)`;
                    typeSelect.appendChild(option);
                });
            }
        }

        function calculateLeistung() {
            const anzahl = parseInt(document.getElementById('modul_anzahl').value) || 0;
            
            if (aktuellesModul && anzahl > 0) {
                const gesamtleistung = (aktuellesModul.leistung * anzahl) / 1000;
                document.getElementById('gesamtleistung_display').textContent = 
                    `${gesamtleistung.toFixed(1)} kWp`;
            }
        }

        function exportToPDF() {
            // Temporär den Button ausblenden
            elements.pdfButton.style.display = 'none';
            
            // Drucken/PDF-Erstellung
            window.print();
            
            // Button nach kurzer Zeit wieder anzeigen
            setTimeout(() => {
                elements.pdfButton.style.display = 'inline-block';
            }, 1000);
        }

        // Event Listener für Modal
        elements.okBtn.addEventListener('click', function() {
            const formData = {
                anlagenbetreiber: {
                    value: document.getElementById('input-anlagenbetreiber').value.trim(),
                    required: true
                },
                telefon_nr: {
                    value: document.getElementById('input-telefon_nr').value.trim(),
                    required: true
                },
                anlagenadresse: {
                    value: document.getElementById('input-anlagenadresse').value.trim(),
                    required: true
                },
                postadresse: {
                    value: document.getElementById('input-postadresse').value.trim(),
                    required: false
                }
            };
            
            // Validierung
            const validation = utils.validateForm(formData);
            if (!validation.isValid) {
                alert('Bitte füllen Sie alle Pflichtfelder aus (mit * markiert).');
                document.getElementById(`input-${validation.field}`).focus();
                return;
            }
            
            // Daten in die Tabelle eintragen
            const processedData = {
                anlagenbetreiber: formData.anlagenbetreiber.value,
                telefon_nr: formData.telefon_nr.value,
                anlagenadresse: formData.anlagenadresse.value,
                postadresse: formData.postadresse.value || formData.anlagenadresse.value
            };
            
            stammdaten.display(processedData);
            
            // Modal schließen
            utils.toggleModal(false);
            
            // Speichern im Local Storage
            stammdaten.save(processedData);
        });
        
        elements.cancelBtn.addEventListener('click', function() {
            if (confirm('Möchten Sie wirklich abbrechen? Der Prüfbefund kann ohne Stammdaten nicht erstellt werden.')) {
                utils.toggleModal(false);
            }
        });

        // Event Listener für die Radio-Buttons (Zusammenfassung)
        document.addEventListener('DOMContentLoaded', function() {
            document.querySelectorAll('input[name="zusammenfassung"]').forEach(radio => {
                radio.addEventListener('change', function() {
                    if (this.value === 'nicht_ok') {
                        elements.nichtOkOptions.style.display = 'block';
                    } else {
                        elements.nichtOkOptions.style.display = 'none';
                        // Zurücksetzen der Checkboxen
                        document.querySelectorAll('input[name="nicht_ok_grund"]').forEach(checkbox => {
                            checkbox.checked = false;
                        });
                    }
                });
            });
            
            // PDF-Button Event
            elements.pdfButton.addEventListener('click', exportToPDF);
            
            // Enter-Taste im Modal unterstützen
            document.addEventListener('keypress', function(e) {
                if (e.key === 'Enter' && elements.modal.style.display === 'flex') {
                    elements.okBtn.click();
                }
            });
            
            // ESC-Taste zum Schließen des Modals
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape' && elements.modal.style.display === 'flex') {
                    elements.cancelBtn.click();
                }
            });
            
            // Initial Datumsvalidierung und Berechnung
            const currentDateInput = document.getElementById('datum_ueberpruefung');
            if (currentDateInput) {
                validateDate(currentDateInput);
                calculateNextInspectionDate();
            }
            
            const nextDateInput = document.getElementById('naechste_ueberpruefung');
            if (nextDateInput) {
                validateDate(nextDateInput);
            }
        });

        // Beim Laden der Seite
        window.onload = function() {
            // Zuerst versuchen, gespeicherte Daten zu laden
            const savedData = stammdaten.load();
            const hasSavedData = stammdaten.display(savedData);
            
            // Wenn keine gespeicherten Daten vorhanden sind, Dialog anzeigen
            if (!hasSavedData) {
                // Kurz warten damit die Seite komplett geladen ist
                setTimeout(askForStammdaten, 100);
            }
            
            // Vorauswahl für Anlagendaten
            {% if modul_hersteller %}
            document.getElementById('modul_hersteller').value = "{{ modul_hersteller }}";
            updateModulData();
            {% endif %}
            
            {% if modul_type %}
            setTimeout(() => {
                document.getElementById('modul_type').value = "{{ modul_type }}";
                updateModulDetails();
            }, 100);
            {% endif %}
            
            {% if wechselrichter_hersteller %}
            document.getElementById('wechselrichter_hersteller').value = "{{ wechselrichter_hersteller }}";
            updateWechselrichterData();
            {% endif %}
            
            {% if batterie_hersteller %}
            document.getElementById('batterie_hersteller').value = "{{ batterie_hersteller }}";
            updateBatterieData();
            {% endif %}
        };
    </script>
</body>
</html>