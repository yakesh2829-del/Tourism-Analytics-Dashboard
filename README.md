# WanderScope — Tourism Analytics Dashboard

A modern R/Shiny tourism analytics dashboard with a custom travel-inspired UI/UX.

## Features
- Overview with tourism KPIs
- Date, destination, experience and visitor-origin filters
- Monthly demand/revenue trend
- Visitor origin analysis
- Destination ranking cards
- Destination-type mix
- Destination revenue performance
- Trip-duration analysis
- Searchable booking explorer
- CSV export
- Fully offline after packages are installed

## Requirements
- R 4.1+ (tested design for R 4.6.1)
- Internet only for the first-time R package installation

## Windows / VS Code
Open the project folder in VS Code PowerShell:

```powershell
& "C:\Program Files\R\R-4.6.1\bin\x64\Rscript.exe" requirements.R
& "C:\Program Files\R\R-4.6.1\bin\x64\Rscript.exe" run_app.R
```

Then open http://127.0.0.1:8080

If port 8080 is busy, run:
```powershell
& "C:\Program Files\R\R-4.6.1\bin\x64\Rscript.exe" -e "shiny::runApp('.', host='127.0.0.1', port=8081, launch.browser=TRUE)"
```

## Project structure
- `app.R` — Shiny UI and server
- `run_app.R` — launcher
- `requirements.R` — package installer
- `data/tourism_data.csv` — bundled sample dataset
- `www/styles.css` — custom UI/UX

## Data
The included dataset is synthetic sample tourism booking data intended for academic/demo use.

## Navigation
The top navigation is functional: Overview, Destinations, Insights and Bookings are separate Shiny views. The Explore destinations button opens Destinations.
