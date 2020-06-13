library("shiny")
library("neatStats")
library("ggplot2")
library("plotly")

nearnormal = function(n, mean = 0, sd = 1) {
    stats::qnorm(seq(1 / n, 1 - 1 / n, length.out = n), mean, sd)
}

### --- Accuracy vs. Effect

col_names = c(
    "d_case1_vs_case2",
    "mean_1",
    "mean_2",
    "d_1",
    "d_2",
    "d_increase",
    "accuracy_1",
    "accuracy_2",
    "accuracy_increase",
    "AUC_1",
    "AUC_2",
    "AUC_increase"
)
results_table = data.frame(matrix(NA , nrow = 0, ncol = length(col_names)))
colnames(results_table) = col_names

d_between_guilties = seq(0.0, 1.2, by = 0.05)
d_case_control = seq(0.5, 2.5, by = 0.5) # c( 0.6, 1.0, 1.4, 1.8, 2.0 )
sd_g = 1 # 33.6
sd_i = 1 # 23.5

N = 500 # 15000 for high precision; much higher number may result in error

for (d_gi0 in d_case_control) {
    for (d_gg0 in d_between_guilties) {
        # dd_gi0 =  mg1 / ( ( (sd_g**2 + sd_i**2)/2  ) **0.5 )
        mg1 = d_gi0 * (((sd_g ** 2 + sd_i ** 2) / 2) ** 0.5)
        # d_gg =  (mg2 - mg1) / ( ( (sd_g**2 + sd_i**2)/2  ) **0.5 )
        mg2 = d_gg0 * (((sd_g ** 2 + sd_g ** 2) / 2) ** 0.5) + mg1
        
        case1 = nearnormal(n = N,
                                 mean = mg1,
                                 sd = sd_g)
        case2 = nearnormal(n = N,
                                 mean = mg2,
                                 sd = sd_g)
        control1 = nearnormal(n = N,
                                   mean = 0,
                                   sd = sd_i)
        control2 = nearnormal(n = N,
                                   mean = 0,
                                   sd = sd_i)
        
        gi1 = t_neat(
            case1,
            control1,
            auc_added = T,
            bf_added = F,
            hush = T
        )
        gi2 = t_neat(
            case2,
            control2,
            auc_added = T,
            bf_added = F,
            hush = T
        )
        
        d_gi1 = gi1$stats["d"]
        d_gi2 = gi2$stats["d"]
        auc1 = gi1$stats["auc"]
        auc2 = gi2$stats["auc"]
        acc1 = gi1$stats["accuracy"]
        acc2 = gi2$stats["accuracy"]
        
        d_gg = t_neat(case2,
                      case1,
                      bf_added = F,
                      hush = T)$stats["d"]
        
        results_table[nrow(results_table) + 1, ] = c(d_gg,
                                                     mg1,
                                                     mg2,
                                                     d_gi1,
                                                     d_gi2,
                                                     d_gi2 - d_gi1,
                                                     auc1,
                                                     auc2,
                                                     auc2 - auc1,
                                                     acc1,
                                                     acc2,
                                                     acc2 - acc1)
    }
}


theplot = ggplot(data = results_table, aes(
    x = d_case1_vs_case2,
    group = accuracy_1,
    color = as.factor(accuracy_1)
)) +
    geom_hline(
        yintercept = seq(0.5, 1.0, by = 0.05),
        colour = "#e6e6e6",
        size = 0.5
    ) +
    geom_line(size = 0.7,
              aes(
                  y = accuracy_2,
                  text = paste0(
                      "Single-case effect size: ",
                      ro(d_case1_vs_case2, 3),
                      "\nBase accuracy: ",
                      ro(accuracy_1, 3, leading_zero = FALSE),
                      "\nNew accuracy: ",
                      ro(accuracy_2, 3, leading_zero = FALSE),
                      "\nIncrease in accuracy: ",
                      ro(accuracy_increase, 3, leading_zero = FALSE)
                  )
              ), 
              linetype = "dashed") +
    geom_line(size = 0.7,
              aes(y = accuracy_increase - 0.1 + round(min(
                  results_table$accuracy_1
              ), 1),
              text = paste0(
                  "Single-case effect size: ",
                  ro(d_case1_vs_case2, 3),
                  "\nBase accuracy: ",
                  ro(accuracy_1, 3, leading_zero = FALSE),
                  "\nIncrease in accuracy: ",
                  ro(accuracy_increase, 3, leading_zero = FALSE)
              )),
              linetype = "solid") +
    scale_color_grey(
        start = 0.7,
        end = 0.0,
        name = 'd: "case 1" vs. "control"',
        label = ro(levels(as.factor(results_table$d_1)), 1)
    ) +
    scale_y_continuous(
        breaks = round(seq(0.6, 1.0, by = 0.05), 2),
        sec.axis = sec_axis(
            ~ . + 0.1 - round(min(results_table$accuracy_1), 1),
            name = "Accuracy gain (solid lines)\n",
            breaks = round(seq(
                min(results_table$accuracy_increase),
                max(results_table$accuracy_increase),
                by = 0.05
            ), 2)
        )
    ) +
    theme_bw() +
    theme(
        text = element_text(family = "serif"),
        legend.position = "right",
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(colour = "#e6e6e6", size = 0.5)
    ) +
    xlab('\nd: "case 1" vs. "case 2"') + ylab('Accuracy: "case 2" vs. "control" (dashed lines)\n')

plotly::config(
    plotly::ggplotly(theplot, tooltip = "text"),
    displaylogo = FALSE,
    modeBarButtonsToRemove = list(
        'autoScale2d',
        'pan2d',
        'zoom2d',
        'zoomIn2d',
        'zoomOut2d'
    )
)





#+ facet_wrap(~ Place, ncol = 3)

#roc_neat( gi1$roc_obj, gi2$roc_obj )
