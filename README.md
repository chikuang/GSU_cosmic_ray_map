# GSU Cosmic Ray Detector and Research Map

A Shiny web application that displays cosmic ray detector locations and research sites on an interactive map, with data sourced from Google Sheets.

## Features

- **Interactive Map**: Leaflet-based map showing detector and research locations worldwide
- **Google Sheets Integration**: Automatically reads data from your Google Sheet
- **Automatic Geocoding**: Converts addresses (City, Country, School) to map coordinates
- **Filtering**: Filter by Country and City
- **Data Table**: View filtered data in a searchable table
- **Dynamic Updates**: Data updates automatically when the Google Sheet is modified

## Setup Instructions

### 1. Install Required R Packages

Open R or RStudio and run:

```r
install.packages(c("shiny", "leaflet", "googlesheets4", "dplyr", "DT", "tidygeocoder"))
```

Or use the `.Rprofile` file which will automatically install packages when you open the project.

### 2. Prepare Your Google Sheet

The app is currently configured to use this Google Sheet:
**https://docs.google.com/spreadsheets/d/1rhfsLXwBJXZXwvsUw5cSmItdt44fGl156Ix6jSzAY9Y/edit**

Your Google Sheet should have the following columns:

- **Country**: Country name (e.g., "USA", "Japan", "Turkey")
- **City**: City name (e.g., "Atlanta, Georgia", "Istanbul")
- **School**: School/Institution name (e.g., "Georgia State University")

The app will automatically geocode these locations to get latitude and longitude coordinates. No manual coordinate entry needed!

#### Example Google Sheet Structure:

| Country | City | School |
|---------|------|--------|
| USA | Atlanta, Georgia | Georgia State University |
| Japan | Nara | Nara Women's University |
| Turkey | Istanbul | Istanbul University |

### 3. Make Google Sheet Public (or Set Up Authentication)

**Option A: Public Sheet (Easiest)**
1. In Google Sheets, click "Share"
2. Set sharing to "Anyone with the link can view"
3. Copy the sheet URL

**Option B: Private Sheet with Authentication**
1. Set up Google Sheets API authentication
2. Modify `app.R` to use authentication instead of `gs4_deauth()`
3. See [googlesheets4 documentation](https://googlesheets4.tidyverse.org/) for details

### 4. Configure the App (Optional)

The app is already configured to use your Google Sheet. If you need to change it:

1. Open `app.R`
2. Find the line: `GOOGLE_SHEET_URL <- "https://docs.google.com/spreadsheets/d/1rhfsLXwBJXZXwvsUw5cSmItdt44fGl156Ix6jSzAY9Y/edit"`
3. Replace with your Google Sheet URL

**Note**: The app automatically geocodes locations on first load. This may take a minute or two depending on the number of locations. Geocoded results are cached to speed up subsequent loads.

### 5. Run the App Locally

In R or RStudio:

```r
shiny::runApp("app.R")
```

Or if you're in the project directory:

```r
shiny::runApp()
```

### 6. Deploy to shinyapps.io (Optional)

1. Install `rsconnect` package:
   ```r
   install.packages("rsconnect")
   ```

2. Set up your account:
   ```r
   library(rsconnect)
   rsconnect::setAccountInfo(name="your-account-name", 
                             token="your-token", 
                             secret="your-secret")
   ```

3. Deploy:
   ```r
   rsconnect::deployApp()
   ```

## Customization

### Adjust Default Map Location

In `app.R`, modify the `setView` line:
```r
setView(lng = -84.4, lat = 33.8, zoom = 10)  # Change coordinates and zoom level
```

### Change Filter Options

Modify the `choices` parameter in the `selectInput` functions in the UI section.

### Customize Marker Colors

Modify the color palette in the `type_colors` definition:
```r
type_colors <- colorFactor(
  palette = c("blue", "red", "green", "orange", "purple"),
  domain = unique(df$Type)
)
```

## File Structure

```
GSU_cosmic_ray_map/
├── app.R              # Main Shiny application
├── README.md          # This file
├── requirements.txt   # Package dependencies
├── .Rprofile          # Auto-install packages
└── LICENSE            # License file
```

## Troubleshooting

### Data Not Loading

- Verify the Google Sheet URL is correct
- Ensure the sheet is public (if using public access)
- Check that column names match expected names (case-sensitive)
- Verify Latitude and Longitude columns contain valid numeric values

### Map Not Displaying

- Check browser console for JavaScript errors
- Verify data contains valid coordinates
- Ensure at least one row of data exists after filtering

### Authentication Issues

- For public sheets, ensure `gs4_deauth()` is called
- For private sheets, set up proper authentication credentials

## Author

Chi-Kuang Yeh  
Email: chi-kuang.yeh@mail.mcgill.ca

## License

See LICENSE file for details.
