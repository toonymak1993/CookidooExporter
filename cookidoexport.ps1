#region erster Start und URI Aktualisierung
$coockidoExportPath = Join-Path $env:APPDATA "coockidoexport"
$settingFilePath = Join-Path $coockidoExportPath "setting.xml"

$firstRun = $false

# Überprüfe, ob der coockidoexport-Ordner vorhanden ist, andernfalls erstelle ihn
if (-not (Test-Path $coockidoExportPath -PathType Container))
{
	New-Item -Path $coockidoExportPath -ItemType Directory | Out-Null
	$firstRun = $true
}

# Überprüfe, ob die setting.xml-Datei vorhanden ist, andernfalls erstelle sie
if (-not (Test-Path $settingFilePath -PathType Leaf))
{
	$defaultSettings = '<?xml version="1.0" encoding="UTF-8"?><settings></settings>'
	$defaultSettings | Out-File -FilePath $settingFilePath -Encoding UTF8
	$firstRun = $true
}

# UI erstellen
Add-Type -AssemblyName System.Windows.Forms

$form = New-Object System.Windows.Forms.Form
$form.Text = "Einstellungen"
$form.Size = New-Object System.Drawing.Size(400, 250)
$form.MaximumSize.Height = 250
$form.MaximizeBox = $false
$form.FormBorderStyle = 'FixedSingle'
$form.MaximumSize.Width = 400
$form.StartPosition = "CenterScreen"

if ($firstRun)
{
	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10, 10)
	$label.Size = New-Object System.Drawing.Size(380, 40)
	$label.Text = "Erster Programmstart, es wird ein Ordner im Pfad %APPDATA% erstellt"
	$form.Controls.Add($label)
}

$label1 = New-Object System.Windows.Forms.Label
$label1.Location = New-Object System.Drawing.Point(10, 50)
$label1.Size = New-Object System.Drawing.Size(280, 20)
$label1.Text = "URL & Port:"
$form.Controls.Add($label1)

$textBox1 = New-Object System.Windows.Forms.TextBox
$textBox1.Location = New-Object System.Drawing.Point(10, 70)
$textBox1.Size = New-Object System.Drawing.Size(280, 20)
$form.Controls.Add($textBox1)

$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(10, 100)
$label2.Size = New-Object System.Drawing.Size(280, 20)
$label2.Text = "Bringlink:"
$form.Controls.Add($label2)

$textBox2 = New-Object System.Windows.Forms.TextBox
$textBox2.Location = New-Object System.Drawing.Point(10, 120)
$textBox2.Size = New-Object System.Drawing.Size(280, 20)
$form.Controls.Add($textBox2)

$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10, 150)
$button.Size = New-Object System.Drawing.Size(140, 23)
$button.Text = "Import zu Bring"
$button.Add_Click({
		$global:iourl = $textBox1.Text
		$global:bringlink = $textBox2.Text
		
		# XML-Daten aktualisieren oder erstellen
		[xml]$settingsXml = New-Object System.Xml.XmlDocument
		if (Test-Path $settingFilePath -PathType Leaf)
		{
			$settingsXml.Load($settingFilePath)
		}
		else
		{
			$settingsXml.AppendChild($settingsXml.CreateXmlDeclaration("1.0", "UTF-8", $null))
			$settingsXml.AppendChild($settingsXml.CreateElement("settings"))
		}
		
		# Elemente "URL" und "Bringlink" aktualisieren oder erstellen
		$settingsElement = $settingsXml.SelectSingleNode("//settings")
		
		$urlElement = $settingsElement.SelectSingleNode("URL")
		if ($urlElement -eq $null)
		{
			$urlElement = $settingsXml.CreateElement("URL")
			$settingsElement.AppendChild($urlElement)
		}
		$urlElement.InnerText = $iourl
		
		$bringlinkElement = $settingsElement.SelectSingleNode("Bringlink")
		if ($bringlinkElement -eq $null)
		{
			$bringlinkElement = $settingsXml.CreateElement("Bringlink")
			$settingsElement.AppendChild($bringlinkElement)
		}
		$bringlinkElement.InnerText = $bringlink
		
		$settingsXml.Save($settingFilePath)
		
		$form.Close()
	})
$form.Controls.Add($button)

# Wenn die Datei bereits vorhanden ist, lade die Daten aus der XML-Datei
if (Test-Path $settingFilePath -PathType Leaf)
{
	[xml]$settingsXml = New-Object System.Xml.XmlDocument
	$settingsXml.Load($settingFilePath)
	$textBox1.Text = $settingsXml.SelectSingleNode("//settings/URL").InnerText
	$textBox2.Text = $settingsXml.SelectSingleNode("//settings/Bringlink").InnerText
}

$form.ShowDialog() | Out-Null


#endregion erster Start und URI Aktualisierung

# Funktion zum Überprüfen des Clipboards
function CheckClipboard
{
	# Text aus der Zwischenablage lesen
	$rezept = Get-Clipboard -Raw
	
	# Zeilen des Texts ab der ersten Zeile mit Inhalt extrahieren
	$zeilen = $rezept -split '\r?\n' | Where-Object { $_.Trim() -ne '' }
	
	# Überprüfen, ob die erste Zeile Klammern enthält
	if ($zeilen[0] -match '^\s*\[.*?\]\s*$')
	{
		$ergebnisArray = @()
		
		# Durchlaufe die Zeilen ab der zweiten Zeile
		for ($i = 1; $i -lt $zeilen.Count; $i++)
		{
			$zeile = $zeilen[$i].Trim()
			
			# Überprüfen, ob die Zeile nicht mit Klammern beginnt oder endet
			if (-not $zeile.StartsWith('[') -and -not $zeile.EndsWith(']') -and $zeile -ne '')
			{
				$ergebnisArray += $zeile
			}
		}
		
		# Überprüfen auf doppelte Werte und Anzahl hinzufügen
		$ergebnisArray = Get-UniqueArray $ergebnisArray
		
		# Rückgabe des Ergebnis-Arrays
		return $ergebnisArray
	}
	else
	{
		# Fehlermeldung anzeigen
		Show-Error "Der Text in der Zwischenablage beginnt nicht mit eckigen Klammern."
		exit
		return $null
	}
}

# Funktion zur Anzeige einer Fehlermeldung mit einer MessageBox
function Show-Error($message)
{
	[System.Windows.Forms.MessageBox]::Show($message, "Fehler", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# Funktion zum Entfernen von doppelten Werten in einem Array und Anzahl hinzufügen
function Get-UniqueArray
{
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[Array]$Array
	)
	
	$result = @()
	$countTable = @{ }
	
	foreach ($item in $Array)
	{
		if ($countTable.ContainsKey($item))
		{
			$count = $countTable[$item]
			$count++
			$countTable[$item] = $count
			$newItem = "$item x$count"
		}
		else
		{
			$countTable[$item] = 1
			$newItem = $item
		}
		
		$result += $newItem
	}
	
	return $result
}

#Verbindung mit IOBROKER
#Benötigte Variablen
$global:saveitem = "$iourl" + "/set/" + "$bringlink"
$global:number = 0
$successfulCount = 0
$errorCount = 0
$hasError = $false

# Funktion zum Senden eines Werts an ioBroker
function SendValueToIoBroker($url)
{
	try
	{
		# API-Aufruf an ioBroker
		Invoke-RestMethod -Uri $url -Method Put -ContentType "application/json"
		Write-Host "Wert erfolgreich an ioBroker gesendet."
		$global:successfulCount++
	}
	catch
	{
		$script:hasError = $true
		Show-Error "Fehler beim Senden des Werts an ioBroker: $_"
		$global:errorCount++
	}
}

# Aufruf der Funktion CheckClipboard
$ergebnisArray = CheckClipboard

# Wenn das Ergebnis-Array nicht leer ist und kein Fehler aufgetreten ist, Werte an ioBroker senden
if ($ergebnisArray -and !$hasError)
{
	foreach ($list in $ergebnisArray)
	{
		# wert und API-URL für ioBroker
		$Wert = $list
		$ApiUrl = $global:saveitem + "?value=$Wert"
		
		# Aufruf der Funktion, um den Beispielwert an ioBroker zu senden
		SendValueToIoBroker $ApiUrl
		
		# Wenn ein Fehler aufgetreten ist, den Schleifen-Durchlauf abbrechen
		if ($hasError)
		{
			break
		}
	}
}

# Ausgabe der Anzahl der erfolgreich gesendeten Produkte und der Anzahl der fehlerhaften Produkte in einer MessageBox
if (!$hasError)
{
	$message = "Anzahl erfolgreich gesendeter Produkte: $global:successfulCount`nAnzahl fehlerhafter Produkte: $global:errorCount"
	[System.Windows.Forms.MessageBox]::Show($message, "Auswertung", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
	}
	

