# GSU Cosmic Ray Detector and Research Map
# Shiny app to display detector and research locations from CSV file

library(shiny)
library(leaflet)
library(dplyr)
library(DT)
library(readr)

# Local CSV file path
CSV_FILE_PATH <- "comsic_data.csv"

# Cluster options
cluster_opts <- markerClusterOptions(
  maxClusterRadius = 50,
  showCoverageOnHover = FALSE,
  zoomToBoundsOnClick = TRUE,
  spiderfyOnMaxZoom = TRUE
)

# Read data from CSV file
detector_data <- tryCatch({
  cat("Reading CSV file:", CSV_FILE_PATH, "\n")
  
  if (!file.exists(CSV_FILE_PATH)) {
    stop("CSV file not found: ", CSV_FILE_PATH)
  }
  
  # Read CSV with UTF-8 encoding, handling encoding errors
  data <- read_csv(CSV_FILE_PATH, show_col_types = FALSE, locale = locale(encoding = "UTF-8"))
  
  # Clean column names
  colnames(data) <- trimws(colnames(data))
  
  # Remove empty columns (columns starting with X, ..., or completely empty)
  empty_cols <- grep("^X\\.?[0-9]*$|^\\.\\.\\.|^$", colnames(data))
  if (length(empty_cols) > 0) {
    data <- data[, -empty_cols, drop = FALSE]
  }
  
  # Handle typo in Latitude column name (do this AFTER removing empty cols)
  if ("Lattitude" %in% colnames(data) && !"Latitude" %in% colnames(data)) {
    colnames(data)[colnames(data) == "Lattitude"] <- "Latitude"
  }
  
  cat("Columns after cleaning:", paste(colnames(data), collapse = ", "), "\n")
  
  # Ensure required columns exist
  if (!"Country" %in% colnames(data)) data$Country <- NA_character_
  if (!"City" %in% colnames(data)) data$City <- NA_character_
  if (!"School" %in% colnames(data)) data$School <- NA_character_
  if (!"Type" %in% colnames(data)) data$Type <- "Detector"
  
  # Check for coordinate columns
  if (!"Latitude" %in% colnames(data)) {
    cat("ERROR: Latitude column not found!\n")
    cat("Available columns:", paste(colnames(data), collapse = ", "), "\n")
    stop("Latitude column missing")
  }
  if (!"Longitude" %in% colnames(data)) {
    cat("ERROR: Longitude column not found!\n")
    cat("Available columns:", paste(colnames(data), collapse = ", "), "\n")
    stop("Longitude column missing")
  }
  
  # Clean UTF-8 encoding issues in character columns first
  char_cols <- c("Country", "City", "School", "Type")
  for (col in char_cols) {
    if (col %in% colnames(data)) {
      # Remove invalid UTF-8 sequences
      data[[col]] <- iconv(as.character(data[[col]]), from = "UTF-8", to = "UTF-8", sub = "")
    }
  }
  
  # Convert coordinates to numeric (handle empty strings and NAs)
  # Use base R approach to avoid column reference issues
  data$Latitude <- suppressWarnings(as.numeric(trimws(as.character(data$Latitude))))
  data$Longitude <- suppressWarnings(as.numeric(trimws(as.character(data$Longitude))))
  data$Country <- as.character(data$Country)
  data$City <- as.character(data$City)
  data$School <- as.character(data$School)
  data$Type <- as.character(data$Type)
  
  # Filter out rows without coordinates
  data <- data[!is.na(data$Latitude) & !is.na(data$Longitude), ]
  
  # Create Institution column (merge School and Name)
  # Use School if available, otherwise fallback to City/Country
  data$Institution <- ifelse(
    !is.na(data$School) & data$School != "",
    data$School,
    ifelse(!is.na(data$City) & data$City != "", data$City, 
           ifelse(!is.na(data$Country) & data$Country != "", data$Country, "Unknown"))
  )
  
  # Clean Institution column for UTF-8 as well
  data$Institution <- iconv(data$Institution, from = "UTF-8", to = "UTF-8", sub = "")
  
  cat("Successfully loaded", nrow(data), "rows with coordinates\n")
  if (nrow(data) > 0) {
    cat("Sample data - First row:\n")
    print(data[1, c("Institution", "City", "Country", "Latitude", "Longitude")])
  }
  data
}, error = function(e) {
  cat("ERROR loading data:", e$message, "\n")
  cat("Stack trace:\n")
  print(e)
  data.frame(
    Institution = character(0),
    Latitude = numeric(0),
    Longitude = numeric(0),
    Country = character(0),
    City = character(0),
    Type = character(0)
  )
})

# UI
ui <- fluidPage(
  titlePanel("GSU Cosmic Ray Detector and Research Map"),
  sidebarLayout(
    sidebarPanel(
      width = 3,
      h4("Filters"),
      selectInput(
        "country_filter",
        label = "Country:",
        choices = c("All"),
        selected = "All"
      ),
      selectInput(
        "city_filter",
        label = "City:",
        choices = c("All"),
        selected = "All"
      )
    ),
    mainPanel(
      width = 9,
      leafletOutput("map", height = "600px"),
      br(),
      h4("Data Table"),
      tableOutput("data_table")
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Update filter choices based on data
  observe({
    cat("Setting up filters - detector_data rows:", nrow(detector_data), "\n")
    if (nrow(detector_data) > 0) {
      countries <- c("All", sort(unique(detector_data$Country[!is.na(detector_data$Country) & detector_data$Country != ""])))
      updateSelectInput(session, "country_filter", choices = countries)
      cat("Countries:", paste(countries, collapse = ", "), "\n")
      
      cities <- c("All", sort(unique(detector_data$City[!is.na(detector_data$City) & detector_data$City != ""])))
      updateSelectInput(session, "city_filter", choices = cities)
      cat("Cities:", paste(cities[1:min(5, length(cities))], collapse = ", "), "...\n")
    }
  }, priority = 10)  # High priority to run first
  
  # Filtered data
  filtered_data <- reactive({
    cat("Filtered data reactive triggered\n")
    df <- detector_data
    cat("Initial rows:", nrow(df), "\n")
    
    # Check if inputs are available
    if (!is.null(input$country_filter) && input$country_filter != "All") {
      cat("Filtering by country:", input$country_filter, "\n")
      df <- df |> filter(Country == input$country_filter)
      cat("After country filter:", nrow(df), "\n")
    }
    if (!is.null(input$city_filter) && input$city_filter != "All") {
      cat("Filtering by city:", input$city_filter, "\n")
      df <- df |> filter(City == input$city_filter)
      cat("After city filter:", nrow(df), "\n")
    }
    cat("Final filtered rows:", nrow(df), "\n")
    df
  })
  
  # Initialize map
  output$map <- renderLeaflet({
    cat("Initializing map - detector_data rows:", nrow(detector_data), "\n")
    if (nrow(detector_data) > 0) {
      mean_lng <- mean(detector_data$Longitude, na.rm = TRUE)
      mean_lat <- mean(detector_data$Latitude, na.rm = TRUE)
      cat("Map center - Lat:", mean_lat, "Lng:", mean_lng, "\n")
      leaflet(options = leafletOptions(
        worldCopyJump = FALSE,
        zoomControl = TRUE,
        minZoom = 1,
        maxZoom = 18
      )) |>
        addProviderTiles(providers$CartoDB.Positron, group = "CartoDB Positron") |>
        addProviderTiles(providers$OpenStreetMap, group = "OpenStreetMap") |>
        setView(
          lng = mean_lng,
          lat = mean_lat,
          zoom = 3
        ) |>
        addLayersControl(
          baseGroups = c("CartoDB Positron", "OpenStreetMap"),
          options = layersControlOptions(collapsed = FALSE)
        )
    } else {
      cat("No data - using default view\n")
      leaflet(options = leafletOptions(
        worldCopyJump = FALSE,
        zoomControl = TRUE,
        minZoom = 1,
        maxZoom = 18
      )) |>
        addProviderTiles(providers$CartoDB.Positron, group = "CartoDB Positron") |>
        addProviderTiles(providers$OpenStreetMap, group = "OpenStreetMap") |>
        setView(lng = 0, lat = 20, zoom = 2) |>
        addLayersControl(
          baseGroups = c("CartoDB Positron", "OpenStreetMap"),
          options = layersControlOptions(collapsed = FALSE)
        )
    }
  })
  
  # Update markers when data or filters change
  observe({
    # Wait for map to be ready
    if (is.null(input$map_bounds)) {
      cat("Map not ready yet, waiting...\n")
      return()
    }
    
    df <- filtered_data()
    
    cat("Observe triggered - filtered data rows:", nrow(df), "\n")
    
    if (nrow(df) == 0) {
      cat("No data to display\n")
      return()
    }
    
    proxy <- leafletProxy("map", data = df)
    proxy |> clearMarkers() |> clearMarkerClusters()
    
    cat("Adding markers for", nrow(df), "locations\n")
    cat("Sample coordinates - Lat:", df$Latitude[1], "Lng:", df$Longitude[1], "\n")
    
    # Create popup content for each row
    popup_content <- sapply(1:nrow(df), function(i) {
      paste0(
        "<strong>", df$Institution[i], "</strong><br>",
        ifelse(!is.na(df$City[i]) & df$City[i] != "", paste("City:", df$City[i], "<br>"), ""),
        ifelse(!is.na(df$Country[i]) & df$Country[i] != "", paste("Country:", df$Country[i], "<br>"), ""),
        "Coordinates: ", round(df$Latitude[i], 4), ", ", round(df$Longitude[i], 4)
      )
    })
    
    # Add markers with clustering
    proxy |> addCircleMarkers(
      lng = df$Longitude,
      lat = df$Latitude,
      radius = 8,
      color = "blue",
      fillOpacity = 0.7,
      stroke = TRUE,
      weight = 2,
      popup = popup_content,
      label = df$Institution,
      clusterOptions = cluster_opts
    )
    
    # Fit bounds to show all markers (only if map hasn't been manually zoomed)
    # Don't force fitBounds if user has interacted with the map
    # This allows users to zoom freely without the map resetting
    # Uncomment the code below if you want automatic fitting on filter changes:
    # if (sum(!is.na(df$Longitude)) > 0 && sum(!is.na(df$Latitude)) > 0) {
    #   proxy |> fitBounds(
    #     lng1 = min(df$Longitude, na.rm = TRUE),
    #     lat1 = min(df$Latitude, na.rm = TRUE),
    #     lng2 = max(df$Longitude, na.rm = TRUE),
    #     lat2 = max(df$Latitude, na.rm = TRUE)
    #   )
    #   cat("Fitted bounds to markers\n")
    # }
  }, priority = 1)  # Run after filters are set up
  
  # Render data table - using simple table output to avoid Ajax errors
  output$data_table <- renderTable({
    df <- filtered_data()
    
    if (is.null(df) || nrow(df) == 0) {
      return(data.frame(Message = "No data to display"))
    }
    
    # Convert to regular data.frame
    df <- as.data.frame(df, stringsAsFactors = FALSE)
    
    # Select columns to display
    keep_cols <- c("Institution", "Type", "Country", "City", "Latitude", "Longitude")
    keep_cols <- keep_cols[keep_cols %in% colnames(df)]
    
    # Create display table
    display_df <- df[, keep_cols, drop = FALSE]
    
    # Clean UTF-8 encoding issues - remove invalid characters
    for (col in colnames(display_df)) {
      if (is.character(display_df[[col]])) {
        # Remove invalid UTF-8 sequences
        display_df[[col]] <- iconv(display_df[[col]], from = "UTF-8", to = "UTF-8", sub = "")
        # Replace any remaining NA with empty string
        display_df[[col]][is.na(display_df[[col]])] <- ""
      }
    }
    
    # Round coordinates
    if ("Latitude" %in% colnames(display_df)) {
      display_df$Latitude <- round(display_df$Latitude, 6)
    }
    if ("Longitude" %in% colnames(display_df)) {
      display_df$Longitude <- round(display_df$Longitude, 6)
    }
    
    display_df
  }, striped = TRUE, bordered = TRUE, hover = TRUE, width = "100%")
}

# Run the application
shinyApp(ui = ui, server = server)
