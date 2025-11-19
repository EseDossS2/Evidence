#EVIDENCE – Windows Forensics & Threat Detection Framework

A compact and extensible framework for collecting and analyzing system evidence on Windows environments.
Built for forensic investigators, blue team analysts, defensive pentesters, DFIR students, and anyone who needs deep visibility into system activity.

Modules
🛰 Collector (EvidenceCollector.ps1)

Captures key forensic artifacts from the system and packages them into a structured ZIP file.
Collected evidence includes:

Running processes & services

Listening ports and active network connections

Registry Run keys

Scheduled tasks

Logon events

Downloads & recent files

Temporary files

Installed programs

Network adapters & IP configuration

Firewall rules

The evidence is exported in an organized format, ready for processing or long-term storage.

⚡ Analyzer (EvidenceAnalyzer.ps1)

Processes the evidence ZIP or a raw folder, performs automated detection of anomalies, and generates professional reports.

Features include:

Basic anomaly detection

Suspicious process and service identification

Network irregularity detection

Persistence mechanism inspection

Behavioral scoring (0–100 risk level)

Automatic HTML, CSV, and TXT report generation

Perfect for:

Post-incident investigations

Blue Team automation workflows

DFIR learning labs

Threat hunting

Security auditing

Local system health & compromise assessment

If you want, I can now create a full README for your repo with:

✔ Installation
✔ Usage examples
✔ Screenshots / sample output
✔ Requirements
✔ License template
✔ Banner ASCII
✔ Folder structure
