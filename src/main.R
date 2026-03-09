# ================================
# INSTALL & LOAD LIBRARIES
# ================================

if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  tidyverse,    
  metRology,    
  readxl,       
  pastecs,
  ggplot2,
)

# ================================
# PIPELINE
# ================================
data_analysis_pipeline = function(data, sigma, output_path = getwd()) {
  # Define and create output directory
  output_path <- file.path(output_path, "output")
  
  if (!dir.exists(output_path)) {
    dir.create(output_path)
  }
  
  # Validate input type
  if (!is.vector(data)) {
    stop("Input 'data' must be an atomic vector (numeric, character, etc.)")
  }
  
  if (!is.numeric(sigma)) {
    stop("Input 'sigma' must be an numeric")
  }
  
  # START LOGGING CONSOLE OUTPUT TO TEXT FILE
  log_file = file.path(output_path, "Analysis_Console_Log.txt")
  sink(log_file, append = FALSE, split = TRUE) 
  # split = TRUE allows results to appear in the Console and the file simultaneously
  
  cat("====================================================\n")
  cat("ISO 13528 DATA ANALYSIS REPORT\n")
  cat("Date:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
  cat("====================================================\n")
  
  
  # --------- 1. Data Processing ------------
  
  # STEP A: COERCE TO NUMERIC (Non-numeric strings become NA)
  numeric_result = as.numeric(as.character(data))
  
  # STEP B: FLAG INDICES CONTAINING NA VALUES
  rm_mark = is.na(numeric_result)
  
  # STEP C: REMOVE INVALID DATA BASED ON CALCULATED INDICES
  rm_values = data[rm_mark]
  if(length(rm_values) > 0) {
    cat("\n--- THE FOLLOWING NON-NUMERIC VALUES WERE REMOVED: ---\n")
    print(unique(rm_values)) 
    cat("Total removed items:", length(rm_values), "\n")
    cat("----------------------------------------------------\n\n")
  } else {
    cat("No values were removed. Data is clean!\n\n")
  }
  
  # STEP D: RETRIEVE VALID NUMERIC VALUES FROM ORIGINAL INPUT
  cleaned = numeric_result[!rm_mark]
  
  
  # ERROR HANDLING: Ensure at least some valid data remains
  if(length(cleaned) == 0) {
    stop("Error: No valid numeric data left to analyze!")
  }
  
  print("Cleaned data sent to Algorithm A:")
  print(cleaned)
  
  # --------- 2. DESCRIPTIVE STATISTICS ------------
  
  cat("\n--- DESCRIPTIVE STATISTICS ---\n")
  stat = stat.desc(cleaned)
  print(stat)
  
  # --------- 3. HISTOGRAM AND KERNEL DENSITY GRAPH ------------
  hist_plot = function(){
    hist(cleaned, freq = FALSE,
         main = "Histogram with Kernel Density",
         xlab = "Testing (unit)",
         ylab = "Kernel density",
         breaks = 10)
    
    lines(density(cleaned, kernel = "gaussian"),
          col = "black", lwd = 3)
  }
  
  # --------- 4. Algorithm A ------------
  cat("\n--- FINAL ALGORITHM A OUTPUT ---\n")
  
  algA_result = algA(cleaned, verbose = TRUE)
  mu_hat = algA_result$mu
  print(algA_result)
  
  # --------- 4. Z-score Chart ------------
  df_final = data.frame(
    labcode = as.character(Data$lab_code[!rm_mark]), 
    result = cleaned,
    uncertainty = as.numeric(Data$u[!rm_mark]),
    zscore = (cleaned - mu_hat) / sigma
  )
  
  cat("\n--- RESULTS FINAL ---\n")
  print(df_final)
  
  # SORT DATA ASCENDING BY RESULT (Affects both charts)
  df_final = df_final[order(df_final$result), ]
  df_final$labcode = factor(df_final$labcode, levels = df_final$labcode)
  
  p1 = ggplot(df_final, aes(x = labcode, y = zscore)) +
    geom_col(fill = "steelblue", width = 0.6) +
    geom_text(aes(label = labcode, 
                  hjust = ifelse(zscore >= 0, -0.2, 1.2)), 
              angle = 90, size = 3, vjust = 0.5, fontface = "bold") +
    geom_hline(yintercept = 0, color = "black") +
    geom_hline(yintercept = c(-2, 2), color = "blue", linetype = "dashed", linewidth = 0.5) +
    geom_hline(yintercept = c(-3, 3), color = "red", linetype = "solid", linewidth = 0.5) +
    scale_y_continuous(limits = c(-5, 5), breaks = -5:5) +
    labs(title = "Z-score",
         subtitle = paste("Robust Mean:", round(mu_hat, 4), "| Sigma pt:", sigma),
         x = "Lab Code", y = "z-score") +
    theme_minimal() +
    theme(axis.text.x = element_blank(), 
          axis.ticks.x = element_blank(),
          panel.grid.minor = element_blank())
  
  # --------- 5. Uncertainty Chart (Hình 2) ------------
  p2 = ggplot(df_final, aes(x = labcode, y = result)) +
    geom_hline(yintercept = mu_hat, color = "black", linewidth = 0.8) + 
    geom_hline(yintercept = c(mu_hat + 2*sigma, mu_hat - 2*sigma), 
               color = "blue", linetype = "dotdash", linewidth = 0.5) + 
    geom_hline(yintercept = c(mu_hat + 3*sigma, mu_hat - 3*sigma), 
               color = "red", linetype = 2, linewidth = 0.5) + 
    geom_errorbar(aes(ymin = result - uncertainty, ymax = result + uncertainty), 
                  width = 0.3, color = "black") +
    geom_point(size = 2, color = "black") +
    theme_bw() +
    theme(
      axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, face = "bold"),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()
    ) +
    labs(title = "Measurement Uncertainty Chart",
         x = "Lab Code", y = "Result (Y)")
  
  print(p1)
  print(p2)
  
  # --------- 5. Export Files (Lưu trữ) ------------
  if (!dir.exists(output_path)) dir.create(output_path, recursive = TRUE)
  
  file_csv = file.path(output_path, "ISO13528_Results.csv")
  write.csv(df_final, file_csv, row.names = FALSE)
  
  file_path = file.path(output_path, "Histogram_Density.png")
  png(filename = file_path, 
      width = 800,
      height = 600,
      res = 120)
  hist_plot()
  dev.off()
  
  ggsave(file.path(output_path, "Zscore_Chart.png"), plot = p1, width = 10, height = 6, dpi = 300)
  ggsave(file.path(output_path, "Uncertainty_Chart.png"), plot = p2, width = 10, height = 6, dpi = 300)
  
  cat("\n--- DONE! ---\n")
  cat("All files saved to:", output_path, "\n")
  sink()
  invisible(df_final)
}

# ================================
# TESTING
# ================================

# import and run
Data <- read_excel("your_file_path") # for example: C:/user/statistical-methods-iso13528/data_template/data_ref_iso13528.xlsx
data_analysis_pipeline(data = Data$result, sigma = 0.06)