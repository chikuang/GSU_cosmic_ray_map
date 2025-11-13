# GSU Cosmic Ray Detector and Research Map

A Shiny web application that displays cosmic ray detector locations and research sites on an interactive map, with data sourced from a local CSV file.

## Features

- **Interactive Map**: Leaflet-based map showing detector and research locations worldwide
- **CSV Data Source**: Reads data from `comsic_data.csv` file
- **Filtering**: Filter by Country and City
- **Data Table**: View filtered data in a searchable table
- **Marker Clustering**: Groups nearby markers for better visualization
- **Zoom Controls**: Full zoom in/out functionality

## Setup Instructions

### 1. Install Required R Packages

Open R or RStudio and run:

```r
install.packages(c("shiny", "leaflet", "dplyr", "DT", "readr"))
```

### 2. Prepare Your Data File

The app reads data from `comsic_data.csv`. Your CSV file should have the following columns:

- **Type**: Type of location (e.g., "Detector")
- **Country**: Country name (e.g., "USA", "Japan", "Turkey")
- **City**: City name (e.g., "Atlanta, Georgia", "Istanbul")
- **School**: School/Institution name (e.g., "Georgia State University")
- **Latitude**: Latitude coordinate (numeric)
- **Longitude**: Longitude coordinate (numeric)

**Note**: The app will automatically create an "Institution" column from the School/City/Country data.

#### Example CSV Structure:

| Type | Country | City | School | Latitude | Longitude |
|------|---------|------|--------|----------|-----------|
| Detector | USA | Atlanta, Georgia | Georgia State University | 33.7536 | -84.3854 |
| Detector | Japan | Nara | Nara Women's University | 34.6856 | 135.8328 |

### 3. Run the App Locally

In R or RStudio:

```r
shiny::runApp("app.R")
```

Or if you're in the project directory:

```r
shiny::runApp()
```

### 4. Deploy to shinyapps.io

1. Install `rsconnect` package:
   ```r
   install.packages("rsconnect")
   ```

2. Set up your account (get token and secret from https://www.shinyapps.io/admin/#/tokens):
   ```r
   library(rsconnect)
   rsconnect::setAccountInfo(
     name = "your-account-name",
     token = "your-token",
     secret = "your-secret"
   )
   ```

3. Deploy the app:
   ```r
   rsconnect::deployApp(
     appDir = ".",
     appName = "GSU_cosmic_ray_map",
     account = "your-account-name"
   )
   ```

   Or simply:
   ```r
   rsconnect::deployApp()
   ```

**Important**: Make sure `comsic_data.csv` is in the same directory as `app.R` when deploying. The file will be included automatically.

## Customization

### Change Data File

Edit the `CSV_FILE_PATH` variable in `app.R`:
```r
CSV_FILE_PATH <- "your_data_file.csv"
```

### Adjust Default Map Location

In `app.R`, modify the `setView` line in the map initialization:
```r
setView(lng = mean_lng, lat = mean_lat, zoom = 3)  # Change zoom level
```

### Customize Marker Appearance

Modify the marker properties in the `addCircleMarkers` function:
```r
addCircleMarkers(
  radius = 8,           # Marker size
  color = "blue",       # Marker color
  fillOpacity = 0.7,    # Opacity
  ...
)
```

## File Structure

```
GSU_cosmic_ray_map/
├── app.R              # Main Shiny application
├── comsic_data.csv    # Data file with detector locations
├── README.md          # This file
├── requirements.txt   # Package dependencies
├── LICENSE            # License file
└── .gitignore         # Git ignore file
```

## Troubleshooting

### Data Not Loading

- Verify the CSV file exists and is named `comsic_data.csv` (or update `CSV_FILE_PATH` in `app.R`)
- Check that column names match expected names (Type, Country, City, School, Latitude, Longitude)
- Verify Latitude and Longitude columns contain valid numeric values
- Ensure the CSV file is in the same directory as `app.R`

### Map Not Displaying

- Check browser console for JavaScript errors
- Verify data contains valid coordinates
- Ensure at least one row of data exists after filtering

### Deployment Issues

- Make sure `comsic_data.csv` is included in the deployment directory
- Verify all packages in `requirements.txt` are available on shinyapps.io
- Check that file paths are relative (not absolute)

## Author

Chi-Kuang Yeh  
Email: chi-kuang.yeh@mail.mcgill.ca

## License

See LICENSE file for details.
