# Deployment Guide for shinyapps.io

This guide will help you deploy the GSU Cosmic Ray Map app to shinyapps.io.

## Prerequisites

1. Create a free account at [shinyapps.io](https://www.shinyapps.io/)
2. Install R and RStudio (if not already installed)

## Step 1: Install rsconnect Package

Open R or RStudio and run:

```r
install.packages("rsconnect")
```

## Step 2: Get Your Account Credentials

1. Log in to [shinyapps.io](https://www.shinyapps.io/)
2. Go to your account dashboard
3. Click on "Tokens" in the left sidebar
4. Click "Add Token" to create a new token
5. Copy the following information:
   - **Account name** (your username)
   - **Token** (the token string)
   - **Secret** (the secret string)

## Step 3: Configure rsconnect

In R or RStudio, run:

```r
library(rsconnect)

rsconnect::setAccountInfo(
  name = "your-account-name",    # Replace with your account name
  token = "your-token",          # Replace with your token
  secret = "your-secret"         # Replace with your secret
)
```

**Note**: You only need to do this once. The credentials will be saved locally.

## Step 4: Deploy the App

Make sure you're in the project directory (where `app.R` is located), then run:

```r
rsconnect::deployApp(
  appDir = ".",
  appName = "GSU_cosmic_ray_map",
  account = "your-account-name"  # Replace with your account name
)
```

Or simply:

```r
rsconnect::deployApp()
```

## Step 5: Verify Deployment

1. The deployment process will show progress in the console
2. Once complete, you'll see a URL like: `https://your-account-name.shinyapps.io/GSU_cosmic_ray_map/`
3. Open the URL in your browser to verify the app is working

## Important Notes

- **CSV File**: The `comsic_data.csv` file will be automatically included in the deployment
- **File Paths**: All file paths in the app are relative, which is correct for deployment
- **Packages**: All required packages will be automatically installed during deployment
- **Updates**: To update the deployed app, simply run `rsconnect::deployApp()` again

## Troubleshooting

### Deployment Fails

- Check that all files are in the same directory
- Verify `comsic_data.csv` exists and is readable
- Ensure you have internet connection
- Check the console for error messages

### App Doesn't Load Data

- Verify `comsic_data.csv` was included in deployment
- Check that the CSV file has the correct column names
- Look at the app logs in the shinyapps.io dashboard

### Package Installation Errors

- Some packages may not be available on shinyapps.io
- Check the deployment logs for specific package errors
- All packages in `requirements.txt` should be available

## Updating the App

To update your deployed app:

1. Make changes to `app.R` or `comsic_data.csv`
2. Run `rsconnect::deployApp()` again
3. The app will be updated automatically

## Viewing Logs

To see app logs and debug issues:

1. Go to your shinyapps.io dashboard
2. Click on your app
3. Click on "Logs" to view real-time logs

## Free Tier Limitations

The free tier of shinyapps.io has some limitations:
- Limited hours per month
- Apps may spin down after inactivity
- Some resource constraints

For production use, consider upgrading to a paid plan.

