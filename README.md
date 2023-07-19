# CookidooExporter zu Bring

Leider verfügt Cookidoo nicht über eine Importfunktion, was mich ein wenig gestört hat. Deshalb habe ich ein PowerShell-Skript geschrieben, das es mir ermöglicht, die Zutaten von der offiziellen Coockidoo-Website zu importieren. Da ich bereits eine laufende ioBroker-Instanz habe, kann ich dieses Skript verwenden.

Wenn du also einen Thermomix besitzt, deine Woche planst und eine laufende ioBroker-Instanz hast, kannst du jetzt dieses Skript verwenden, um Bring für deine Einkäufe zu nutzen. Ich finde es viel bequemer.

Außerdem habe ich das Ganze nun in eine ausführbare Datei (EXE) gepackt. Diese fragt einmalig die benötigten Daten ab. Danach musst du nur die Einkaufsliste auf der Coockidoo-Website kopieren und über den Start der EXE importieren.

Die einrichtung dauert etwas, einmal eingerichtet, ist es jedoch ein Leichtes die Einkaufsliste hochzuladen.

# Notwendig

Bring Account

Iobroker mit Bring und Simple api Plugin  (Bring muss mit deinem Account angemeldet werden auf Iobroker)

Coockidoo 



# Erweiterte Anleitung

Bitte hinterlege die EXE-Datei an dem Ort, an dem du sie haben möchtest.

Um fortzufahren, gehe bitte zu https://cookidoo.de/ und melde dich dort an. Gehe dann zu deiner Einkaufsliste und wähle oben den Reiter "Nach Rezepten" aus. Dadurch wird sichergestellt, dass die Lebensmittel korrekt zusammengerechnet werden und nicht doppelt angezeigt werden.
![image](https://github.com/toonymak1993/CookidooExporter/assets/78177901/7dfe677b-116e-41e2-aa4f-00ec8829e92f)

Nun klicke auf Optionen und Teilen und kopiere die Liste in den Clipboard
![image](https://github.com/toonymak1993/CookidooExporter/assets/78177901/ee513f63-fb04-4360-8b1e-2a0eb2906b0e)

Starte nun die Exe. Beim ersten mal müssen folgende Daten in die Textboxen eingetragen werden: 
Als Beispiel:
URL + Port von Iobroker = http://192.168.178.98:8087
Bring IOBROKER Knoten = bring.0.b679bc07-9183-48ac-b555-bbf9df0913bf.saveItem

Die Form speichert beim klicken vom Button (Import zu Bring) die Daten in %APPDATA%/coockidoexport/setting.xml
Die Form öffnet sich bei jedem durchlauf und zeigt die aktuellen Werte an, so das die Daten jederzeit aktualisiert werden können , sollte sich was ändern an der URL.

![1](https://github.com/toonymak1993/CookidooExporter/assets/78177901/a5896fd7-c146-48ce-b77d-dcb9f18a15c2)

Nun bestätige mit dem Button (Import zu Bring) und wenn die Verbindung geklappt hat, erhält man eine bestätigung. 

![image](https://github.com/toonymak1993/CookidooExporter/assets/78177901/811da68c-e4f7-4161-ada8-4f6d6040672a)

In der APP sollten nun die Produkte mit Bild verfügbar sein

![image](https://github.com/toonymak1993/CookidooExporter/assets/78177901/0aeebca4-b2db-483b-a656-4cbfc45db8ec)

# Simple Anleitung sobald eingerichtet: 

Kopiere die Daten auf der Cookidoo Webseite.

Starte die Exe und klicke auf dem Button (Import zu Bring).

Die Daten werden nun vom Clipboard genommen und hochgeladen.
