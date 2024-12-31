﻿# Constantes
$AppNameShort = "SpotiX+ Reborn"
$AppName = "$AppNameShort PC Script"
$Version = "1.1"
$ByPassAdmin = $false
$Github = "https://github.com/AgoyaSpotix/spotixplus-reborn-windows"

# Logo fait avec https://patorjk.com/software/taag/
$Logo = "
       ____                    _     _  __  __        
      / ___|   _ __     ___   | |_  (_) \ \/ /    _   
      \___ \  | '_ \   / _ \  | __| | |  \  /   _| |_ 
       ___) | | |_) | | (_) | | |_  | |  /  \  |_   _|
      |____/  | .__/   \___/   \__| |_| /_/\_\   |_|  
              |_|  ____      _                       
                  |  _ \ ___| |__   ___  _ __ _ __    
                  | |_) / _ \ '_ \ / _ \| '__| '_ \   
                  |  _ <  __/ |_) | (_) | |  | | | |  
                  |_| \_\___|_.__/ \___/|_|  |_| |_|  

       ----------------------------------------------
      /     Merci d'avoir téléchargé le script      /
     / App tierces utilisées: SpotX CLI, Spicetify /
    /                Version $Version                  /
   -----------------------------------------------
"

# Paramètre PowerShell
$ErrorActionPreference = "Continue"

function EnterToContinue {
	param (
		[bool] $DefaultPrompt = $false
	)
	if ($DefaultPrompt) {
		Write-Host "Appuyez sur Entrée pour continuer..." -NoNewLine
	}
	$Host.UI.ReadLine()
}

function SetTitle {
	param (
		[string] $Name
	)
	$Host.UI.RawUI.WindowTitle = "$AppName v$Version - $Name"
}

function StopSpotify {
	$spotify = Get-Process -Name spotify -ErrorAction SilentlyContinue
	if ($spotify) {
		Stop-Process $spotify
	}
}

function RemoveIfExists {
	param (
		[string] $Path
	)
	if (Test-Path -Path $Path) {
		Remove-Item $Path -Recurse
	}
}

# Titre fenêtre
SetTitle "Chargement"

# Change de répertoire
Set-Location $PSScriptRoot

# Génére un nom de fichier de log unique basé sur la date et l'heure
$date = Get-Date -Format "yyyyMMdd_HHmmss"
$log_file_name = "logs_$date.txt"
$log_file_dir = "$PSScriptRoot\SpotiX-Logs\$log_file_name"

# Crée le répertoire nécessaire pour les logs
if (-not (Test-Path -Path "$PSScriptRoot\SpotiX-Logs")) {
	New-Item -Path "$PSScriptRoot\SpotiX-Logs\" -ItemType Directory
}

# Commencement des logs
Start-Transcript -Path $log_file_dir

# Vérifie si PowerShell 7 est installé
$powershellPath        = "C:\Program Files\PowerShell\7\pwsh.exe"
$powershellPreviewPath = "C:\Program Files\PowerShell\7-preview\pwsh.exe"

# PowerShell 7 pas trouvé => demande à l'utilisateur de l'installer
if (($PSVersionTable.PSVersion.Major -lt 7) -and (-Not ((Test-Path $powershellPath) -or (Test-Path $powershellPreviewPath)))) {
	SetTitle "Erreur"
	Clear-Host
	Write-Host "PowerShell 7 n'est pas installé sur ce système." -ForegroundColor Red
	$confirmation = Read-Host -Prompt "Souhaitez-vous installer PowerShell 7 ? (Y/N)"

	if ($confirmation -eq "Y") {
		# Installation de PowerShell 7
		SetTitle "PowerShell 7.3.3"
		Clear-Host
		Write-Host "Lancement du téléchargement de PowerShell 7.3.3..." -ForegroundColor Green

		$url = "https://github.com/PowerShell/PowerShell/releases/download/v7.3.3/PowerShell-7.3.3-win-x64.msi"
		$fichierLocal = "$env:TEMP\PowerShell-7.3.3-win-x64.msi"

		$webClient = New-Object System.Net.WebClient
		$webClient.DownloadFile($url, $fichierLocal)

		if (Test-Path $fichierLocal) {
			Write-Host "Téléchargement terminé. Lancement de l'installation..." -ForegroundColor Green
			Start-Process $fichierLocal
			Write-Host "Une fois l'installation terminée, vous pouvez relancer ce script avec PowerShell 7." -ForegroundColor Green
			Write-Host "Pour obtenir des instructions supplémentaires, veuillez consulter le tutoriel sur le site $AppNameShort" -ForegroundColor Green
			EnterToContinue -DefaultPrompt $true
			Stop-Transcript
			exit
		} else {
			Write-Host "Une erreur est survenue lors du téléchargement." -ForegroundColor Red
			EnterToContinue -DefaultPrompt $true
			Stop-Transcript
			exit
		}
	} else {
		Clear-Host
		Write-Host "Vous pouvez fermer cette fenêtre en appuyant sur Entrée." -ForegroundColor Yellow -NoNewLine
		EnterToContinue -DefaultPrompt $true
		Stop-Transcript
		exit
	}
}

# PowerShell 7 est installé, exécute le script avec PowerShell 7 si c'est pas le cas
if ($args -notcontains "-FromLauncher") {
	if ($PSVersionTable.PSVersion.Major -lt 7) {
		Write-Host "Chargement.." -ForegroundColor Yellow
		$scriptPath = $MyInvocation.MyCommand.Path
		if ($scriptPath -match "AppData\\Local\\Temp") {
			$destinationDir = "$PSScriptRoot\SpotiX-Logs\"
			if (-Not (Test-Path $destinationDir)) {
				New-Item -Path $destinationDir -ItemType Directory -Force
			}
			$newScriptPath = Join-Path $destinationDir (Split-Path -Leaf $scriptPath)
			Write-Host "Déplacement du script a cette adresse : $newScriptPath" -ForegroundColor Yellow
			Write-Host "Lancement du script.." -ForegroundColor Yellow
			Copy-Item -Path $scriptPath -Destination $newScriptPath -Force
			$scriptPath = $newScriptPath
		}

		if (Test-Path $powershellPath) {
			Start-Process $powershellPath -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`" -FromLauncher"
		} else {
			Start-Process $powershellPreviewPath -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`" -FromLauncher"
		}
		exit
	}
}

# Verification admin ou pas
if ((-not $ByPassAdmin) -and ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	Write-Host "Pour pouvoir faire fonctionner correctement le script, celui ci ne dois pas être lancer en administrateur." -ForegroundColor Red
	Write-Host "Veuillez redémarrer le script normalement." -ForegroundColor Red
	EnterToContinue -DefaultPrompt $true
	exit 1
}

function PrintLogo {
	Clear-Host
	Write-Host $Logo -ForegroundColor Green
	Write-Host ""
}

function GetUserChoices {
	param (
		[string[]]$validResponses
	)

	$responses = $null
	do {
		Write-Host " > " -NoNewLine
		$input = $Host.UI.ReadLine().Replace(" ", "")
		$responses = $input.Split(",") -ne ''
	} while ($responses -eq $null)

	return $responses
}

function Main {
	# Changement nom fenêtre
	SetTitle "Accueil"

	# Affichage du logo
	PrintLogo

	# Accueil du script
	Write-Host "PREVENTION: ce script utilise votre connexion internet pour fonctionner correctement." -ForegroundColor Yellow
	Write-Host "Ne désactivez pas votre connexion internet pendant l'exécution du script." -ForegroundColor Yellow
	Write-Host ""

	Write-Host ((
		"Que voulez-vous faire ?",
		"1. Installer $AppNameShort",
		"2. Activer/Désactiver la qualité très élevée",
		"3. Désinstaller $AppNameShort",
		"4. Ouvrir la page GitHub",
		"5. Fermer le script"
	) -join "`n`t")

	$userChoices0 = GetUserChoices -validResponses @("1", "2", "3", "4", "5", "6")

	# Exécute les commandes en fonction des réponses
	foreach ($choice in $userChoices0) {
		switch ($choice.Trim()) {
			"1" {
				# Installation
				PrintLogo
				$confirmation1 = Read-Host -Prompt "Avez-vous Spotify actuellement installé sur votre ordinateur ? (Y/N)"
				PrintLogo
				if ($confirmation1 -eq "N") {
					Write-Host ((
						"Quelle version de Spotify souhaitez-vous ?",
						"1. Nouvelle interface - Compatible avec Windows 11/10         - Plugin externe compatible",
						"2. Ancienne interface - Compatible avec Windows 11/10/8.1/8/7 - Plugin externe compatible"
					) -join "`n`t")
					Write-Host "Pour en savoir plus sur les différences entre les versions, consultez la page tutoriel PC du site $AppNameShort (1/2)"
					$confirmation2 = GetUserChoices -validResponses @("1", "2")

					if ($confirmation2 -eq "1") {
						# URL et fichier pour la nouvelle interface
						$url = "https://download.scdn.co/SpotifySetup.exe"
						$spotifyInstaller = "$env:TEMP\SpotifySetup.exe"
					} else {
						# URL et fichier pour l'ancienne interface
						$url = "https://download.scdn.co/SpotifyFull7-8-8.1.exe"
						$spotifyInstaller = "$env:TEMP\SpotifyFull7-8-8.1.exe"
					}

					# Installation de Spotify
					SetTitle "Installation"
					PrintLogo

					Write-Host "Téléchargement et installation de Spotify.."

					$webClient = New-Object System.Net.WebClient
					$webClient.DownloadFile($url, $spotifyInstaller)

					Start-Process $spotifyInstaller
					Write-Host "Une fois Spotify installé, vous pouvez appuyer sur la touche Entrée"
					EnterToContinue

					# SpotX
					Write-Host "Téléchargement/Installation de SpotX CLI.."
					SetTitle "SpotX Configuration"
					Clear-Host
					[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex "& { $((iwr -useb 'https://raw.githubusercontent.com/SpotX-Official/SpotX/main/run.ps1').Content) }"
					Write-Host "Script 1/2 installés : SpotiX installé"

					# Fermeture de Spotify
					Write-Host "Fermeture de Spotify pour faciliter l'exécution des scripts"
					StopSpotify

					# Dossier Spicetify
					Write-Host "Création des dossiers nécessaires"
					if (-not (Test-Path -Path "$env:AppData\spicetify\")) {
						New-Item -Path "$env:AppData\spicetify\" -ItemType Directory
					}

					# Spicetify
					SetTitle "Spicetify Configuration"
					Clear-Host
					[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; iex "& { $((iwr -useb 'https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.ps1').Content) }"
					Write-Host "Script 2/2 installés : Spicetify"

					# Renommer le raccourci Spotify du bureau
					$oldFile = "$env:UserProfile\Desktop\Spotify.lnk"
					$newFile = "$env:UserProfile\Desktop\$AppNameShort.lnk"
					Rename-Item -Path $oldFile -NewName $newFile

					# Renommer le raccourci Spotify du menu démarrer
					$oldFile = "$env:AppData\Microsoft\Windows\Start Menu\Programs\Spotify.lnk"
					$newFile = "$env:AppData\Microsoft\Windows\Start Menu\Programs\$AppNameShort.lnk"
					Rename-Item -Path $oldFile -NewName $newFile

					# Arrêt du processus Spotify
					StopSpotify

					# Conditions
					Write-Host "Configuration de $AppNameShort"
					$pathconfig = "$env:AppData\Spotify\"
					New-Item -Path $pathconfig -Name "config.need" -ItemType "File" -Force

					# Plugins
					SetTitle "Spicetify plugins"
					PrintLogo

					Write-Host "Spicetify propose 3 plugins externes pouvant améliorer l'expérience utilisateur"
					Write-Host ((
						"Souhaitez vous installer des plugins externes ?",
						"1. Reddit: récupérez des messages de n'importe quel subreddit de partage de liens Spotify",
						"2. Lyrics-plus: accédez aux paroles du titre actuel grâce à divers fournisseurs,",
						"                tels que Musixmatch, Netease et Genius",
						"3. New-releases: regroupez toutes les nouvelles sorties de vos artistes et podcasts préférés"
					) -join "`n`t")
					Write-Host "Vous pouvez choisir plusieurs plugins externes en mettant une virgule entre chaque nombre (ex : 2,3)"
					Write-Host "Appuyez sur Entrer en laissant vide pour ne rien installer"
					$userChoices = GetUserChoices -validResponses @("1", "2", "3")

					# Installation des plugins en fonction des réponses
					foreach ($choice in $userChoices) {
						switch ($choice.Trim()) {
							"1" {
								Write-Output 'Installation du plugin externe "Reddit"..'
								spicetify config custom_apps reddit
								spicetify apply
								Write-Output 'Plugin externe "Reddit" installé avec succès !'
							}
							"2" {
								Write-Output 'Installation du plugin externe "Lyrics-plus"..'
								spicetify config custom_apps lyrics-plus
								spicetify apply
								Write-Output 'Plugin externe "Lyrics-plus" installé avec succès !'
							}
							"3" {
								Write-Output 'Installation du plugin externe "New-releases"..'
								spicetify config custom_apps new-releases
								spicetify apply
								Write-Output 'Plugin externe "New-releases" installé avec succès !'
							}
						}
					}
					SetTitle "Installation terminée"
					PrintLogo
					Write-Host "Fin de la configuration de $AppNameShort.."
					StopSpotify
					Write-Host "$AppNameShort installé avec succès !"
					EnterToContinue -DefaultPrompt $true
					Stop-Transcript
					exit
				} else {
					# Erreur Spotify déjà installé
					Write-Host "Avant d'installer $AppNameShort, veuillez tout d'abord désinstaller Spotify (ou Spotify Windows Store)"
					EnterToContinue -DefaultPrompt $true
					Stop-Transcript
					exit
				}

			}
			"2" {
				# Qualité audio
				SetTitle "Configuration Audio"
				PrintLogo

				if (-not (Test-Path -Path "$env:AppData\Spotify")) {
					SetTitle "Erreur"
					Write-Host "$AppNameShort n'est pas installé sur votre PC, merci de l'installer d'abord."
					EnterToContinue -DefaultPrompt $true
					Stop-Transcript
					exit
				}

				# Fichier trouvé
				Write-Host "ATTENTION: ne démarrez pas $AppNameShort pendant ce processus, cela pourrait engendrer des conflits" -ForegroundColor Red
				Write-Host ((
					"Quelle qualité audio souhaitez-vous ?",
					"1. Qualité très élevée",
					"2. Qualité basique (réglable depuis $AppNameShort)"
				) -join "`n`t")
				$confirmation = GetUserChoices -validResponses @("1", "2")
				PrintLogo
				SetTitle "Configuration Audio"

				StopSpotify
				if ($confirmation -eq "1") {
					Write-Host "Configuration de la qualité très élevée"
				} else {
					Write-Host "Suppresion de la qualité très élévée"
				}

				$audioveryhigh = (
					"audio.sync_bitrate=320000",
					"audio.play_bitrate=320000"
				) -join "`n"

				$prefs = "$env:AppData\Spotify\prefs"
				if (Test-Path -Path $prefs) {
					if ($confirmation -eq "1") {
						Add-Content -Path $prefs -Value $audioveryhigh
						Set-ItemProperty -Path $prefs -Name IsReadOnly -Value $true
					} else {
						Set-ItemProperty -Path $prefs -Name IsReadOnly -Value $false
						$content = Get-Content -Path $prefs
						$newContent = $content | Where-Object { $_ -notmatch "audio.sync_bitrate=320000" -and $_ -notmatch "audio.play_bitrate=320000" }
						Set-Content -Path $prefs -Value $newContent
					}
				}
				$tmp = "$env:AppData\Spotify\prefs.tmp"
				if (Test-Path -Path $tmp) {
					if ($confirmation -eq "1") {
						Add-Content -Path $tmp -Value $audioveryhigh
						Set-ItemProperty -Path $tmp -Name IsReadOnly -Value $true
					} else {
						Set-ItemProperty -Path $tmp -Name IsReadOnly -Value $false
						$content = Get-Content -Path $tmp
						$newContent = $content | Where-Object { $_ -notmatch "audio.sync_bitrate=320000" -and $_ -notmatch "audio.play_bitrate=320000" }
						Set-Content -Path $tmp -Value $newContent
					}
				}

				if ($confirmation -eq "1") {
					Write-Host "La qualité très élevée est appliquée !"
				} else {
					Write-Host "La qualité très élevée a été supprimée avec succès !"
				}
				EnterToContinue -DefaultPrompt $true
				Stop-Transcript
				exit
			}
			"3" {
				PrintLogo
				# Désinstallation

				if (-not (Test-Path -Path "$env:AppData\Spotify")) {
					SetTitle "Erreur"
					Write-Host "Vous ne pouvez pas déinstaller $AppNameShort car celui-ci n'est pas installé."
					EnterToContinue -DefaultPrompt $true
					Stop-Transcript
					exit
				}

				$confirmation = Read-Host -Prompt "Êtes vous sûr de vouloir désinstaller $AppNameShort et tout ses composants ? (Y/N)"
				PrintLogo
				if ($confirmation -eq "Y") {
					SetTitle "Désinstallation"
					StopSpotify
					Write-Host "Désinstallation de $AppNameShort.."

					# Suppression des dossiers/fichiers
					Write-Host "Suppresion de Spicetify.."
					RemoveIfExists "$env:AppData\spicetify"

					Write-Host "Suppresion de Spotify.."

					$prefs = "$env:AppData\Spotify\prefs"
					if (Test-Path -Path $prefs) {
						Set-ItemProperty -Path $prefs -Name IsReadOnly -Value $false
					}
					$tmp = "$env:AppData\Spotify\prefs.tmp"
					if (Test-Path -Path $tmp) {
						Set-ItemProperty -Path $tmp -Name IsReadOnly -Value $false
					}

					RemoveIfExists "$env:AppData\Spotify"
					RemoveIfExists "$env:LocalAppData\Spotify"
					RemoveIfExists "$env:UserProfile\Desktop\$AppNameShort.lnk"

					Write-Host "$AppNameShort désinstallé avec succès !"
					EnterToContinue -DefaultPrompt $true
					Stop-Transcript
					exit
				} else {
					Write-Host "Annulation.."
					EnterToContinue -DefaultPrompt $true
					Stop-Transcript
					exit
				}
			}
			"4" {
				Write-Host "Ouverture de la page GitHub.."
				Start-Process $Github
				Main
			}
			"5" {
				Stop-Transcript
				exit
			}
		}
	}
}
Main
